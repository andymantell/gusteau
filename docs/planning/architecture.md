# Architecture (draft)

This is a first-pass shape, expected to change as open questions get
resolved. Nothing here is built yet.

## High-level components

```
Flutter app (Android)
    │  HTTPS (mTLS/OIDC, see security notes)
    ▼
API layer (API Gateway + Lambda, or ECS Fargate — TBD by iteration 0)
    │
    ├── Recipe Suggestion Service  ── Bedrock (LLM) ── Recipe history store
    ├── Preferences Service        ── DynamoDB (dismissals, reasons, likes)
    ├── Photo Recognition Service  ── Bedrock (multimodal) ── S3 (photos)
    ├── Shopping List Service      ── ingredient normalisation/merge logic
    ├── Price Comparison Service   ── per-retailer adapters
    └── Ordering Service           ── per-retailer adapters ── Secrets Manager
```

Everything sits in the owner's own AWS account, single environment to
start (no separate "prod/staging" split needed for a personal tool,
though CDK will still support it cheaply).

## Client — Flutter (Android)

- Talks only to Gusteau's own backend API — never directly to Bedrock,
  never directly to a supermarket. Keeps all secrets and retailer
  sessions server-side.
- Local device auth (biometric/PIN) gates opening the app, on top of
  backend auth — see `risks-and-open-questions.md` for the auth
  mechanism decision.
- Camera capture for recipe cards / food photos, upload to backend for
  processing (not on-device inference).

## Backend — AWS, CDK (Python)

- CDK app organised as one stack per bounded concern (network/auth,
  data, suggestion, ordering) so pieces can be deployed/rolled back
  independently.
- Compute: **Lambda only** for request/response and event-driven work
  (suggestion generation, ingredient merge, photo processing). The
  assisted-handoff ordering posture (`decisions.md`) means nothing
  needs a long-lived browser session, so there's no Fargate/EC2
  requirement for MVP — see "Cost and frugality" below. If a retailer
  ever moves to full automation later, whether that needs
  container-based compute becomes a fresh cost/benefit call at that
  point, not assumed now.
- Storage:
  - **DynamoDB**, on-demand billing mode, for recipes, weekly plans,
    suggestions, dismissals + favourites, shopping lists, order
    history.
  - **S3** for uploaded photos and any extracted/generated recipe
    images.
  - **Secrets Manager** — not needed at all for MVP under the
    assisted-handoff posture (no retailer credentials to store);
    revisit if/when any retailer moves to full automation.
- **Bedrock** for:
  - Recipe suggestion generation (text) — model choice covered above.
  - Multimodal recipe reconstruction from photos.
- **Cognito** for household/user authenticated identity against the
  API — free at this scale, and avoids hand-rolling auth.
- **CloudWatch** for logging/alerting, especially anything that spends
  money (order handed off) — treat these as audit events, not just
  debug logs. Short log retention (e.g. 2 weeks) to keep storage cost
  negligible.

## Cost and frugality

Budget ceiling: **£15/month**, set by the owner. This is comfortably
achievable for a single-household tool as long as a few well-known AWS
cost traps are avoided by design, not caught after the fact:

- **No NAT Gateway, ever.** This is the single most common way a
  "cheap" serverless app quietly costs £25+/month — a NAT Gateway
  bills per-hour just for existing, regardless of traffic. Lambdas
  here don't need VPC placement at all (Bedrock, DynamoDB, S3,
  Cognito, Secrets Manager are all reached over the AWS SDK without a
  VPC) — so no VPC, no NAT, full stop, unless a future need
  (unlikely) genuinely requires putting a Lambda inside a VPC.
- **No Application Load Balancer.** ALB bills hourly regardless of
  traffic. API Gateway (HTTP API, not the pricier REST API type) is
  pay-per-request with no idle cost and is the right fit here.
- **No EC2, no always-on Fargate/containers.** Lambda's free tier
  (1M requests + 400,000 GB-seconds/month) comfortably covers a
  household of one or two using the app a few times a week — this
  should run at essentially £0 compute cost most months.
- **DynamoDB on-demand, not provisioned capacity** — provisioned mode
  bills for capacity whether it's used or not; on-demand matches this
  app's bursty, low-volume usage pattern and its free tier.
- **No managed vector/search store** (e.g. OpenSearch) — moot anyway
  since there's no external recipe corpus to index (see "Grounding
  data" above), but worth stating as a standing rule: don't introduce
  one later without a real, evaluated need.
- **Bedrock is the one genuinely variable cost** — billed per token.
  Mitigations: no large RAG context to pay to process on every call
  (already true — see "Grounding data"); default to a cheaper/smaller
  model tier and only step up to a more capable one where evaluation
  shows it's actually needed for quality (applies to both suggestion
  generation and photo-to-recipe); keep prompts and photo resolution
  no larger than the task needs.
- **A CloudWatch billing alarm at £15/month is a day-one requirement**
  (iteration 0), not a nice-to-have — it's the backstop that catches
  a design mistake before it becomes a surprise bill.

## LLM strategy

Two genuinely different LLM use cases live in this app, and they don't
need the same treatment. Splitting them out:

### Shared house style: how `method` gets written

Regardless of which capability produces a `Recipe` (suggestion
generation or photo-to-recipe below), the `method` field is written
for a competent home cook, not a beginner — no narrating basic
technique, no padding. It should include whatever actually varies
dish-to-dish and would trip up someone recreating it blind: specific
temperatures/times, ordering that matters, and any step that's easy to
get wrong for *this* dish. This is a fixed instruction in both
prompts, not something either capability decides independently — see
`requirements.md` for the full spec.

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

Given that, the plan for suggestion generation is:

1. **Primary path — prompt engineering on a strong general model**
   (e.g. a Claude model on Bedrock): a system prompt encoding cookery
   expertise, with the household's standing preferences and dismissal
   reasons injected into every request. **No external recipe corpus
   required** — see "Grounding data" below for why, and where a
   retrieval step fits in later without needing one upfront. Fast to
   build, easy to iterate, no training pipeline.
2. **Iteration-1 spike — evaluate a Hugging Face cookery model as a
   supplement**, imported via **Bedrock Custom Model Import** (which
   supports a specific set of open architectures — broadly
   Llama/Mistral/Mixtral-family and a few others; confirm the chosen
   model's architecture is supported before committing). Run it
   side-by-side on the same suggestion prompts as (1) and only keep it
   in the design — e.g. as a specialised sub-step for a narrow task
   like ingredient substitution — if it demonstrably beats prompt+RAG
   on a general model. Time-boxed; not a hard dependency for iteration
   1 to ship. **Scoped to suggestion generation only** — see below for
   why it doesn't apply to the photo feature.
3. **Fine-tuning our own model** stays as a later option, not pursued
   now — for a single-household tool the effort of maintaining a
   training pipeline is hard to justify unless (1) and (2) both prove
   insufficient.

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

## Data model (sketch)

Modelled as multi-household/multi-user from the start (see
`decisions.md`), even though only one household is expected to exist
in practice. Every entity below that isn't global hangs off a
`Household`, not off an implicit single owner.

- `Household` — id, name, members.
- `User` — id, household id, display name, auth identity (Cognito
  sub), own preference profile.
- `Recipe` — id, title, ingredients[with qty+unit], method, source
  (llm-suggested / photo-recipe-card / photo-food-reconstruction /
  manual), tags (cuisine, time, difficulty). Recipes themselves are
  not household-scoped — they're shared, reusable content.
- `WeeklyPlan` — household id, week id, list of `Suggestion` slots (N
  per week). One shared plan per household, not one per member.
- `Suggestion` — slot id, current `Recipe`, `filled_via`
  (llm-suggestion / favourite-pick), refresh history, status
  (pending / accepted / dismissed-temporary / dismissed-permanent).
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
- `ShoppingList` — household id, week id, merged ingredient lines
  (name, quantity, unit, source recipes), purchasable-quantity
  rounding applied.
- `BasketQuote` — household id, retailer, shopping list id, line-item
  matches, total price, availability/substitution notes, fetched-at
  timestamp.
- `Order` — household id, retailer, basket snapshot, delivery slot,
  status (quoted / slot-reserved / placed / failed), audit trail.

Suggestion generation reads every household member's active
preferences and dismissal history and pools them into the prompt/RAG
context for that household's single shared plan, rather than
personalising per member.

## Security posture (headline, detail in open-questions doc)

- Gusteau **never stores raw card details**. Payment rides on whatever
  the retailer already has saved against the owner's account there;
  Gusteau's job is to build the basket and drive checkout up to the
  point the retailer's own (already-tokenised) payment method is used.
- Retailer credentials stored only in Secrets Manager, accessed only
  by the Ordering Service's execution role.
- All traffic TLS; API requires authenticated owner identity; anything
  that places an order or reserves a slot is logged as an auditable,
  money-moving event.
- Least-privilege IAM per Lambda/service — the Recipe Suggestion
  service, for instance, has no access to Secrets Manager at all.
