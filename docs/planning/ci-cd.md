# CI/CD pipeline

## Why this is a first-class concern

The owner needs to be able to develop, deploy and install Gusteau
**without a PC** — the working assumption is a phone and the GitHub
mobile app. That rules out running `cdk deploy` or `flutter build`
locally as the normal path, and makes CI the primary mechanism rather
than a nicety.

Two problems to solve, and both must work from a phone:

1. **Deploying the AWS stack** without AWS credentials on any device.
2. **Getting an installable APK onto the phone** without a build
   machine.

Solved by: OIDC-authenticated deploys (no stored credentials
anywhere), and CI-built signed APKs published as GitHub Releases,
downloadable and sideloadable directly from the phone's browser.

## Supply-chain policy: first-party actions only

**Rule: only actions from the `actions/*` organisation (GitHub's own).
Anything else is hand-rolled bash.**

The reasoning is the usual supply-chain one, and it applies unusually
sharply here. A third-party action runs arbitrary code on the runner
with access to whatever secrets that step can see — including, in the
deploy workflow, the OIDC token that is the *entire* basis of access
to the AWS account. A compromised action, or a compromised maintainer
account behind one, is a direct route to the account. There's no
mitigating control that makes that acceptable when the alternative is
a few lines of shell.

**Also pin to full commit SHAs, not tags**, even for `actions/*`. Tags
are mutable: `@v4` can be repointed at new code. SHA-pinning costs
nothing and makes the pipeline reproducible, with Dependabot able to
raise PRs to move the pins.

### What this rules out, and what replaces it

| Was going to use | Replaced by |
|---|---|
| `aws-actions/configure-aws-credentials` | Hand-rolled OIDC exchange (below) |
| `subosito/flutter-action` | Download + cache the Flutter SDK in bash |
| `softprops/action-gh-release` | `gh release create` — the GitHub CLI is preinstalled on runners |

Still fine, being first-party: `actions/checkout`,
`actions/setup-python`, `actions/setup-java`, `actions/setup-node`,
`actions/cache`, `actions/upload-artifact`.

The Android SDK is preinstalled on GitHub's `ubuntu-latest` runners,
so nothing extra is needed for it.

### The OIDC exchange, hand-rolled

This is the one worth writing out, because it's the step people assume
needs an action. It doesn't — it's a token request and an STS call:

```bash
# Requires: permissions: id-token: write
TOKEN=$(curl -sSf \
  -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" \
  "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=sts.amazonaws.com" \
  | jq -r '.value')

CREDS=$(aws sts assume-role-with-web-identity \
  --role-arn "$AWS_DEPLOY_ROLE_ARN" \
  --role-session-name "gha-${GITHUB_RUN_ID}" \
  --web-identity-token "$TOKEN" \
  --duration-seconds 3600 \
  --query Credentials --output json)

# Mask before export so nothing leaks into public build logs
for k in AccessKeyId SecretAccessKey SessionToken; do
  v=$(jq -r ".$k" <<<"$CREDS"); echo "::add-mask::$v"
done
{
  echo "AWS_ACCESS_KEY_ID=$(jq -r .AccessKeyId <<<"$CREDS")"
  echo "AWS_SECRET_ACCESS_KEY=$(jq -r .SecretAccessKey <<<"$CREDS")"
  echo "AWS_SESSION_TOKEN=$(jq -r .SessionToken <<<"$CREDS")"
} >> "$GITHUB_ENV"
```

`aws`, `jq` and `curl` are all preinstalled on GitHub runners. The
`::add-mask::` calls matter here specifically because this is a
**public repository** — build logs are world-readable.

### Flutter SDK, hand-rolled

Download the pinned SDK tarball to a cached directory, verify its
checksum, extract, and prepend to `PATH`. Cache keyed on the pinned
version via `actions/cache`, so it's a download once and a restore
thereafter. Pinning the version explicitly is a benefit rather than a
cost — builds stop changing underfoot.

### The trade being accepted

More bash to own and maintain: roughly 40 lines across the workflows,
mostly the two blocks above. That's the price of no third-party code
in the credential path, and it's a good trade at this size. The bash
is also more legible than an action's inputs, since what it does is
visible in the repo rather than behind a version tag.

## Repo layout this assumes

```
/app          Flutter application (Android only)
/infra        CDK app (Python)
/infra/github-oidc.yaml   one-time bootstrap template (see below)
/.github/workflows
```

Path filters key off `app/**` and `infra/**` so a backend change
doesn't rebuild the APK and vice versa.

## Authentication: OIDC, no stored AWS credentials

GitHub Actions requests a short-lived OIDC token and exchanges it for
an AWS role. **No access keys exist anywhere** — not in GitHub
secrets, not on a device, not in this planning session.

```yaml
permissions:
  id-token: write     # required to request the OIDC token
  contents: read
```
then the hand-rolled exchange above — no third-party action sits
between the OIDC token and the AWS account.

### The IAM role should NOT have AdministratorAccess

The common shortcut is to give the GitHub role broad permissions.
Don't. **CDK v2 deploys by assuming the bootstrap roles**, so the
GitHub role only needs permission to assume those:

```
arn:aws:iam::<account>:role/cdk-<qualifier>-deploy-role-<account>-<region>
arn:aws:iam::<account>:role/cdk-<qualifier>-file-publishing-role-<account>-<region>
arn:aws:iam::<account>:role/cdk-<qualifier>-image-publishing-role-<account>-<region>
arn:aws:iam::<account>:role/cdk-<qualifier>-lookup-role-<account>-<region>
```

`<qualifier>` is `hnb659fds` unless bootstrap was run with a custom
one. The account is already bootstrapped, so these exist. The lookup
role is needed for `cdk diff` as well as deploy.

Net effect: a compromised workflow can deploy this app's stack and
nothing more — a far smaller blast radius than an admin role.

### Trust policy must be scoped to this repo and branch

Without a `sub` condition, *any* GitHub repo could assume the role.

```json
"Condition": {
  "StringEquals": {
    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
    "token.actions.githubusercontent.com:sub": "repo:andymantell/gusteau:ref:refs/heads/main"
  }
}
```

Using a GitHub **Environment** instead (`...:environment:production`)
is the better variant — see "Approval from a phone" below.

## One-time manual setup (the chicken-and-egg bit)

The role that lets CI deploy can't itself be deployed by CI. So the
OIDC provider and role live in a small CloudFormation template,
`infra/github-oidc.yaml`, deployed **once, by hand**, via the AWS
console's "Create stack → upload template". Keeping it as a template
rather than console clicking means it's version-controlled and
reproducible, and it's a single console action — feasible from a phone
browser if impatient, trivial from a PC.

It creates: the OIDC identity provider for
`token.actions.githubusercontent.com`, and the deploy role with the
trust policy and bootstrap-role-assumption permissions above. It
outputs the role ARN, which goes into GitHub as a variable.

Everything after this point is automated.

## Workflows

### `ci.yml` — on every PR and push

Fast feedback, no credentials needed, so it runs safely on any PR.

- **infra job:** `ruff` lint, `pytest`, and `cdk synth`. Synth is the
  real check — it proves the CDK app compiles and produces a valid
  template without touching AWS.
- **app job:** `flutter analyze`, `flutter test`, and a **debug** APK
  build to prove compilation. Not published. Flutter SDK installed by
  the cached bash step, not a third-party action.
- Runs both in parallel; caches pip, pub and Gradle.
- No `id-token` permission, no secrets — deliberately, so a PR can
  never reach AWS.

### `deploy.yml` — CDK deploy

- **Triggers:** push to `main` touching `infra/**`, plus
  `workflow_dispatch` for manual runs from the phone.
- OIDC auth → `cdk diff` (logged, so the change is reviewable) →
  `cdk deploy --require-approval never`.
- **`concurrency:` group** so two deploys can't overlap and corrupt
  each other — easy to trigger accidentally from a phone.
- Targets a GitHub Environment (`production`).

### `release.yml` — signed Android APK

- **Triggers:** pushing a `v*` tag, plus `workflow_dispatch`.
- Sets up JDK 17 via `actions/setup-java`, Flutter via the cached bash
  step, restores the signing keystore from secrets, builds
  `flutter build apk --release`.
- **Publishes the APK as a GitHub Release asset** with
  `gh release create` (the GitHub CLI is preinstalled). This is the
  whole point: the release page is a URL the phone's browser can open,
  and the APK installs straight from Downloads.
- Build APK, not App Bundle — `.aab` is for Play Store distribution
  and can't be sideloaded.
- Version name/code derived from the tag so installs upgrade cleanly
  rather than being refused as a downgrade.

### Approval from a phone

Configuring the `production` GitHub Environment with a **required
reviewer** turns deploys into an approval prompt in the GitHub mobile
app. The scary step becomes a deliberate tap rather than a side effect
of merging, and it costs nothing to set up. Recommended for
`deploy.yml`; unnecessary for `release.yml`, which spends no money and
touches nothing live.

## Android signing — and why the keystore is now critical data

Release APKs must be signed with a keystore generated once
(`keytool`), then stored base64-encoded in GitHub secrets.

**This interacts with the backup story in a way that isn't obvious:**
Android identifies an app by its signing certificate. Lose the
keystore and you cannot ship an upgrade over an existing install — the
new build reads as a different app, so it must be uninstalled first,
**destroying the local database**. Auto Backup restore is also tied to
the signing identity, so the backup won't save you either.

So the keystore joins the list of things whose loss is expensive, and
belongs wherever the JSON export escape hatch is kept — see
`risks-and-open-questions.md` §10. It is not enough for it to exist
only in GitHub secrets, which are write-only and cannot be read back.

## Secrets and variables inventory

**Repository variables** (not secret):
| Name | Purpose |
|---|---|
| `AWS_REGION` | Deploy region |
| `AWS_DEPLOY_ROLE_ARN` | Output of the one-time bootstrap template |

**Repository secrets:**
| Name | Purpose |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | The signing keystore |
| `ANDROID_KEYSTORE_PASSWORD` | |
| `ANDROID_KEY_ALIAS` | |
| `ANDROID_KEY_PASSWORD` | |

Notably **no AWS credentials** in that list.

## Public repository considerations

The repo is public, which is mostly good and needs two precautions:

- **Actions minutes are free and unlimited** for public repos, so
  build frequency costs nothing.
- **Keep the AWS account ID out of committed code.** CDK apps often
  hardcode `env={"account": ...}`; here it comes from the deploy
  role ARN variable and `CDK_DEFAULT_ACCOUNT` at run time instead. Not
  catastrophic if leaked, but it's free to avoid.
- Secrets are **not** exposed to workflows triggered by fork PRs,
  which is why `ci.yml` is designed to need none. Release and deploy
  only ever run from the main repo.

## The handoff between the two pipelines

The app needs the API Gateway key to call the inference proxy, and the
key only exists after a deploy. Deliberately **not** baked into the
APK at build time — that would put a credential in a public build
artifact and couple the two pipelines.

Instead: **one-time manual entry.** After the first deploy, retrieve
the key value from the AWS console and paste it into the app's
settings, where it goes into the Android Keystore. Copy-paste between
two apps on a phone is fine for something done once. The CDK stack
outputs the key's *ID* (not its value), since deploy logs are public.

## Cost

Nothing. Public-repo Actions minutes are free, and the pipeline adds
no AWS resources of its own — the OIDC provider and role are free.
