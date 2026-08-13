# Gusteau — Planning

Gusteau is a personal meal-planning and grocery-ordering Android app,
replacing Gousto/HelloFresh-style subscription boxes with a system that:

- suggests recipes each week using a Bedrock-hosted LLM,
- learns from what gets favourited, dismissed, and why — as a list of
  rules you can read and edit, not a hidden blob,
- can reconstruct a recipe from a photo (recipe card or a plate of food),
- consolidates ingredients across the week into a shopping list, skipping
  what's already in the cupboard, and
- turns that into a supermarket basket ready for the owner to pay for.

It is **local-first**: the phone holds the database and does the work,
and AWS is called only for what a phone can't do — LLM inference.
There is no cloud copy of your recipes, preferences, or photos, and
durability comes from Android Auto Backup to your own Google account.

Comparing basket prices across several supermarkets is a post-v1
enhancement — v1 goes end-to-end against Sainsbury's alone.

This directory is the living plan. Build status is in
[status](#status) below; the code itself lives in `/app` (Flutter),
`/infra` (CDK) and `.github/workflows` (CI/CD) at the repo root.

## Documents

| Doc | Purpose |
|---|---|
| [`requirements.md`](./requirements.md) | Feature list as agreed so far, v1 scope and deferred items |
| [`architecture.md`](./architecture.md) | System design: Flutter app, AWS/CDK backend, Bedrock LLM, data model |
| [`risks-and-open-questions.md`](./risks-and-open-questions.md) | Open risks and resolved questions, especially around retailer data access and payment security |
| [`iterations.md`](./iterations.md) | Build order, broken into iterations, each independently shippable to the owner's own phone |
| [`ci-cd.md`](./ci-cd.md) | GitHub Actions pipeline: OIDC-authenticated CDK deploys and CI-built APKs, so everything ships without a PC |
| [`decisions.md`](./decisions.md) | Log of decisions made during planning, once resolved (ADR-style) |

## Status

**Planning is done — no blocking unknowns.** All the originally-open
decisions are resolved (see `decisions.md`: assisted-first ordering,
LLM strategy with an upfront validation spike, no recipe corpus,
single-user local-first design, dismissals and favourites,
£15/month Lambda-first budget, ingredient disambiguation, pantry
staples).

**v1 ends at a textual shopping list** — no price comparison, no
retailer integration, so it depends on nothing outside our control.
Filling the real Sainsbury's trolley is iteration 6, using an approach
worked out from the MIT-licensed
[`open-supermarkets`](https://github.com/abracadabra50/open-supermarkets)
project; multi-retailer price comparison follows after that. This
sequencing means the plan's former biggest risk (retailer data access,
`risks-and-open-questions.md` §9) is off the critical path entirely.

**Iteration 0 (foundations) is built** — see `iterations.md` for the
full checklist. In the repo: the Flutter app skeleton with a tested
Drift/SQLite layer (migrations, a pre-migration snapshot, a
proxy-connection screen), Android Auto Backup wired up with the WAL
checkpoint that makes it safe, the CDK proxy stack (API Gateway +
Lambda `/health` stub + a monthly AWS Budget guard — real Bedrock
calls land in iteration 1), and the three GitHub Actions workflows
(`ci.yml`, `deploy.yml`, `release.yml`).

**Deploy infra succeeded on 2026-08-13** — `GusteauProxyStack` is live
in `eu-west-2`:
`ApiUrl = https://eenk57002b.execute-api.eu-west-2.amazonaws.com/prod/`,
`ApiKeyId = nzuexor6yb`. Getting there needed two real fixes along the
way, both now recorded in `decisions.md`/`ci-cd.md`: `infra/github-oidc.yaml`'s
trust policy had to move to GitHub's newer immutable subject-claim
format (`repo:owner@id/repo@id:...`, not `repo:owner/repo:...`), and
`deploy.yml` had to export `AWS_REGION` (not just `CDK_DEFAULT_REGION`)
to every step, or the CDK CLI's own AWS SDK calls silently defaulted to
`us-east-1`.

**What's left is manual, on the owner's side:**

1. ~~From AWS CloudShell: deploy `infra/github-oidc.yaml`~~ — **done**,
   deployed by hand via the CloudFormation console instead (CloudShell
   wasn't accepting the owner in). Generating the **Android signing
   keystore in CloudShell** is still outstanding — CI runs on a
   temporary checked-in keystore for now (see `decisions.md`,
   2026-08-13); do this before real data is on the device.
2. ~~In the GitHub repo settings: create a `production` Environment...
   set the variables/secrets~~ — **done**, confirmed working (the
   deploy above went through the approval gate and read
   `AWS_DEPLOY_ROLE_ARN`/`AWS_REGION`/`GUSTEAU_BUDGET_ALERT_EMAIL`
   correctly). The four `ANDROID_KEYSTORE_*`/`ANDROID_KEY_*` secrets
   are still outstanding, tied to step 1 above.
3. ~~Push to `main` to trigger the first `deploy.yml` run~~ — **done**.
   Still to do: fetch the real API key value from the AWS console
   (API Gateway → API Keys → `nzuexor6yb` → Show — the stack only
   outputs the *ID*, deploy logs are public) and paste it, with the
   API URL above, into the app's connection screen once installed.
4. ~~Install the CI-built APK... and confirm the round trip to
   `/health` actually works~~ — **done, confirmed 2026-08-13**: the
   app reached `GusteauProxyStack` and got back
   `{"status":"ok","service":"gusteau-inference-proxy",...}`. Phone →
   API Gateway → Lambda is live end to end, on today's temporary
   signing key.
5. Run the install-and-restore test on a real device — iteration 0's
   one requirement that genuinely can't be done in CI.
6. Once CloudShell is reachable again: generate the real keystore,
   set the four Android secrets, delete
   `android/app/sideload.keystore.jks`, and push — **before real data
   is on the device**, since this swap is itself a signing-identity
   change that would otherwise force a data-losing reinstall. See
   `ci-cd.md`, "Android signing".

Iteration 1 (real Bedrock suggestions, replacing the `/health` stub)
starts once the above is confirmed working.

## Ground rules for this plan

- **Local-first.** The device stores the data and does the computing;
  AWS earns its place only where the device genuinely can't do the job.
- **One install, one user, no accounts.** The device is the user;
  nothing in the schema is owned by anybody.
- **No hidden learned state.** Anything the app infers about the owner
  is visible and editable, including the LLM prompt itself.
- Security is a first-class requirement, not a later pass, because a
  real debit card and real supermarket accounts are involved.
- Every iteration should end with something the owner can actually use
  on their phone, even if later iterations replace parts of it.
- Prefer boring, inspectable technology over cleverness, given this is
  built and operated by one person.
- **Everything ships from a phone.** Deploys and app installs go
  through CI, so no step in the normal workflow requires a computer.
