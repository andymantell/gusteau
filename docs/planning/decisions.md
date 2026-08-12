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
