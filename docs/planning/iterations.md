# Iterations (build order)

Each iteration leaves the owner with something usable on their own
phone. The planning decisions shaping this order are in
`decisions.md`. The one big sizing unknown left is iteration 5 —
retailer product/price data access (`risks-and-open-questions.md` §9)
— which has a feasibility spike scheduled ahead of it and does not
block anything before it.

## Iteration 0 — Foundations
- CDK app skeleton (Python), bootstrapped in the owner's AWS account.
- Auth: Cognito user pool, with `Household`/`User` modelled from the
  start (see `architecture.md`) even though only one household and
  one or two users will exist in practice.
- API Gateway (HTTP API) + a "hello world" Lambda, deployed via CDK.
  No VPC — Lambdas call AWS services directly, no NAT Gateway or ALB
  anywhere in the design. DynamoDB table(s) created on-demand billing.
  See `architecture.md`, "Cost and frugality."
- Flutter app skeleton: login against Cognito, one screen calling the
  API.
- CI: lint/test for both CDK (Python) and Flutter, deploy pipeline
  (manual trigger is fine for a personal project).
- CloudWatch billing alarm at **£15/month** (see `decisions.md`).
- **Outcome:** empty app that authenticates and talks to a real
  backend, on infrastructure that costs close to £0 at this usage
  level.

## Iteration 1 — Recipe suggestions (core loop)
- **Step zero, before building the service:** a small manual prompt
  spike against candidate Bedrock models — confirms a generic model
  is actually good at recipe generation without fine-tuning/RAG, and
  picks the cheapest model tier that's good enough (see
  `architecture.md`, "Recipe suggestion generation").
- Same spike, extended: evaluate a Hugging Face cookery model via
  Bedrock Custom Model Import against the same prompts; keep only if
  it demonstrably wins (see `decisions.md`). Scoped to suggestion
  generation only, not photo-to-recipe (iteration 3).
- Bedrock integration for recipe suggestion generation (general model,
  cookery-focused prompting, no external corpus — see
  `architecture.md`).
- `Household` / `User` / `WeeklyPlan` / `Suggestion` / `Recipe` data
  model in DynamoDB.
- "Suggest N recipes for the week" + per-suggestion refresh.
- Flutter: weekly plan screen, refresh button per slot.
- **Outcome:** owner gets a real week of suggestions and can refresh
  individual ones.

## Iteration 2 — Preferences: favourites and dismissals
- Temporary vs. permanent dismissal, reason capture UI.
- Favouriting a recipe (household-wide, works on any `Recipe`
  regardless of source).
- Slot refresh gains a second source: fill from favourites instead of
  asking the LLM, so a week can be planned as a mix of both — see
  `architecture.md`.
- Dismissal reasons (negative) and favourites (positive) both fed back
  into the suggestion prompt context; when the LLM fills remaining
  slots it's given the recipes already sitting in the other slots for
  that week.
- **Outcome:** suggestions visibly improve/avoid known dislikes over
  time, and the owner can build a week around known favourites instead
  of always starting from a blank LLM suggestion.

## Iteration 3 — Photo-to-recipe
- Photo capture (recipe card and food) → S3 → Bedrock multimodal call
  → structured `Recipe`. Simple, general-purpose prompt — no cookery
  specialisation, preference grounding, or RAG needed (see
  `architecture.md`), so this doesn't depend on iteration 1's LLM
  spike.
- Slot into the weekly plan alongside LLM-suggested recipes.
- **Outcome:** owner can photograph something and get a usable recipe
  back, added to their week.

## Iteration 4 — Shopping list generation
- Ingredient normalisation and cross-recipe merging for a week's plan.
- Purchasable-quantity rounding.
- Flutter: shopping list screen.
- **Outcome:** one clean shopping list per week instead of per-recipe
  lists.

## Iteration 5 — Price comparison *(highest-risk iteration — gated on a spike)*
- **Gate: the product/price data feasibility spike from
  `risks-and-open-questions.md` §9 runs first** (it can start any time
  from iteration 4 onwards) — it decides per retailer whether data
  comes from an aggregator API, an unofficial API, scraping, or not at
  all, and therefore what this iteration actually builds.
- Retailer adapters (read-only): match shopping list items to
  retailer catalog/products, compute basket totals, for whichever of
  Tesco, Sainsbury's, Asda, and Waitrose the spike shows are viable.
- Spike (part of the same investigation): Amazon.co.uk's grocery
  partnerships (Morrisons/Co-op/Iceland + Amazon's own range) as a
  fifth channel; add an adapter if it stacks up, otherwise note why
  not and move on.
- Flutter: side-by-side basket comparison, owner picks one. Degraded
  modes (fewer retailers, cached or clearly-labelled estimated
  prices) are acceptable outcomes — see §9.
- **Outcome:** owner sees comparative pricing before committing — as
  real as retailer data access allows.

## Iteration 6 — Slot reservation and order placement (assisted)
- Assisted handoff per the phased posture decided in
  `decisions.md`: Gusteau prepares the chosen retailer's basket
  contents and hands off for the owner to reserve the slot and pay
  themselves on the retailer's own app/site. Expectation check: UK
  retailer apps generally can't be deep-linked into a pre-filled
  basket, so the realistic baseline is a fast, well-ordered checklist
  (grouped to match the retailer's search, one-tap copy per item)
  used alongside the retailer's app — with per-retailer deep-linking
  investigated as an enhancement, not assumed.
- Order/basket state tracked in Gusteau (`Order` status: quoted →
  handed-off → confirmed) so history is still useful even without full
  automation.
- Security hardening pass end-to-end (see `risks-and-open-questions.md`
  §5) before this iteration is considered done — no card data or
  retailer credentials touch Gusteau at this stage.
- **Outcome:** owner can go from "here's my week" to "basket ready to
  pay for" with one handoff step; full automation for specific
  retailers is a later, separately-scoped iteration if pursued.

## Iteration 7+ — Backlog
Pull from the "not yet specified" list in `requirements.md` as it
firms up: nutrition tracking, pantry-staple handling, meal-repeat
rules, notifications, budget alerts, iOS, etc. Re-prioritise after
iteration 6 based on what the owner actually wants next once the core
loop is live.
