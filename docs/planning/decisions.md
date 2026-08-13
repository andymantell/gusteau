# Decisions log

Resolved decisions move here from `risks-and-open-questions.md`, in
the order they were made. Each entry: the question, what was decided,
and why — so we don't relitigate it later without a reason.

## 2026-08-12 — Ordering automation posture

**Decided:** Phased. Start with assisted handoff (Gusteau builds the
compared basket, hands off to the retailer's own app/site for the
owner to do the final add-to-basket-and-pay step) for every retailer.
Revisit full automation per-retailer later only where it looks
technically viable and the owner is comfortable with the ToS/security
tradeoff.

**Why:** lowest risk and fastest to ship, while still delivering most
of the value (comparison + list-building, which is the tedious part).
Keeps the ordering iteration scoped and avoids taking on standing
retailer credential access before it's proven necessary.

## 2026-08-12 — Target retailers

**Decided:** Tesco, Sainsbury's, Asda, and Waitrose as the initial
set, plus investigate ordering via **Amazon.co.uk's grocery
partnerships** (Morrisons, Co-op, Iceland are all orderable through
Amazon as of 2026, alongside Amazon's own grocery range) as a
potentially efficient fifth channel — one integration against Amazon's
checkout could stand in for several retailer brands at once. Needs a
short technical spike in iteration 5 to confirm feasibility before
committing to it as a channel.

**Why:** covers the major UK grocers the owner is likely to actually
use, with Amazon flagged as worth investigating rather than committed
to, since its viability as an automatable/assistable channel hasn't
been checked yet.

*(Superseded 2026-08-12 — see "v1 is Sainsbury's only" below. This
retailer set is now the post-v1 comparison scope; v1 ships against
Sainsbury's alone.)*

## 2026-08-12 — LLM strategy for recipe suggestions

**Decided:** Primary path is a strong general model on Bedrock (e.g.
Claude) with cookery-focused prompting, per `architecture.md`. In
parallel, run a small **evaluation spike in iteration 1** trying an
off-the-shelf, cookery-specialised open model from Hugging Face (see
`architecture.md` for candidates and why none is an obvious drop-in
win) via Bedrock Custom Model Import, and only keep it in the design
if it demonstrably beats the general-model baseline for
recipe-generation quality.

*(Amended 2026-08-12, see the "no recipe corpus" decision below: the
RAG-grounding half of this originally assumed a curated recipe corpus,
which turned out not to be available and was dropped as a requirement.
Prompt engineering + the household's own preference/dismissal history
remains the plan.)*

**Why:** the owner asked to explore off-the-shelf/Hugging Face
options specifically. Research during planning found existing
"specialist cookery" models on Hugging Face are small (560M–1.1B
parameter), narrowly trained (e.g. diabetic-friendly recipes, one
regional cuisine), and text-only — none are multimodal, which rules
each out as a full replacement given the photo-to-recipe requirement.
Treating it as a time-boxed spike honours the request without
gambling the core suggestion feature on an unproven small model.

## 2026-08-12 — Household / multi-user scope

**Decided:** structure the whole system as multi-user/multi-household
from the start (proper `Household` and `User` entities, per-user
preferences and dismissals), even though it will likely only ever run
for a household of one. Not building a public sign-up flow or
multi-tenant marketing site — just not hard-coding a single-user
assumption into the data model or auth.

**Why:** cheap to do correctly now, expensive to retrofit later, and
the owner wants the option open even if it's never released.

*(Reversed 2026-08-12 — see "One install, one user" below. Once
local-first landed, carrying unused multi-tenancy stopped being cheap
enough to justify.)*

## 2026-08-12 — Weekly plan and dismissal scope

**Decided:** a `WeeklyPlan` is a single shared plan for the whole
household (one set of N meals, not one per member), and dismissing a
recipe — temporary or permanent — removes it for the whole household,
not just the member who dismissed it. The dismissing member and their
reason are still recorded (for feeding back into future suggestion
prompts and so the household knows who dismissed what and why), but
the effect of the dismissal itself is household-wide.

**Why:** confirmed by the owner directly. Also the more internally
consistent design — a single shared plan can't sensibly have one
member still seeing a recipe another member has ruled out.

*(Moot from 2026-08-12 — with one user there is no scope question
left. Dismissals simply apply.)*

## 2026-08-12 — Photo-to-recipe doesn't need cookery specialisation

**Decided:** photo-to-recipe (recipe card or food photo → structured
recipe) uses a plain call to the general multimodal Bedrock model with
a simple extraction prompt — no cookery-specialist system prompt, no
household preference grounding, no RAG, and it's out of scope for the
Hugging Face specialist-model spike from iteration 1. See
`architecture.md`.

**Why:** the owner pointed out that recognising a recipe card is
essentially OCR, and recreating a recipe from a food photo is general
visual reasoning plus food world-knowledge any strong frontier model
already has — neither task benefits from the cookery-specific framing
that suggestion generation needs. Keeping it as a separate, simpler
capability avoids over-engineering it and leaves room to move it to a
cheaper model later if cost matters, independent of the suggestion
engine's model choice.

## 2026-08-12 — No recipe corpus for suggestion grounding

**Decided:** drop the requirement for an external curated recipe
corpus. Suggestion generation relies on the general model's own
culinary knowledge plus the household's own preference/dismissal
history injected per request. The household's own accepted and
photo-derived recipes, already persisted in the data model, can become
an optional self-built retrieval source later once there's enough
usage history — not sourced upfront. See `architecture.md`
("Grounding data") and `risks-and-open-questions.md` §6.

**Why:** the owner doesn't have a recipe corpus, and for a
single-household tool, sourcing/licensing one upfront isn't worth the
effort when the model's own knowledge plus real preference data covers
the actual requirement.

## 2026-08-12 — Favourites, and how a week gets filled

**Decided:** any recipe can be saved as a household-wide favourite —
the positive mirror of a permanent dismissal, feeding future
suggestion prompts as a positive signal. Rather than building a
separate "plan the week" mode, favouriting extends the existing
per-slot refresh mechanic: refreshing a slot can now pull from
favourites instead of asking the LLM. A week is planned by any mix of
default LLM suggestions, favourite picks, and refreshes of either.
When the LLM fills remaining slots, it's given the recipes already
chosen for the other slots that week, so it can plan for variety and,
where possible, ingredient overlap with what's already picked. See
`architecture.md`.

**Why:** the owner wanted to be able to save a good recipe and build a
week around known favourites rather than starting from scratch every
time. Folding it into the existing refresh mechanic (rather than a new
planning flow) keeps the interaction model simple and reuses machinery
already being built in iteration 1.

## 2026-08-12 — AWS budget ceiling: £15/month, Lambda-first

**Decided:** target ceiling of **£15/month**, achieved by design
rather than by monitoring alone. Concretely: Lambda for all compute
(no EC2, no always-on Fargate/containers), no VPC/NAT Gateway, no
Application Load Balancer, API Gateway HTTP API, DynamoDB on-demand
billing, no managed vector/search store, and deliberate attention to
Bedrock token usage (the one genuinely variable cost) via a lean
prompt (no large corpus to process, per the earlier "no recipe corpus"
decision) and a cheaper model tier by default. Full rationale and the
specific traps being avoided (NAT Gateway and ALB especially) are in
`architecture.md`, "Cost and frugality." A CloudWatch billing alarm at
£15 is a day-one (iteration 0) requirement, as a backstop rather than
the primary control.

**Why:** the owner set the figure directly and asked for frugal
infrastructure — Lambda over containers/EC2. Conveniently, this lines
up with decisions already made for other reasons: the assisted-handoff
ordering posture means no long-lived browser sessions (so no Fargate
need), and dropping the external recipe corpus means no vector store
and smaller Bedrock prompts. The main deliberate design discipline
this adds is avoiding NAT Gateway/ALB, which are the classic ways a
"serverless" app ends up with a surprise fixed monthly cost.

## 2026-08-12 — Validate "generic model is good enough" before building on it

**Decided:** treat "a general Bedrock model, no fine-tuning, no RAG,
can already write good recipes" as a hypothesis to test directly, not
assume — add a small manual prompt spike as the literal first step of
iteration 1, before the suggestion service is built. Same spike also
compares Bedrock model tiers for cost (£15/month budget) and runs the
Hugging Face specialist-model comparison already planned. See
`architecture.md`.

**Why:** the owner asked whether generic models can do this, on the
reasoning that recipes/cooking content are well represented in
general pretraining data. That's a reasonable hypothesis — recipe
generation is a commonly-cited strength of general LLMs — but it's
cheap to verify with a handful of real prompts before writing any
application code around it, rather than discovering a quality problem
after the suggestion service, data model, and UI are already built on
top of the assumption.

## 2026-08-12 — Ingredient disambiguation: ask rarely, never twice

**Decided:** resolving an ambiguous ingredient like "mince" into a
specific orderable product follows an escalation ladder rather than
interrogating the owner: (1) the recipe house style requires the LLM
to emit buyable ingredient specs up front, (2) the LLM infers from
dish context where a photo-derived recipe is genuinely vague, (3)
standing household `IngredientPreference` records resolve product tier
and spec silently, (4) the app asks only when a choice is both novel
and consequential, and (5) every answer is stored as a standing
preference so it's never asked again. Questions are batched into the
basket-review step, never surfaced during meal planning, and every
line is pre-resolved to a default with guessed lines flagged — so
correcting is optional, not blocking. Preferences are stored
**retailer-neutrally**, with per-retailer product IDs only as a
revalidated cache. See `architecture.md`.

**Why:** the owner asked how the app would know which kind of mince to
order, correctly anticipating that it would have to ask sometimes. It
does — but a system that asks the same procurement question every week
would be worse than the meal-kit services this replaces. Most
ambiguity is avoidable for free at generation time, most of the rest
is a one-off standing preference, so the genuine question budget is
small and shrinks to near zero after the first few weeks. The
retailer-neutral storage requirement fell out of the same thinking:
price comparison across retailers is actively misleading unless it
compares the same product tier at each, which is impossible if a
preference is stored as one retailer's SKU.

## 2026-08-12 — Pantry staples: assume and disclose, don't track inventory

**Decided:** a household `PantryStaple` list marks ingredients assumed
to be in the cupboard and excludes them from the weekly basket, with:
a quantity threshold per staple so small usages are skipped but bulk
ones ordered ("2 tbsp olive oil" no, "500ml" yes); excluded items
disclosed in a collapsed "assumed you already have these" section at
basket review, each one tap from being added back; a one-tap "running
low" the owner can hit any time, which adds the item to the next
basket; and a soft, plainly-labelled-as-a-guess depletion nudge based
on how many planned recipes have drawn on it since last purchase. The
list is seeded from an LLM-generated default UK pantry at setup and
refined by the same ask-once-remember-forever mechanic as ingredient
preferences. Exclusion runs before retailer matching, so staples never
skew price comparison. See `architecture.md`.

**Explicitly rejected: full pantry inventory tracking** (modelling
quantities and decrementing them as recipes consume them).

**Why:** the owner asked not to be sold olive oil every week. Real
inventory tracking is the theoretically correct answer and a
well-known trap — it only stays accurate if every purchase made
elsewhere, every consumption, and every item that went off is
faithfully logged, which is precisely the kind of admin burden that
kills home inventory apps and that this project exists to avoid. The
chosen design accepts that the app cannot know what's in the cupboard
and is honest about it: it assumes, shows its assumptions, and makes
the human's own observation ("that bottle's nearly empty") the
cheapest possible input. That's more robust than a model that's
precise until the week you forget to update it.

## 2026-08-12 — v1 is Sainsbury's only; price comparison deferred

**Decided:** cut multi-retailer price comparison from the first
version. v1 goes end-to-end against **Sainsbury's** alone: suggestions
→ weekly plan → shopping list → Sainsbury's basket → assisted handoff.
Tesco, Asda, Waitrose, the Amazon.co.uk grocery channel, and the
side-by-side comparison they exist to serve all move to the post-v1
backlog. The retailer adapter boundary stays a thin seam so adding a
second retailer is an addition rather than a refactor — a seam, not a
plugin framework. Retailer-neutral preference storage stays as
designed, since it costs nothing now and comparison depends on it
later.

**Why:** the owner scoped it this way, and it's the right call on
risk. The plan review had just identified retailer product/price data
access as the biggest threat to the project — four retailers, no
public APIs, aggressive bot protection, and workarounds that clash
with the £15/month Lambda-only budget. Cutting comparison collapses
that from "four retailers must work or the headline feature is dead"
to "one retailer, and there's a useful fallback if its data proves
inaccessible" (a well-ordered checklist alongside the Sainsbury's app
is genuinely usable). It also gets the complete loop into real weekly
use sooner, which is the fastest way to learn what actually needs
building next — and comparison is a clean bolt-on afterwards precisely
because nothing else depends on it. Sainsbury's confirmed as the
owner's usual supermarket, so v1 targets where they actually shop.

## 2026-08-12 — Portions and meals per week: defaults plus per-week override

**Decided:** a settings screen holds household defaults for portions
per meal and meals per week. Both are surfaced as overridable when
planning a new week (pre-filled from the defaults), for one-off
changes without editing the defaults. **Portions are uniform across a
week's meals — no per-meal override**, on the owner's explicit
instruction. Implementation-wise, the week's portion count goes into
the generation prompt so recipes arrive at the right quantities rather
than being scaled arithmetically afterwards; reused favourites and
photo recipes whose `serves` differs get one LLM re-expression, cached
as a variant keyed on `(recipe_id, serves)`. See `architecture.md`,
"Portions and recipe scaling."

**Why:** the owner asked for exactly this shape, and the
no-per-meal-override simplification is a good one — it keeps
`WeeklyPlan` holding a single portion count instead of pushing it down
onto every `Suggestion`, and keeps the planning UI to two numbers.
Generating at the target count rather than scaling afterwards avoids
the classic scaling failures (1.5 eggs, non-linear seasoning, pan
sizes, timings) at no extra cost, since it's the same LLM call either
way. Caching rescaled variants keeps repeat use of favourites free,
which matters against the £15/month ceiling.

## 2026-08-12 — Local-first: the device is the system of record

**Decided:** favour on-device storage and compute. The phone's SQLite
database is the system of record — recipes, favourites, dismissals,
preference rules, plans, shopping lists, ingredient preferences,
pantry staples — and all the plain computation (ingredient merging,
staple exclusion, rounding, unit conversion, prompt assembly, basket
construction) runs on the device. **AWS is used only for capabilities
the device genuinely cannot provide**, which in practice means LLM
inference: a thin authenticated proxy Lambda in front of Bedrock, and
nothing else. No DynamoDB, no S3, no Secrets Manager, no VPC. Photos
stay on the handset. Possibly retailer data fetching also moves
on-device — the §9 spike decides. See `architecture.md`.

Rejected along the way: giving the device scoped IAM credentials via a
Cognito Identity Pool to call Bedrock directly. Cheaper and simpler,
but it puts usable AWS credentials on the handset and gives up the one
control point for rate limiting, model pinning and spend guarding.

**Why:** the owner's architectural steer. It turns out to pay for
itself several times over: privacy becomes structural (no cloud copy
of the household's eating habits or photos to leak), the AWS bill
collapses to essentially Bedrock tokens alone, most of the app works
offline including in the supermarket, and there's no network hop for
anything but inference. The costs are real but bounded and mitigable —
device loss is now a data-loss risk needing backup (§10), true
multi-user now needs sync (§11), and logic fixes ship as app builds
rather than Lambda deploys.

## 2026-08-12 — The personalised prompt is a visible, editable list

**Decided:** what the app learns about the household's tastes is
stored as a list of discrete `PreferenceRule` records, not an opaque
accumulated blob, and that list is a screen in the app. Permanently
dismissing a recipe visibly creates a rule from the reason given.
Every rule is editable, disableable (distinct from deletable),
reorderable and deletable, and rules can be added by hand. The
assembled prompt is viewable in full. Reasons are stored verbatim —
no silent LLM rewording, though an optional suggested rewrite is
acceptable. Deleting a rule does not un-dismiss recipes; dismissed
recipes get their own reviewable list. The same no-hidden-learned-state
principle extends to `IngredientPreference` and `PantryStaple`, which
also get editable list screens. See `architecture.md`.

**Why:** the owner asked to see and edit the personalisation rather
than have it accumulate invisibly, and specified a list over a text
blob. That's the right instinct — a single growing blob is impossible
to audit, impossible to partially retract, and tends to drift into
self-contradiction as reasons pile up over months. Discrete toggleable
rules make it possible to see exactly why suggestions changed, and to
test a hypothesis by switching one off. Storing reasons verbatim
matters for the same reason: an LLM helpfully "improving" the owner's
words into something they didn't say would reintroduce precisely the
opacity this feature removes.

## 2026-08-12 — One install, one user: the device is the "user"

**Decided:** strip out the household and user layer entirely. One
household is one device; one user per household; therefore the device
*is* the user. No `Household` table, no `User` table, no owner id on
any row, no accounts, no sign-up. Settings become a single row.
Dismissals and favourites lose their attribution fields — there is
only one person to attribute to. All the "household-wide" scoping
language disappears because there is nothing to scope against.

Cognito goes with it: with one device and no personal data behind the
endpoint, the only thing authentication protects is the Bedrock
budget, so the proxy is guarded by an **API Gateway API key in a usage
plan**, held in the Android Keystore. The usage plan doubles as the
rate limit and monthly quota. See `architecture.md`.

**Supersedes** the earlier "structure as multi-household/multi-user"
decision above, and closes `risks-and-open-questions.md` §11.

**Why:** the owner's call, on the realistic assessment that it's going
to be them and only them. The earlier multi-tenant decision was made
on "cheap now, expensive later" grounds, and that reasoning weakened
considerably once local-first landed — a device-local single-user
database gains nothing from ownership columns, and multi-user would
now need sync machinery regardless, so the schema was never going to
be the hard part of that retrofit anyway. Against that, the cost of
carrying it is paid continuously: a scoping predicate on every query,
attribution on every write, and a user concept threaded through every
screen. Certain cost, unlikely benefit.

**The trade being accepted, stated plainly:** if this ever does need
multiple users, it's a real migration — ownership columns, backfill,
and sync. That was accepted knowingly rather than overlooked.

**Also accepted:** a long-lived API key is weaker than rotating
tokens. Mitigated by hardware-backed Keystore storage, by the key
granting nothing but "relay a prompt to Bedrock", by the usage-plan
quota capping what a leaked key could cost, and by being trivially
rotatable. Cognito remains the fallback if proper token rotation is
ever wanted.

## 2026-08-12 — Android Auto Backup is the durability answer

**Decided:** rely on **Android Auto Backup** as the primary protection
against device loss. App data goes to the owner's Google account and
restores automatically onto a new phone, so the data is tied to the
account rather than the handset — device loss is no longer data loss.
The JSON export stays, but demoted from primary mitigation to escape
hatch (Google-account loss, portability, inspection, app abandonment),
and can therefore sit later in the build order.

Because Auto Backup fails *silently* when misconfigured, iteration 0
must do it properly rather than switch it on and hope:

- a `BackupAgent` that **checkpoints the SQLite WAL** before backup,
  with `-wal`/`-shm` excluded, so the restored database isn't stale or
  corrupt;
- **explicit** `dataExtractionRules` / `fullBackupContent` rather than
  relying on default behaviour;
- **photos excluded**, because they would consume the 25MB per-app
  quota that the rest of the data needs;
- an **actual install-and-restore test on a clean device**, repeated
  when the schema changes materially.

See `architecture.md`, "Backup and durability".

**Why:** the owner's suggestion, and it's right — Auto Backup is
purpose-built for exactly this and costs nothing. It also turns out
not to compromise the privacy stance that motivated local-first: since
Android 9, backups are encrypted with a key derived from the device
passcode, so Google can't read the contents. The reason this gets a
decision entry rather than a one-line note is that the WAL problem is
a genuine trap — Drift and sqflite use WAL mode by default, and a
backup taken without checkpointing restores quietly wrong, which is
the worst possible failure mode for a backup.

**Residual risks accepted:** durability now depends on the Google
account staying accessible (the JSON export exists for that case); up
to ~24h of recent changes may be unbacked, since Auto Backup runs
roughly daily on charge/idle/Wi-Fi; and original photos aren't
restored, only the recipes extracted from them.

## 2026-08-12 — Sainsbury's integration: adopt the approach, not the dependency; ship it after v1

**Decided:** build the Sainsbury's basket integration on the endpoints
and auth flow documented by
[`open-supermarkets`](https://github.com/abracadabra50/open-supermarkets)
(MIT, Zishan Ashraf), reimplemented natively rather than depending on
the library — and schedule it as **iteration 6, after v1 ships a
purely textual shopping list**. Full design in `architecture.md`,
"Sainsbury's integration"; credit the project in the repo when built.

Shape: WebView login against Sainsbury's own page (owner types their
own password, app keeps only session cookies — no stored credential),
Dart HTTP against `groceries-api/gol-services` to resolve products and
fill the real trolley, then hand off in the WebView at the trolley
page for slot and payment.

**Why not the library itself:** it's a Node/TypeScript CLI requiring
Playwright and a filesystem session directory. None of that ships in a
Flutter app, and headful Chromium in Lambda is exactly what the
£15/month budget rules out. But splitting its mechanisms shows only
login, slots and payment need a browser — and a Flutter app already
has one. Android WebView replaces Playwright, which makes the whole
thing fit local-first with no server involved.

**Why after v1:** the owner's sequencing call, and the right one. The
integration depends on an unofficial API that will break eventually;
building the core concept against a textual list first means v1 has no
external dependency at all, and the checklist survives as a permanent
fallback for when the integration does break.

**A correction worth recording:** the project's feature table shows
"Checkout ✓" for Sainsbury's, but the source is explicit that it never
completes payment — `dryRun=false` books a slot, navigates to the
payment page, and stops. So this does **not** deliver unattended
ordering, and adopting it does not reverse the assisted-handoff
decision. Notably, the most capable open implementation available
independently arrived at the same stopping point Gusteau had already
chosen for its own reasons.

## 2026-08-12 — Repeat cooldown: prompt only

**Decided:** recently cooked meals — and near variations of them —
don't come back as unprompted suggestions for a configurable window
(default ~6 weeks). Mechanism: **send the recent history into the
suggestion prompt, and nothing else.** No app-side duplicate check.
Favourite picks are exempt; the window reads accepted suggestions, not
everything ever generated. See `architecture.md`, "Repeat cooldown".

**Corrects an earlier framing in this plan** that described the
cooldown as an app-side filter on recipe identity, in preference to a
prompt instruction. The owner pointed out that this doesn't work, and
they're right: the LLM generates fresh text each time, so a repeat
arrives as a *different* `Recipe` with a different id and title —
"roast chicken thighs with fennel and olives" three weeks after
"chicken thigh traybake with fennel and lemon". Identity matching
would only ever have caught re-picking a stored recipe, which is the
favourites path, and favourites are exempt. The real problem is
near-duplicate detection, not identity.

**Why prompt-first:** it's the only mechanism that gets *semantic*
similarity for free — a model understands that a traybake and a roast
with the same components are the same dinner, where no cheap
deterministic check does. It costs a few hundred tokens.

**Why no backstop yet:** a structural check (protein + method +
cuisine matching something recent → regenerate) was drafted and then
dropped at the owner's request. It's a crude heuristic silently
suppressing suggestions they'd never see, added before any evidence it
was needed. What makes deferring safe is that **this failure mode is
visible**: if the prompt isn't holding, chicken traybake shows up
every fortnight and it's obvious within weeks. Better to add a check
against real evidence — including evidence of *how* it fails, which
determines what the right check is — than to guess now.

**Escalation path if it does prove insufficient:** strengthen the
prompt first; then a structural check on the response; then embedding
similarity over title plus ingredients, stored locally and
cosine-compared against the recent set. The structured attributes
(protein, method, cuisine) are recorded on `Recipe` regardless — they
earn their place for display and filtering, and it means step two
wouldn't start with a blind history.

## 2026-08-12 — CI/CD: OIDC deploys and CI-built APKs, because there's no PC

**Decided:** GitHub Actions is the primary build and deploy mechanism,
not a convenience. Three workflows — `ci.yml` (lint/test/`cdk synth`,
no secrets, safe on any PR), `deploy.yml` (OIDC-authenticated `cdk
diff` + `deploy`, gated behind a `production` environment), and
`release.yml` (signed APK published as a GitHub Release asset). **No
AWS credentials are stored anywhere**; the workflow exchanges a
short-lived OIDC token for a role. The IAM role grants only
`sts:AssumeRole` on the CDK bootstrap roles, not broad permissions.
One manual bootstrap step remains — deploying `infra/github-oidc.yaml`
by hand via the console, since the role that lets CI deploy can't be
deployed by CI. Full design in `ci-cd.md`.

**Why:** the owner raised that they can't run AWS commands from a
phone and are away from their PC. That's not a temporary inconvenience
to work around — it's a standing constraint that should shape the
workflow permanently. OIDC plus CI-built APKs means the entire loop
(change → deploy → install) runs from a phone via the GitHub mobile
app, forever, and as a side effect there are no long-lived credentials
to leak.

**Rejected: handing AWS credentials to this planning session** so the
stack could be deployed immediately. The session runs in an ephemeral
cloud container, credentials would pass through the transcript, and
CDK deploys need permissions that are awkward to scope down. There is
also nothing to deploy yet — iteration 0 is unwritten. Short-lived STS
session credentials would be the least-bad option if something ever
genuinely needs deploying before the pipeline exists.

**Consequence worth recording:** the Android signing keystore becomes
critical data. Android identifies an app by its signing certificate,
so losing it means upgrades can't install over an existing build —
requiring an uninstall that destroys the local database, with Auto
Backup unable to help since restore is tied to the same signing
identity. It therefore needs storing outside GitHub secrets too, which
are write-only. Noted in `risks-and-open-questions.md` §10.

## 2026-08-12 — CI supply chain: first-party actions only

**Decided:** workflows use only actions from the `actions/*`
organisation, SHA-pinned rather than tag-pinned. Everything else is
hand-rolled bash. Concretely this replaces
`aws-actions/configure-aws-credentials` with a direct OIDC token
request plus `sts:assume-role-with-web-identity`,
`subosito/flutter-action` with a cached SDK download, and
`softprops/action-gh-release` with `gh release create`. See `ci-cd.md`
for the shell.

**Why:** the owner's call, and correct. A third-party action executes
arbitrary code on the runner with whatever secrets that step can see —
and in the deploy workflow that includes the OIDC token, which *is*
the access to the AWS account. A compromised action or maintainer
account is a direct route in. Nothing mitigates that adequately when
the alternative is about forty lines of shell. The AWS-published
action is first-party to AWS but not to GitHub, and it sits precisely
in the credential path, so it gets no exemption.

**Cost accepted:** more bash to own. Partly offset by the bash being
more legible than an action's inputs — what it does is visible in the
repo rather than behind a mutable version tag — and by pinning the
Flutter version explicitly, which stops builds changing underfoot.

## 2026-08-12 — Structured output: constrained generation, nullable quantities

**Decided:** recipes are requested via Bedrock's tool-use /
structured-output mode with `Recipe` as the tool schema, not by asking
for JSON in the prompt text. The app validates the parsed object
on-device and retries **once** with the validation error fed back;
a second failure surfaces the real error. Ingredient `quantity` and
`unit` are **nullable**, with a free-text `note`, and units come from
a fixed enum (`g, kg, ml, l, tsp, tbsp, item`). See
`architecture.md`, "The structured-output contract".

**Why:** this is the interface between the model and everything that
does arithmetic downstream — merging, rounding, staple thresholds,
rescaling, product matching. Asking for JSON in prose fails in ways
that are individually rare and collectively constant (markdown fences,
preambles, truncation), and some failures are silent rather than loud:
`grams` one call and `g` the next doesn't error, it just quietly
produces two lines of mince in the basket.

**Why nullable quantities:** requiring a number forces the model to
lie or fail whenever a recipe genuinely means "salt to taste" or "2–3
cloves". Making them nullable costs nothing downstream, because the
ingredients that resist quantification are overwhelmingly the ones
already on the pantry-staples list — they were never going to be
ordered. The two designs fit together without either being bent.

## 2026-08-12 — Export via the system file picker, not the Drive API

**Decided:** the deliberate backup layer is an export/import through
Android's Storage Access Framework — the standard system file sheet —
rather than a Google Drive integration. Optionally includes photos.
A staleness nudge appears in settings.

**Why:** the owner asked for Drive backup, and SAF delivers it without
Gusteau integrating with Drive at all: the system picker already lists
Drive as a destination. No OAuth, no Google Cloud project, no Drive
SDK, no third-party dependency — consistent with the supply-chain
stance taken for CI. It also isn't locked to Drive, so the export can
go somewhere that isn't the same Google account Auto Backup depends
on, which is precisely the failure case this layer exists to cover.
Including photos closes the one real gap in Auto Backup, which has to
exclude them for quota reasons.

## 2026-08-12 — Errors are blunt; testing avoids the LLM

**Decided:** error messages state exactly what failed, with the
underlying status or exception visible and copyable, and distinguish
transient from terminal. Specific named cases: no connectivity, the
monthly spend cap, malformed model output after retry, expired
Sainsbury's session, and the Sainsbury's integration breaking. See
`architecture.md`, "Error handling".

**Testing:** never call a live LLM in CI. Test the deterministic core
hard (merging, unit conversion, rounding, staple thresholds, prompt
assembly, cooldown filtering), test recipe parsing against recorded
fixtures including malformed ones, test migrations against per-version
fixture databases, and snapshot-test `cdk synth`. Keep the iteration-1
spike as a manual eval harness for prompt changes. See `ci-cd.md`,
"Testing strategy".

**Why:** one user who is also the developer, so vague errors help
nobody — and a spend-cap 429 is a guard we deliberately added, so it
will fire and should say so plainly. On testing: the model's output
quality isn't something CI can meaningfully assert, and trying makes
builds flaky and costly. The bugs that actually matter live in the
arithmetic around the model, which is fully deterministic.

## 2026-08-12 — UX is designed by building, not by specifying

**Decided:** no upfront UX document — no screen inventory, no flow
diagrams, no wireframes. Screens get built and the owner reacts to the
running app. To make that work from a phone, `ci.yml` uploads a
**signed APK artifact on every `main` push**, so a build reaches the
device on every change rather than only on tagged releases.

**Why:** the owner's preference, and the better loop. A screen
inventory asks someone to have an opinion about a description of an
interface; an installed build asks them to have an opinion about the
interface. The second produces better feedback and skips a translation
step. It also happens to decouple the pipelines usefully — the APK
path depends on nothing in AWS, so UI and local-database work can run
ahead of the one-time AWS console bootstrap.

**Consequence:** the plan is deliberately silent on UI, and stays
silent. Screens are not going to be back-specified into the docs after
the fact; `requirements.md` describes behaviour and the app itself
describes its interface.

*(Amended 2026-08-12: originally this used unsigned debug APKs, on the
assumption that generating a keystore needed a PC. It doesn't —
CloudShell runs `keytool` from a phone browser — so builds are signed
with the real key from the first one, avoiding a later signing-identity
switch that would have forced an uninstall.)*

## 2026-08-12 — Photos are transient, not stored

**Decided:** a captured image is held only until the extracted recipe
is confirmed, then deleted. No photo store on the device, nothing in
the cloud, nothing in backups or exports.

**Why:** the owner pointed out that these are inputs to OCR and image
recognition, not records — once the `Recipe` exists, the pixels have
no remaining job. Correct, and it deletes a surprising amount of
design: the local photo store, the 25MB Auto Backup quota problem,
the backup-exclusion rules, the optional-photos export archive, and
the UI caveat about restored installs losing snapshots. The app's data
is now text only, comfortably inside every relevant limit.

## 2026-08-12 — Signed builds from the first one; bootstrap from CloudShell

**Decided:** the Android signing keystore is generated in **AWS
CloudShell** — which runs `keytool` in a phone browser — and used to
sign APKs from the very first build. `ci.yml` uploads a signed APK
artifact on `main` pushes, with the signing step gated to `push`
events so pull requests still run with no secrets. The one-time OIDC
bootstrap is likewise a single paste into CloudShell. See `ci-cd.md`.

**Supersedes** the debug-APK approach recorded above, which existed
only to work around an assumed constraint — that generating a keystore
required a PC. It didn't.

**Why:** the owner asked why builds weren't signed from the start, and
whether AWS could be set up from a phone. Both fair. Signing from the
first build avoids ever changing signing identity, which would force
an uninstall and — after iteration 1 — destroy the local database.
Generating the key in CloudShell rather than in this planning session
or a build pipeline keeps private key material somewhere the owner
controls, which matters more than the convenience of having it
generated for them.

*(Temporarily stood in for 2026-08-13 — CloudShell wasn't reachable
from the phone in the moment CI needed a working key. See "Temporary
checked-in sideload keystore" below.)*

## 2026-08-13 — Temporary checked-in sideload keystore, pending real CloudShell key

**Decided:** unblock CI now with a keystore generated locally and
**checked into the repo** (`android/app/sideload.keystore.jks`, fixed
non-secret password), rather than waiting on CloudShell access. This
mirrors the shortcut already taken in another personal project
([`exercise-app`](https://github.com/andymantell/exercise-app)), whose
`build.gradle.kts` comment independently documents the same root
cause: CI runners are stateless, so without *some* persistent key
every build regenerates a fresh random debug key and Android refuses
to install it as an upgrade over the last one ("App not installed").

`build.gradle.kts` now tries three signing sources in order: the real
`key.properties`/GitHub-secrets key (unset), the checked-in sideload
keystore (active now), then debug signing (local dev with neither).
`ci.yml`/`release.yml`'s signing step writes `key.properties` only if
all four `ANDROID_KEYSTORE_*`/`ANDROID_KEY_*` secrets are set, doing
nothing (falling through to the sideload key) if none are, and failing
loudly on a partial set as a real misconfiguration.

**Follow-up owed, tracked in `iterations.md`'s iteration 0 checklist:**
once CloudShell is reachable again, generate the real keystore there,
set the four secrets, and delete `sideload.keystore.jks` — at which
point `build.gradle.kts` automatically prefers the real key without
further code changes. **This must happen before any real user-facing
data accumulates on a device**, since every signing-key change forces
an uninstall (destroying the local database) — the exact failure mode
this whole keystore story exists to avoid. Fine to defer while the app
is a connection-test screen with nothing worth losing yet.

**Why accepted despite the plan's own "generate in CloudShell, keep
private key material owner-controlled" stance above:** unlike
`exercise-app`, Gusteau's roadmap involves real payment and supermarket
account credentials later, so a public signing key is a real (if
narrow) risk long-term — a leaked/forgeable identity could sign a
build Android would accept as a legitimate update. But it's an
accepted, explicitly time-boxed exception, not a reversal: blocked
entirely on CloudShell access, which is an environmental problem
(reported as not letting the owner in), not a design one. Shipping
nothing until that clears would leave the whole pipeline red for no
security benefit, since there is nothing sensitive on the device yet.

## 2026-08-13 — OIDC immutable subject claims: `owner@id/repo@id`, not `owner/repo`

**Decided:** `infra/github-oidc.yaml`'s trust policy condition uses
GitHub's newer **immutable subject claim** format —
`repo:andymantell@134642/gusteau@1331477953:environment:production` —
instead of the classic name-only `repo:andymantell/gusteau:environment:production`
the template originally generated. Two new parameters,
`GitHubOwnerId` and `GitHubRepoId`, hold the numeric IDs (looked up via
the GitHub API: `GET /users/andymantell` → `id`, `GET
/repos/andymantell/gusteau` → `id`), defaulted for this repo.

**Why this was necessary, not stylistic:** GitHub changed the default
OIDC token `sub` claim on **2026-07-15**. Repos created before that
date (or that haven't opted in) still get the classic
`repo:OWNER/REPO:...` format; repos created after — `gusteau`
included, created 2026-08-12 — get an immutable format embedding the
numeric owner and repo IDs instead, specifically to stop a renamed or
recycled repo/org name from inheriting another repo's trust. The
manually-deployed `github-oidc.yaml` stack used the classic format,
so every deploy attempt failed identically: `AccessDenied` /
`Not authorized to perform sts:AssumeRoleWithWebIdentity`, with
nothing in the error naming the actual cause. Diagnosed by web search
once the pattern (correct-looking config, opaque AWS denial) ruled out
every plausible GitHub-Environment or parameter-typo explanation
first.

**Consequence for anyone reusing this template on a different repo:**
`GitHubOwnerId`/`GitHubRepoId` must be looked up and set explicitly —
they're not derivable from the org/repo name strings alone, and
getting them wrong fails exactly the same way, with no error message
pointing at why.

## 2026-08-13 — `deploy.yml` must export `AWS_REGION`, not just `CDK_DEFAULT_REGION`

**Decided:** the OIDC-exchange step in `deploy.yml` now writes
`AWS_REGION=eu-west-2` to `$GITHUB_ENV` alongside `CDK_DEFAULT_REGION`,
so it's available to every later step, not just the one where it was
originally computed.

**Why this was necessary:** after the OIDC trust-policy fix above, the
next deploy attempt succeeded at assuming the role but then failed —
`cdk deploy` tried to check the bootstrap version and assume the CDK
lookup role in **`us-east-1`**, not `eu-west-2`, despite
`AWS_REGION`/`CDK_DEFAULT_REGION` being set correctly at the repo-variable
level. Root cause: the OIDC step's `env:` block scoped `AWS_REGION` to
itself only — it used that value to compute `CDK_DEFAULT_REGION`
for `$GITHUB_ENV`, but never exported `AWS_REGION` itself.
`CDK_DEFAULT_REGION` is read only by the **CDK app** (`app.py`,
constructing `cdk.Environment`); the **CDK CLI's own** AWS SDK calls —
bootstrap-version check, lookup-role assumption — read plain
`AWS_REGION`/`AWS_DEFAULT_REGION` instead, and the CLI actually
**overwrites** `CDK_DEFAULT_REGION` from its own resolved region
before invoking the app. With `AWS_REGION` unset for later steps, the
SDK fell back to `us-east-1`, and that overwrite dragged the app's
synthesized stack there too — so the region mismatch wasn't confined
to the CLI's own calls, it silently redirected the whole deploy.

**Confirmed by evidence, not guessed:** the failure's ARNs
(`cdk-hnb659fds-lookup-role-...-us-east-1`,
`arn:aws:cloudformation:us-east-1:...:stack/GusteauProxyStack/*`) named
the wrong region explicitly. After the fix, the next run's step-env
dump showed both `AWS_REGION: eu-west-2` and `CDK_DEFAULT_REGION:
eu-west-2`, and the deploy succeeded — `GusteauProxyStack` created in
`eu-west-2` as intended, all 19 resources, ~47s.
