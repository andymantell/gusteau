# Architecture (draft)

This is a first-pass shape, expected to change as open questions get
resolved. Nothing here is built yet.

## Shape: local-first

**The phone is the system. AWS is a capability the phone calls out to
when it genuinely can't do something itself.** That's the governing
rule — see `decisions.md`. In practice the only thing that qualifies
is LLM inference: running a frontier-quality model is not something a
handset does, and the alternatives (small on-device models) wouldn't
meet the quality bar this app depends on.

Everything else — the database, all the planning and shopping-list
logic, every screen's state — lives on the device.

```
Flutter app (Android)  ◀── the system of record
│
├── Local DB (SQLite)        recipes, favourites, dismissals,
│                            preference rules, plans, shopping lists,
│                            ingredient preferences, pantry staples
├── On-device logic          ingredient merge, staple exclusion,
│                            quantity/pack rounding, unit conversion,
│                            prompt assembly, basket/checklist build
├── Local photo store        captured recipe cards and food photos
│
└── HTTPS (Cognito-authenticated) ──▶ AWS
                                      │
                                      └── Inference proxy Lambda
                                            └── Bedrock
                                                  · recipe suggestions
                                                  · photo → recipe

    (+ Sainsbury's product data — on-device or via a fetch Lambda,
       decided by the §9 spike; see "Retailer data" below)
```

**No household data is stored in AWS.** No DynamoDB, no S3 bucket of
photos, no server-side copy of what you like or dislike. The cloud
sees a prompt and returns a completion.

### What this buys

- **Privacy by construction.** Your eating habits, preferences and
  photos never leave the device except as prompt text at the moment of
  inference.
- **Cost.** DynamoDB, S3 and most Lambdas disappear from the bill,
  leaving Bedrock tokens as essentially the only charge — comfortably
  inside the £15/month ceiling (see "Cost and frugality").
- **Offline use.** Browsing recipes, editing the week, regenerating
  the shopping list and working through the shopping checklist in the
  supermarket all work with no signal. Only suggestion generation and
  photo-to-recipe need connectivity.
- **Latency.** No network round-trip for anything but inference.

### What it costs — and the mitigations

- **Device loss = data loss.** The accumulated favourites, dismissal
  reasons and preference rules *are* the product's value. Mitigations,
  in iteration order: Android auto-backup on from day one; explicit
  JSON export/import the owner can run any time and stash wherever
  they like; optional encrypted cloud backup as a post-v1 addition if
  the local-only story ever feels too thin. Tracked as a risk in
  `risks-and-open-questions.md` §10.
- **Multi-device and true multi-user need sync**, which local-first
  doesn't give for free — see "Multi-user, revisited" below.
- **Logic ships in the app**, so fixing a bug means shipping a build
  rather than deploying a Lambda. Acceptable for a personal
  sideloaded app; worth remembering when the retailer-adapter parsing
  breaks (see "Retailer data").

## Client — Flutter (Android)

The app is the whole product; everything below runs on the handset.

- **Local database: SQLite**, via a typed Flutter data layer (Drift is
  the obvious candidate — compile-time-checked queries and painless
  migrations, which matter when the schema is the system of record
  rather than a cache). Holds every entity in the data model below.
- **On-device logic** for everything that's plain computation:
  cross-recipe ingredient merging, pantry-staple exclusion, pack-size
  rounding, unit conversion, shopping-list assembly, basket/checklist
  construction, and assembling the LLM prompt from the household's
  preference rules. None of this needs a server, so none of it gets
  one.
- **Photos stay on the device.** Captured images are resized and
  compressed locally, then sent as part of the inference request —
  never stored in the cloud. Resizing is needed anyway to keep vision
  token costs and request payloads down.
- **Talks to AWS only for inference** (and possibly retailer product
  data — see below). Never holds AWS credentials directly; never talks
  to Bedrock without going through the proxy.
- **Local device auth** (biometric/PIN) gates opening the app. With
  the data now living on the handset rather than in a cloud account,
  this is the primary protection for it, not a secondary nicety — see
  "Security posture".

## Backend — AWS, CDK (Python)

Deliberately small. One stack, a handful of resources, no data stores.

- **Inference proxy Lambda** behind an **API Gateway HTTP API**. Takes
  an assembled prompt (and optionally an image) from the app, calls
  **Bedrock**, returns the completion. Stateless — it stores nothing.
  Its jobs beyond relaying:
  - keep AWS credentials off the device entirely;
  - pin the model and parameters server-side, so a compromised or
    modified client can't switch to an expensive model;
  - enforce a request rate limit and a monthly spend guard, the
    active control that keeps Bedrock inside budget;
  - be the one place to add cost logging.
- **Cognito** authenticates the device to that endpoint. Its role is
  narrower than before: it protects the *inference budget*, not stored
  data, because there is no stored data. Still worth having — an
  unauthenticated Bedrock relay on the public internet is somebody
  else's free LLM.
- **CloudWatch** for proxy logs and the billing alarm. Short retention
  (2 weeks). No personal data in logs: log token counts and latency,
  never prompt or completion bodies.
- **No DynamoDB, no S3, no Secrets Manager, no VPC.** Nothing to put
  in them.

**Considered and rejected: a Cognito Identity Pool handing the device
scoped IAM credentials to call Bedrock directly**, removing the Lambda
and API Gateway entirely. It's cheaper still and appealingly simple,
but it puts usable AWS credentials on the handset and gives up the
single control point for rate limiting, model pinning and spend
guarding — a poor trade when the whole cost model rests on Bedrock
usage staying bounded. The proxy stays.

### Retailer data

Where Sainsbury's product data is fetched from — device or Lambda — is
decided by the §9 spike, and the local-first steer adds a genuine
argument for the device: requests from a residential mobile IP are far
less likely to trip bot protection than requests from AWS IP ranges.
Against that, parsing logic on the device can only be fixed by
shipping a build. The spike should weigh both; on-device is the
default under this architecture unless it proves unworkable.

## Multi-user, revisited

The earlier decision to model `Household` and `User` as first-class
(`decisions.md`) is in genuine tension with local-first: if the phone
is the system of record, two household members on two phones have two
disconnected systems. Sync is the missing piece, and local-first
doesn't provide it for free.

**Resolution:** keep the schema multi-user-shaped — households, users,
attribution on dismissals and favourites — exactly as designed, but
accept that **v1 is single-device**. That preserves the cheap-now,
expensive-later property the original decision was about (the schema
doesn't have to be retrofitted) without pretending v1 delivers
multi-user. Real multi-user is unlocked by sync, which becomes the
post-v1 feature that would deliver it, and would also solve the
device-loss problem in passing. Nothing about v1 forecloses it.

## Cost and frugality

Budget ceiling: **£15/month**, set by the owner. Local-first makes
this much easier: with no data stores and almost no compute in the
cloud, **Bedrock tokens are essentially the only line on the bill.**

- **Bedrock is the one real cost**, billed per token. Mitigations: no
  RAG context to process on every call (see "Grounding data"); default
  to a cheaper model tier and step up only where the iteration-1 spike
  shows it's needed; resize photos on-device before sending; cache
  rescaled recipe variants so repeat use of a favourite is free (see
  "Portions and recipe scaling"); and enforce a rate limit and monthly
  spend guard in the proxy Lambda, which is the active control rather
  than just a warning.
- **Lambda and API Gateway** stay inside the free tier at this volume
  — a few inference calls a week rounds to £0.
- **Cognito** is free at this scale.
- **No DynamoDB, S3, Secrets Manager, or vector store** — the
  local-first design removes them rather than optimising them.
- **No NAT Gateway, ever.** The classic way a "cheap" serverless app
  quietly costs £25+/month: it bills per hour just for existing. The
  proxy Lambda reaches Bedrock over the SDK with no VPC, so there is
  no VPC and no NAT.
- **No Application Load Balancer** (bills hourly regardless of
  traffic); API Gateway HTTP API is pay-per-request with no idle cost.
- **No EC2, no always-on Fargate/containers.**
- **A CloudWatch billing alarm at £15/month is a day-one requirement**
  (iteration 0) — the backstop behind the proxy's spend guard.

## LLM strategy

Two genuinely different LLM use cases live in this app, and they don't
need the same treatment. Splitting them out:

### Shared house style: how recipes get written

Regardless of which capability produces a `Recipe` (suggestion
generation or photo-to-recipe below), two fixed instructions apply to
both prompts, rather than being decided independently by each:

- **`method`** is written for a competent home cook, not a beginner —
  no narrating basic technique, no padding. It should include whatever
  actually varies dish-to-dish and would trip up someone recreating it
  blind: specific temperatures/times, ordering that matters, and any
  step that's easy to get wrong for *this* dish. See `requirements.md`
  for the full spec.
- **`ingredients` are specified precisely enough to buy**, not just
  precisely enough to cook. "500g beef mince, 12% fat" rather than
  "mince"; "chicken thighs, boneless and skinless" rather than
  "chicken". The LLM knows what a bolognese wants even when a human
  writing the recipe wouldn't bother spelling it out, so making the
  model be explicit at generation time removes most downstream
  ambiguity for free. This is the cheapest place to solve it — see
  "Ingredient specificity and product preferences" below.

### Recipe suggestion generation — this is where "specialist" matters

This is the part that benefits from cookery-specific framing: it needs
to reason about substitutions, weigh a household's accumulated
preferences and dismissal reasons, and produce well-formed, varied
weekly suggestions. Bedrock doesn't offer an off-the-shelf "cookery"
foundation model, so "specialist" needs to be built rather than picked
off a shelf. During planning we looked specifically at Hugging Face
for existing cookery-specialised models, per the owner's request.
What's actually out there:

- Small, narrowly fine-tuned recipe generators — e.g. a BLOOM-560M
  fine-tune aimed at diabetic-friendly recipes, a TinyLlama fine-tune
  on ~10K Indian recipes ("CookGPT"), and encoder-only models like
  RecipeBERT (trained on Recipe1M+, good for embeddings/retrieval, not
  generation).
- All of these are **text-only** and narrowly trained. None are an
  obvious drop-in replacement for a frontier general model on quality
  of open-ended recipe reasoning (substitutions, working from a fuzzy
  owner preference like "too spicy").

**Why a generic frontier model should be good at this without any
special training:** recipes, cooking forums, and food blogs are a
large and well-represented slice of the web-scale text general
foundation models are pretrained on — recipe generation is one of the
more commonly-cited "the model already knows this well" tasks for
general LLMs. That's the working hypothesis behind treating
prompt-only, no fine-tune, no RAG as a credible primary path rather
than something that obviously needs a specialist model — but it's a
hypothesis, not something to take on faith, hence testing it directly
rather than assuming it (see the spike below).

Given that, the plan for suggestion generation is:

1. **Step zero — a small prompt/model spike before building anything
   around it.** Before investing in the suggestion service, run a
   handful of realistic test prompts (varied cuisines, a fuzzy
   preference like "not too spicy", an ingredient-substitution ask)
   directly against candidate Bedrock models by hand — a cheap and
   fast way to test the "generic model is already good at this"
   hypothesis above before committing to it. Two things fall out of
   this spike:
   - **Quality check** — confirm output is genuinely good (correct,
     well-formed, follows the `method` house style) without any
     fine-tuning or RAG. If it isn't, that's the point to reconsider,
     not after the suggestion service is built around the assumption.
   - **Model tier / cost check** — compare a cheaper/smaller Bedrock
     model against a more capable one on the same prompts, and default
     to the cheapest tier that's good enough (ties into the £15/month
     budget — see "Cost and frugality"), stepping up only where
     evaluation shows it's actually needed.
2. **Primary path — prompt engineering on a strong general model**
   (e.g. a Claude model on Bedrock, at whichever tier the spike
   above settles on): a system prompt encoding cookery expertise, with
   the household's standing preferences and dismissal reasons injected
   into every request. **No external recipe corpus required** — see
   "Grounding data" below for why, and where a retrieval step fits in
   later without needing one upfront. Fast to build, easy to iterate,
   no training pipeline.
3. **Same spike, extended — evaluate a Hugging Face cookery model as a
   supplement**, imported via **Bedrock Custom Model Import** (which
   supports a specific set of open architectures — broadly
   Llama/Mistral/Mixtral-family and a few others; confirm the chosen
   model's architecture is supported before committing). Run it on the
   same test prompts and rubric as step zero, and only keep it in the
   design — e.g. as a specialised sub-step for a narrow task like
   ingredient substitution — if it demonstrably beats the general-model
   baseline. Time-boxed; not a hard dependency for iteration 1 to ship.
   **Scoped to suggestion generation only** — see below for why it
   doesn't apply to the photo feature.
4. **Fine-tuning our own model** stays as a later option, not pursued
   now — for a single-household tool the effort of maintaining a
   training pipeline is hard to justify unless the spike and its
   follow-ups both prove insufficient.

#### Grounding data — no recipe corpus needed upfront

The original plan assumed a curated recipe corpus to ground
suggestions via RAG. The owner doesn't have one, and sourcing one
upfront isn't worth the effort for a single-household tool, so that
requirement is dropped:

- **The model's own training knowledge is the baseline.** A frontier
  general model already has broad culinary knowledge — no retrieval
  needed to produce reasonable, varied recipes on its own.
- **The data that actually needs to be "retrieved" per request is the
  household's own preferences and dismissal history** (already in the
  data model — `Dismissal`, accepted `Recipe`s), which is generated by
  using the app, not sourced externally. This is the part that matters
  for personalisation, and it exists regardless of any external
  corpus.
- **The corpus grows itself, if one ever helps.** Every recipe the
  household accepts, or that gets reconstructed via photo-to-recipe,
  is already persisted as a `Recipe`. Once that history has enough
  volume, it can double as a lightweight, self-built RAG source (e.g.
  "you already had something similar to X two weeks ago", or
  grounding substitutions in dishes the household is known to like) —
  worth revisiting once there's real usage data, not before.
- **If broader inspiration beyond the model's own knowledge is ever
  wanted**, a free dataset (e.g. TheMealDB) or nutrition/ingredient
  database (e.g. Open Food Facts, useful anyway for the shopping-list
  ingredient-matching problem in `risks-and-open-questions.md` §8)
  could be bolted on later — optional, and separate from whether
  suggestion generation itself needs it.

#### The personalised prompt is a visible, editable list

Everything the app learns about the household's tastes is stored as a
**list of discrete `PreferenceRule` records**, never as an opaque blob
of accumulated text — and that list is a first-class screen in the
app, not a hidden internal.

- **Each rule is one editable line.** "Too spicy — go easy on chilli",
  "No okra", "Nothing over an hour on weeknights". The prompt sent to
  Bedrock is assembled on-device from the enabled rules at request
  time.
- **Permanently dismissing a recipe visibly creates a rule** from the
  reason given, and the UI says so — the owner sees the rule appear
  rather than wondering what the app did with their reason.
- **Reasons are stored verbatim.** No silent LLM rewriting of what the
  owner typed into something more "prompt-shaped"; putting words in
  their mouth is exactly the opacity this feature exists to remove. An
  optional *suggested* rewording they can accept or ignore is fine;
  automatic replacement is not.
- **Every rule can be edited, disabled, re-enabled, reordered or
  deleted.** Disabled rather than deleted matters: "stop applying this
  for now" is a different intent from "I never meant that", and being
  able to toggle one off is the fastest way to test whether a rule is
  making suggestions worse.
- **Rules can be added by hand**, without a dismissal prompting them —
  the list is the household's standing brief to the model, however it
  got there.
- **The assembled prompt is viewable.** A "see the full prompt"
  affordance shows exactly what gets sent, rules and all. If the app
  is going to claim a rule is being applied, it should be able to show
  it in situ.
- **Provenance is kept**: whether a rule came from a dismissal (and
  which recipe), or was typed by hand, plus who added it and when.
  Useful for making sense of a list that's a year old.

**Deleting a rule does not un-dismiss recipes.** The rule and the
dismissal are separate facts: "don't suggest this specific recipe
again" and "we don't like this thing generally" were both true, and
undoing one shouldn't silently undo the other. Dismissed recipes get
their own reviewable list, where individual blocks can be lifted.

The same principle — **no hidden learned state** — applies to the
other things the app quietly accumulates: `IngredientPreference` (see
below) and `PantryStaple` both get inspectable, editable list screens
for exactly the same reason.

#### Favourites — the positive mirror of dismissal, and filling the week

A saved favourite is treated as the positive counterpart to a
permanent dismissal: both are household-wide preference signal that
gets fed back into the suggestion prompt (favourites push towards a
style/cuisine/flavour profile, dismissal reasons push away from one).

Rather than a separate "meal planning mode," favouriting slots into
the existing per-slot refresh mechanic from the core loop: refreshing
a `Suggestion` slot gains a second source alongside "ask the LLM for
something new" — "fill from favourites." A week can be planned as any
mix of the two: leave every slot on its default LLM suggestion, swap
specific slots to a favourite, or swap most of them and let the LLM
fill only what's left.

When the LLM fills the remaining slots, the prompt includes the
`Recipe`s (and their ingredients) already sitting in the other slots
for that week — so it's not suggesting blind. This serves two things:
variety (don't suggest something too similar to a favourite already
picked) and, usefully, ingredient overlap — the same mechanism that
lets the shopping list merge shared ingredients after the fact
(`risks-and-open-questions.md` §8) can nudge the LLM to lean into
ingredients already in play for the week (e.g. suggest something else
using chicken thighs if a favourite pick already needs them), reducing
the basket rather than just merging it after the plan is fixed.

### Photo-to-recipe — doesn't need a specialist model at all

Recognising a recipe card is essentially structured OCR; recreating a
recipe from a photo of food is general visual reasoning plus the kind
of broad food/cooking world-knowledge any strong frontier model
already has — neither needs cookery-specific fine-tuning nor the
household preference context used for suggestions. So this stays
deliberately simple:

- A single call to the same general multimodal Bedrock model used for
  suggestions (no separate model to run, but a distinct, much simpler
  prompt — "extract/infer a structured recipe from this image", plus
  the shared `method` house style above; no cookery-specialist system
  prompt, no preference grounding, no RAG).
- Out of scope for the Hugging Face specialist-model spike above —
  none of those candidates are multimodal anyway, and even if one
  were, this task doesn't need cookery specialisation to begin with.
- Possible later optimisation, not a decision now: if cost matters at
  volume, this call could move to a cheaper/smaller vision-capable
  model on Bedrock, since it isn't leaning on niche cookery reasoning
  the way suggestion generation is.

## Portions and recipe scaling

Portion count is set per week (defaulting from household settings) and
applies uniformly to every meal in that week — no per-meal override,
by design. It has to reach the actual ingredient quantities, or the
shopping list is wrong.

**Generate at the target portion count; don't scale afterwards.**
Arithmetic scaling of a finished recipe breaks in obvious ways — 1.5
eggs, seasoning that isn't linear, a pan that's now too small, a
roasting time that should have changed. The LLM knows all of that, so
the week's portion count goes into the generation prompt and recipes
come back already correct for it. This is free: it's the same call
either way.

**Reused recipes need one rescale, cached forever.** Favourites and
photo-derived recipes were captured at whatever `serves` count they
were written for. When one is picked for a week with a different
portion count, Gusteau re-expresses it at the new count via a single
LLM call and caches the result keyed on `(recipe_id, serves)`. So a
favourite reused at 4 portions costs one extra call the first time and
zero every time after — which matters against the £15/month ceiling
given favourites are meant to be reused often.

**Downstream this is uneventful**, which is the point: bigger
quantities flow through cross-recipe merging, pack-size rounding, and
staple thresholds unchanged. A staple stays a staple at 6 portions (4
tbsp of oil is still oil you own); a borderline ingredient may cross
its threshold and start being ordered, which is the correct behaviour.

**Changing the meal count mid-planning** adds or removes slots:
increasing appends empty slots for the LLM to fill (with the existing
picks as context, per the favourites design); decreasing removes
trailing slots, confirming first if that would discard a slot the
owner has already accepted or filled from a favourite.

## Ingredient specificity and product preferences

"Mince" is the canonical example of a problem that runs through the
whole shopping-list and price-comparison half of the app. There are
three distinct ambiguities hiding in one word, and they need different
answers:

1. **Which ingredient?** Beef, pork, lamb, turkey, Quorn.
2. **Which specification?** Beef mince at 5%, 12%, or 20% fat.
3. **Which product?** Even given "500g beef mince, 12% fat", a single
   retailer sells a value line, a standard own-brand, an organic, and
   a premium range — at materially different prices.

The design goal is **ask rarely, and never ask twice**. Concretely, an
escalation ladder, where each rung resolves most cases so the next
rung sees few:

1. **Generate unambiguously.** The house style above requires the LLM
   to emit buyable ingredient specs. This eliminates most of (1) and
   much of (2) at zero interaction cost.
2. **Infer from dish context.** Where a recipe is still vague —
   realistically the photo-derived ones, since a photographed recipe
   card may genuinely just say "mince" — the LLM resolves it from the
   dish (a bolognese means beef; a moussaka means lamb) as part of
   normalising the recipe. Inferred values are marked as inferred, not
   presented as though the source said so.
3. **Apply standing household preferences.** Choice of product tier is
   a personal standing preference, not a per-recipe fact: "own-brand
   standard range unless I say otherwise", "always 12% beef mince",
   "never the value range for meat". Once expressed, these resolve (3)
   and the rest of (2) silently, forever.
4. **Ask — but only when it's novel and it matters.** A first-time
   ingredient with a consequential fork (which meat? which fat
   content?) is worth one question. A trivial or low-stakes one
   (which brand of tinned tomatoes) is not — pick the default and let
   the owner override if they care.
5. **Record every answer as a standing preference**, so rung 3 handles
   it next time. The question budget shrinks toward zero over the
   first few weeks of use.

**Ask at basket review, not during meal planning.** Questions are
batched and deferred to the point where the owner is already reviewing
the shopping list before ordering — never interrupting the enjoyable
part (picking the week's meals) with procurement admin. The review
screen shows every line already resolved to a specific product with a
sensible default, and visually flags the ones the system guessed at,
so correcting a guess is the same interaction as answering a question
would have been — but the basket is usable even if the owner corrects
nothing.

**Store preferences retailer-neutrally.** Even though v1 is
Sainsbury's-only, the resolved ingredient is stored in
retailer-neutral terms ("beef mince, 12% fat, ~500g, standard
own-brand tier") and matched into a retailer's catalog at basket time.
It costs nothing now and is a hard requirement for the deferred price
comparison: comparing retailers is meaningless — actively misleading —
if it silently pits one's value mince against another's organic, which
is impossible to avoid if a preference is stored as one retailer's
SKU. Where a retailer has no equivalent at the specified tier, the
comparison surfaces that explicitly (substituted up/down, or
unavailable) rather than quietly swapping in whatever matched.
Per-retailer product IDs are therefore only ever a *cache* on top of
the neutral spec — useful for speed and re-ordering, and revalidated,
because products get discontinued.

## Pantry staples — what not to order

Recipes list everything they need; a shopping list should only contain
what you don't already have. Two tablespoons of olive oil, a pinch of
salt, a teaspoon of cumin — ordering these weekly is waste, cost, and
a basket the owner has to manually prune, which is exactly the chore
the app exists to remove.

**What's explicitly rejected: full pantry inventory tracking.**
Modelling actual quantities and decrementing them as recipes consume
them is the "correct" answer and a well-known trap — it only works if
the owner faithfully logs every purchase made elsewhere, every
consumption, and everything that went off. Home inventory apps die on
this, and it degrades silently the moment you stop keeping up. Not
worth it for a personal tool.

**What's proposed instead: assume, disclose, and let the human be the
sensor.**

- A household **`PantryStaple` list** marks ingredients assumed to be
  in the cupboard — cooking oils, vinegars, salt/pepper, dried herbs
  and spices, flour, sugar, stock, condiments, and whatever else the
  owner keeps in. These are excluded from the shopping list by
  default.
- **Quantity threshold, not just ingredient identity.** "2 tbsp olive
  oil" is a staple usage and gets skipped; "500ml olive oil" for a
  confit is a shop, and gets ordered. Same for butter — a knob for
  frying is assumed, 250g for pastry is not. Each staple carries a
  threshold above which it stops counting as one, which is most of
  what makes this feel intelligent rather than blunt.
- **Excluded staples are shown, not hidden.** The basket-review screen
  carries a collapsed "assumed you already have these" section listing
  what was skipped and why, each one tap away from being added back.
  Hiding the exclusions would make a missing-oil week feel like a bug;
  disclosing them makes it a glance.
- **"Running low" is a one-tap action, available any time.** The owner
  noticing an almost-empty bottle is a far better signal than anything
  the app can infer, so make recording it trivial — from the staples
  list, from the review screen, or from a recipe that used it. Flagged
  items join the next basket automatically and clear the flag once
  ordered.
- **A soft depletion nudge as backstop**, not a claim of accuracy. The
  app knows roughly how many planned recipes have drawn on a staple
  since it was last bought, and can prompt — "~30 meals since you last
  bought olive oil, add it?" — with a plainly-a-guess framing. This
  catches the case where the owner forgets to flag it, without
  pretending to know what's in the cupboard.

**Seeding the list without a setup chore.** The owner shouldn't have
to type out forty staples on day one. Seed it from an LLM-generated
sensible default UK pantry at setup, then refine it the same way
ingredient preferences are learned (see above): the first time a
recipe calls for something plausibly-a-staple that isn't on the list,
that's one batched question at basket review — "keep this in
generally, or buy it each time?" — answered once and remembered.

Exclusion happens **before** retailer matching, so staples never reach
the price comparison and can't skew it; the comparison stays
like-for-like across retailers automatically.

## Data model (sketch)

**This is the on-device SQLite schema.** There is no cloud copy — see
"Shape: local-first". Modelled as multi-household/multi-user from the
start (see `decisions.md` and "Multi-user, revisited"), even though v1
runs on a single device for a single household.

- `Household` — id, name, members, and settings: `default_portions`,
  `default_meals_per_week`. These seed each new `WeeklyPlan` and are
  edited on the settings screen.
- `User` — id, household id, display name, auth identity (Cognito
  sub), own preference profile.
- `Recipe` — id, title, `serves` (the portion count these quantities
  are written for), ingredients[with qty+unit], method, source
  (llm-suggested / photo-recipe-card / photo-food-reconstruction /
  manual), tags (cuisine, time, difficulty). Recipes themselves are
  not household-scoped — they're shared, reusable content. Scaled
  re-expressions are cached as variants keyed on
  `(recipe_id, serves)` — see "Portions and recipe scaling" above.
- `WeeklyPlan` — household id, week id, `portions` and `meal_count`
  (seeded from household defaults, overridable per week), and a list
  of `Suggestion` slots, `meal_count` of them. One shared plan per
  household, not one per member.
- `Suggestion` — slot id, current `Recipe`, `filled_via`
  (llm-suggestion / favourite-pick / photo-capture / manual-pick),
  refresh history, status (pending / accepted / dismissed-temporary /
  dismissed-permanent).
- `Dismissal` — household id, user id (who dismissed it, kept for
  attribution and for reason context), recipe id, type
  (temporary/permanent), reason (free text + optional structured
  category), timestamp. Effect is always household-wide — a dismissal
  removes the recipe from the shared plan (temporary: this week only;
  permanent: from all future suggestions) regardless of which member
  triggered it. Permanent dismissals feed back into future suggestion
  prompts for the household as a whole.
- `Favourite` — household id, user id (who favourited it, kept for
  attribution), recipe id, timestamp. Effect is household-wide (any
  member can pick it when filling a slot), and it feeds future
  suggestion prompts as a positive signal — the mirror image of
  `Dismissal`.
- `PreferenceRule` — household id, the rule text (verbatim as
  written), enabled flag, sort order, provenance (derived from a
  dismissal, with the originating recipe id — or added by hand), user
  id, created/updated timestamps. The enabled rules are what the
  suggestion prompt is assembled from, and the list is directly
  editable by the owner — see "The personalised prompt is a visible,
  editable list" above.
- `ShoppingList` — household id, week id, merged ingredient lines
  (name, quantity, unit, source recipes), purchasable-quantity
  rounding applied. Each line also carries how it was resolved
  (from recipe / inferred / standing preference / owner-answered) and
  a confidence flag, so the review screen knows what to highlight.
- `IngredientPreference` — household id, normalised ingredient key
  ("beef mince"), the retailer-neutral resolved spec (variant, grade/
  fat content, preferred pack size, product tier), how it was
  established (asked / inferred / default), and timestamps. Plus an
  optional per-retailer product-ID cache on top of the neutral spec,
  revalidated rather than trusted indefinitely. This is what makes
  "never ask twice" work — see "Ingredient specificity and product
  preferences" above.
- `PantryStaple` — household id, normalised ingredient key (joins to
  `IngredientPreference` on the same key), assumed-in-stock flag,
  quantity threshold above which a recipe's use of it counts as a
  shop rather than a staple, typical purchase pack size,
  running-low flag (owner-set), last-purchased date, and a count of
  planned recipes drawing on it since then to drive the soft
  depletion nudge. See "Pantry staples" above.
- `BasketQuote` — household id, retailer, shopping list id, line-item
  matches, total price, availability/substitution notes, fetched-at
  timestamp. v1 only ever holds one of these per shopping list
  (Sainsbury's); the shape already supports several per list, which is
  what post-v1 price comparison needs.
- `Order` — household id, retailer, basket snapshot, delivery slot
  (recorded by the owner post-handoff), status (quoted → handed-off →
  confirmed, plus abandoned). If full checkout automation is ever
  added for a retailer, this gains the slot-reserved/placed/failed
  states that flow would need — not modelled until then.

Suggestion generation reads every household member's active
preferences and dismissal history and pools them into the prompt
context for that household's single shared plan, rather than
personalising per member.

Dismissals, favourites, preference rules and accepted-recipe history
are the app's accumulating value — losing them means the suggestion
engine forgets everything it has learned. Because they live on the
device, durability is a device-backup problem: Android auto-backup
enabled from iteration 1, plus a manual JSON export/import the owner
controls. See `risks-and-open-questions.md` §10.

## Security posture

Two decisions make the v1 security story unusually strong. The
assisted-handoff posture means **Gusteau holds no card data and no
retailer credentials at all** — payment and retailer login only ever
happen on Sainsbury's own app. Local-first means **there is no cloud
database to breach**: no account holding your eating habits, no bucket
of your food photos, nothing server-side to leak.

That does move the centre of gravity, though — the data now sits on a
phone, so the phone's protections are the data's protections:

- **The device is the trust boundary.** Rely on Android's
  full-disk/file-based encryption, keep the app's database in internal
  app-private storage (never external/shared storage), and gate the
  app behind biometric/PIN. Consider SQLCipher for at-rest encryption
  of the database itself if the owner wants defence beyond the OS
  default.
- **Backups inherit the same duty.** Android auto-backup is encrypted
  in transit and at rest under the user's account; a manual JSON
  export is plaintext by nature, so the export flow should say so
  plainly and leave the owner to put it somewhere sensible.
- **The proxy sees prompts, so keep them out of logs.** Log token
  counts, latency and errors — never prompt or completion bodies.
  Bedrock's own data-retention behaviour is worth confirming during
  the iteration-1 spike, since prompts carry household preferences.

The rules below are standing policy, stated so they survive any future
move toward automation or cloud sync:

- Gusteau **never asks for, stores, or transmits raw card details** —
  hard rule, never revisited under convenience pressure. If checkout
  is ever automated for a retailer, payment rides entirely on the
  payment method already saved on the owner's account with that
  retailer.
- **No retailer credentials in MVP.** If full automation is ever added
  for a retailer, its credentials go in Secrets Manager, readable only
  by the Ordering Service's execution role — and that expansion gets
  its own security review before it ships.
- All traffic TLS; the inference endpoint requires an authenticated
  Cognito identity; local biometric/PIN gate on the app itself.
- Anything money-adjacent (basket handed off, order confirmed) is
  recorded as an auditable local event with who/what/when — not just
  debug output.
- Least-privilege IAM: the proxy Lambda's role can invoke the specific
  Bedrock model ARNs it needs and nothing else. There are no other
  roles, because there are no other resources.
