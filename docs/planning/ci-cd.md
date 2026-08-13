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
`infra/github-oidc.yaml`, deployed **once, by hand**.

**Do it from AWS CloudShell, which works in a phone browser.** It's a
terminal with your credentials already loaded, so the whole bootstrap
is one paste:

```bash
curl -sSfLO https://raw.githubusercontent.com/andymantell/gusteau/main/infra/github-oidc.yaml
aws cloudformation deploy   --template-file github-oidc.yaml   --stack-name gusteau-github-oidc   --capabilities CAPABILITY_NAMED_IAM
aws cloudformation describe-stacks   --stack-name gusteau-github-oidc   --query 'Stacks[0].Outputs' --output table
```

The last command prints the role ARN to paste into GitHub as a
repository variable. Pasting into CloudShell on a phone is far less
painful than navigating the IAM console's role-creation flow, and
avoids the CloudFormation console's file-upload step (which wants a
local file or an S3 URL — a GitHub raw URL won't do).

Keeping it as a template rather than console clicking also means it's
version-controlled and reproducible.

It creates: the OIDC identity provider for
`token.actions.githubusercontent.com`, and the deploy role with the
trust policy and bootstrap-role-assumption permissions above. It
outputs the role ARN, which goes into GitHub as a variable.

Everything after this point is automated.

## Workflows

### `ci.yml` — on every PR and push

Fast feedback. PRs need no credentials at all; only `main` pushes
touch the signing secrets.

- **infra job:** `ruff` lint, `pytest`, and `cdk synth`. Synth is the
  real check — it proves the CDK app compiles and produces a valid
  template without touching AWS.
- **app job:** `flutter analyze`, `flutter test`, and an APK build.
  Flutter SDK installed by the cached bash step, not a third-party
  action.

**On `main` pushes only, it also builds and uploads a *signed* APK.**
UX is designed by building it and reacting to the running app (see
`decisions.md`), so a build has to reach the phone on every change,
not only on tagged releases. Signing these with the real keystore from
the very first build avoids ever switching signing identity — a switch
would force an uninstall, and after iteration 1 that means losing
data.

The signing step is gated to `push` events on `main`, so **pull
requests still run with no secrets at all** and the "a PR can never
reach credentials" property survives. Tagged releases go through
`release.yml` as proper GitHub Releases; the `main` artifact is the
day-to-day loop.
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

**Status: running on a temporary substitute.** CloudShell wasn't
reachable when CI first needed a working key (see `decisions.md`,
2026-08-13), so `android/app/sideload.keystore.jks` — generated
locally, checked into the repo, fixed non-secret password — stands in
for now. `build.gradle.kts` prefers the real `key.properties`/secrets
key automatically the moment it exists, so switching over needs no
code change, only the steps below plus deleting the sideload file. Do
this **before real data accumulates on the device** — see the
consequence noted below.

**Generate the real one in AWS CloudShell** — the same phone-browser
terminal used for the OIDC bootstrap, so no PC is needed and the key
never passes through anyone else's hands:

```bash
sudo dnf install -y java-17-amazon-corretto-headless   # keytool
keytool -genkeypair -v -keystore gusteau.jks   -alias gusteau -keyalg RSA -keysize 4096 -validity 10000
base64 -w0 gusteau.jks > gusteau.jks.b64   # paste into the secret
```

Then use CloudShell's **Actions → Download file** to save
`gusteau.jks` somewhere durable before the session expires. That copy
matters — see below.

Generating it here rather than in a build pipeline or a third-party
environment is deliberate: private key material should be created
where the owner controls it, and CloudShell is already open for the
OIDC step.

**Once it exists:** set the four `ANDROID_KEYSTORE_*`/`ANDROID_KEY_*`
repository secrets from it (see the inventory table below), delete
`android/app/sideload.keystore.jks` and its `.gitignore` exception, and
push. The next build silently switches to the real key — `main`'s
history from that point on carries only one real signing identity.

**This interacts with the backup story in a way that isn't obvious:**
Android identifies an app by its signing certificate. Lose the
keystore and you cannot ship an upgrade over an existing install — the
new build reads as a different app, so it must be uninstalled first,
**destroying the local database**. Auto Backup restore is also tied to
the signing identity, so the backup won't save you either. **This is
exactly what switching away from the sideload keystore does too** — it
changes the signing identity — so do it while there's still nothing on
the device worth losing, not after weeks of real use.

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
| `GUSTEAU_BUDGET_ALERT_EMAIL` | Where the AWS Budget alert emails go (optional — the stack synths without it) |

All of the above are **repository-scoped**, not Environment-scoped:
`deploy.yml`'s job is the only one bound to the `production` Environment
(that binding is what the required-reviewer approval and the OIDC trust
policy's `sub` condition need), but the Android secrets are also read by
`ci.yml` and `release.yml`, neither of which binds to that Environment.
Environment-scoped secrets are invisible to jobs that don't declare
`environment: production`, so setting them there instead of at the
repository level would silently break those two workflows.

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

## Testing strategy

The app's headline behaviour comes from a model, which is
non-deterministic and costs money — so the test suite deliberately
does **not** try to test that. It tests everything around it, which is
where bugs actually live.

**Never call a live LLM in CI.** It's non-deterministic (flaky builds
for reasons unrelated to the change), it costs tokens on every push,
and a failure tells you nothing actionable. The prompt-quality
question is answered by the manual eval below, not by CI.

### What gets tested hard — the deterministic core

All pure functions, all on-device, all table-driven:

- **Ingredient merging** across recipes, including the nullable-
  quantity cases that must be skipped rather than summed.
- **Unit conversion** and the fixed unit enum.
- **Pack-size rounding**, especially applied to merged totals (three
  recipes needing 300g between them → one pack, not three).
- **Pantry-staple exclusion**, particularly the quantity thresholds
  that decide "2 tbsp oil, skip" vs "500ml oil, order".
- **Prompt assembly** from preference rules — that enabled/disabled
  and ordering are respected, and the recent-meals window is correct.
- **Repeat-cooldown filtering** of the accepted-suggestion history.

This list is essentially the whole of iteration 4 plus the planning
logic, and it's exactly the code where a silent error produces a wrong
shopping list rather than a crash.

### Recipe parsing, against recorded fixtures

Capture real model responses once — including the malformed ones,
which are the valuable fixtures — and commit them. CI replays them
against the schema validator: well-formed parses, truncated JSON
fails cleanly, `"2-3 cloves"` lands as a null quantity with a note,
`grams` vs `g` normalises. No tokens, fully deterministic, and the
fixture set grows every time something new goes wrong in real use.

### Migration tests — higher stakes than usual

The database is the only copy of the data (see `architecture.md`), so
a bad migration destroys the truth rather than a replica of it.

- A **fixture database per schema version**, committed. Each test
  migrates it forward to current and asserts the data survived —
  not just that the migration ran without throwing.
- The app takes an **automatic pre-migration snapshot** of the
  database file before applying anything, kept until the next
  successful launch, so a failure in the wild can roll back instead of
  needing the Drive export.

### CDK snapshot tests

`cdk synth` compared against a committed template. Cheap, and it makes
infrastructure changes visible in the PR diff — including the
accidental ones, like a resource replacement that would delete
something.

### Widget tests, sparingly

The couple of screens with real logic (basket review's resolved/
guessed states, the preference-rule list). Not exhaustive UI coverage,
which for a single-user app is effort better spent elsewhere.

### The manual eval harness

The iteration-1 model spike builds a script that runs a fixed set of
realistic prompts against real Bedrock and shows the output for
judgement. **Keep it rather than throwing it away** — it becomes the
thing you run when changing a prompt, on demand, outside CI. It's the
only honest way to answer "did that prompt change make suggestions
better", and it stays a human judgement call.

## Cost

Nothing. Public-repo Actions minutes are free, and the pipeline adds
no AWS resources of its own — the OIDC provider and role are free.
