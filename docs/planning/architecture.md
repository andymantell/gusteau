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
    ├── Recipe Suggestion Service  ── Bedrock (LLM) ── Recipe/RAG store
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
- Compute: Lambda for request/response and event-driven work
  (suggestion generation, ingredient merge); anything that needs a
  long-lived browser session for retailer checkout will need a
  container-based option (Fargate task) instead of Lambda — depends on
  the ordering-automation decision.
- Storage:
  - **DynamoDB** for recipes, weekly plans, suggestions, dismissals +
    reasons, shopping lists, order history.
  - **S3** for uploaded photos and any extracted/generated recipe
    images.
  - **Secrets Manager** for retailer credentials/tokens — never in
    DynamoDB, never in the app.
- **Bedrock** for:
  - Recipe suggestion generation (text) — model choice covered in
    open questions.
  - Multimodal recipe reconstruction from photos.
- **Cognito** (or similar) for the single owner's authenticated
  identity against the API — even single-user apps benefit from not
  hand-rolling auth.
- **CloudWatch** for logging/alerting, especially anything that spends
  money (order placed, payment attempted) — treat these as audit
  events, not just debug logs.

## LLM strategy — "specialist cookery LLM"

Bedrock does not offer an off-the-shelf "cookery" foundation model, so
"specialist" needs to be built rather than picked off a shelf. During
planning we looked specifically at Hugging Face for existing
cookery-specialised models, per the owner's request. What's actually
out there:

- Small, narrowly fine-tuned recipe generators — e.g. a BLOOM-560M
  fine-tune aimed at diabetic-friendly recipes, a TinyLlama fine-tune
  on ~10K Indian recipes ("CookGPT"), and encoder-only models like
  RecipeBERT (trained on Recipe1M+, good for embeddings/retrieval, not
  generation).
- All of these are **text-only** and trained on a narrow slice of
  cuisine or use case. None handle the photo-to-recipe requirement
  (recipe card or plate of food → recipe), which needs a genuinely
  multimodal model. None are an obvious drop-in replacement for a
  frontier general model on quality of open-ended recipe reasoning
  (substitutions, working from a fuzzy owner preference like "too
  spicy", inferring a dish from a photo).

Given that, the plan is:

1. **Primary path — prompt engineering + retrieval (RAG) on a strong
   general multimodal model** (e.g. a Claude model on Bedrock): a
   system prompt encoding cookery expertise and the household's
   standing preferences/dismissal reasons, grounded in a curated
   recipe corpus via retrieval, using the same model for the
   photo-to-recipe feature since it needs vision anyway. Fast to
   build, easy to iterate, no training pipeline, one model to run.
2. **Iteration-1 spike — evaluate a Hugging Face cookery model as a
   supplement**, imported via **Bedrock Custom Model Import** (which
   supports a specific set of open architectures — broadly
   Llama/Mistral/Mixtral-family and a few others; confirm the chosen
   model's architecture is supported before committing). Run it
   side-by-side on the same suggestion prompts as (1) and only keep it
   in the design — e.g. as a specialised sub-step for a narrow task
   like ingredient substitution — if it demonstrably beats prompt+RAG
   on a general model. Time-boxed; not a hard dependency for iteration
   1 to ship.
3. **Fine-tuning our own model** stays as a later option, not pursued
   now — for a single-household tool the effort of maintaining a
   training pipeline is hard to justify unless (1) and (2) both prove
   insufficient.

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
  per week). **Working assumption:** one shared plan per household,
  not one per member — flagged as an open question in
  `risks-and-open-questions.md` §4 to confirm.
- `Suggestion` — slot id, current `Recipe`, refresh history, status
  (pending / accepted / dismissed-temporary / dismissed-permanent).
- `Dismissal` — household id, user id (who dismissed it), recipe id,
  type (temporary/permanent), scope (this member only / whole
  household — see open question), reason (free text + optional
  structured category), timestamp. Permanent dismissals feed back into
  future suggestion prompts for whichever scope applies.
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
context for that household's plan, rather than personalising per
member — consistent with the single-shared-plan assumption above.

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
