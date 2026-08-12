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

Bedrock does not offer an off-the-shelf "cookery" foundation model,
so "specialist" needs to be built rather than picked off a shelf.
Realistic options, roughly in order of effort:

1. **Prompt engineering + retrieval (RAG)** on a strong general model
   (e.g. a Claude model on Bedrock): ship a system prompt encoding
   cookery expertise and the owner's standing preferences/dismissal
   reasons, and ground suggestions in a curated recipe corpus /
   nutrition data via retrieval. Fast to build, easy to iterate, no
   training pipeline to maintain.
2. **Fine-tuning** a Bedrock-supported base model on a recipe dataset.
   Higher effort, ongoing retraining cost, and for a single-user tool
   the marginal quality gain over (1) + good retrieval is likely small.
3. A hybrid: start with (1), revisit (2) only if evaluation shows
   prompt+RAG genuinely plateaus.

Default recommendation is to start with (1) and treat "specialist" as
"general-purpose model + cookery-specific prompting/grounding/tools,"
not a bespoke model. Flagged as an open question to confirm.

## Data model (sketch)

- `Recipe` — id, title, ingredients[with qty+unit], method, source
  (llm-suggested / photo-recipe-card / photo-food-reconstruction /
  manual), tags (cuisine, time, difficulty).
- `WeeklyPlan` — week id, list of `Suggestion` slots (N per week).
- `Suggestion` — slot id, current `Recipe`, refresh history, status
  (pending / accepted / dismissed-temporary / dismissed-permanent).
- `Dismissal` — recipe id, type (temporary/permanent), reason (free
  text + optional structured category), timestamp — permanent ones
  feed back into future suggestion prompts.
- `ShoppingList` — week id, merged ingredient lines (name, quantity,
  unit, source recipes), purchasable-quantity rounding applied.
- `BasketQuote` — retailer, shopping list id, line-item matches, total
  price, availability/substitution notes, fetched-at timestamp.
- `Order` — retailer, basket snapshot, delivery slot, status
  (quoted / slot-reserved / placed / failed), audit trail.

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
