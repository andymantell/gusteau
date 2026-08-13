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

**What's left before it's actually live is manual, on the owner's
side, and can only be done by them** — everything CI-buildable is
built:

1. From AWS CloudShell: deploy `infra/github-oidc.yaml`, and generate
   the Android signing keystore. Both are one-time — see `ci-cd.md`.
   **Blocked as of 2026-08-13** — CloudShell isn't accepting the owner
   in. CI is unblocked in the meantime by a temporary checked-in
   keystore (see `decisions.md`, same date); `deploy.yml` still needs
   the real CloudShell bootstrap, since that role can't be created any
   other way.
2. In the GitHub repo settings: create a `production` Environment with
   a required reviewer (so deploys are an approval tap from the mobile
   app), and set the variables/secrets `ci-cd.md`'s "Secrets and
   variables inventory" lists (`AWS_DEPLOY_ROLE_ARN`, `AWS_REGION`,
   `GUSTEAU_BUDGET_ALERT_EMAIL`). The four `ANDROID_KEYSTORE_*`/
   `ANDROID_KEY_*` secrets are optional for now — CI falls back to the
   temporary keystore without them — but still needed once step 1
   unblocks, to retire it.
3. Push to `main` to trigger the first `deploy.yml` run, then fetch
   the real API key value from the AWS console (the stack only outputs
   its *ID* — deploy logs are public) and paste it, with the API URL,
   into the app's connection screen once installed.
4. Install the CI-built APK (a run artifact from `ci.yml` on `main`,
   or a tagged `release.yml` build) and confirm the round trip to
   `/health` actually works. **Already unblocked** — works with
   today's temporary signing key.
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
