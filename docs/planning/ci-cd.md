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
then `aws-actions/configure-aws-credentials@v4` with `role-to-assume`.

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
  build to prove compilation. Not published.
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
- Sets up JDK 17 (temurin) and Flutter, restores the signing keystore
  from secrets, builds `flutter build apk --release`.
- **Publishes the APK as a GitHub Release asset.** This is the whole
  point: the release page is a URL the phone's browser can open, and
  the APK installs straight from Downloads.
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
