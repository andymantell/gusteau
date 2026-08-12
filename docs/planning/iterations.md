# Iterations (draft build order)

Draft only — sizing and even ordering may change once the open
questions are resolved, especially the ordering-automation posture,
which determines how big iterations 5/6 really are. Each iteration is
meant to leave the owner with something usable on their own phone.

## Iteration 0 — Foundations
- CDK app skeleton (Python), bootstrapped in the owner's AWS account.
- Auth: Cognito user pool, with `Household`/`User` modelled from the
  start (see `architecture.md`) even though only one household and
  one or two users will exist in practice.
- API Gateway + a "hello world" Lambda, deployed via CDK.
- Flutter app skeleton: login against Cognito, one screen calling the
  API.
- CI: lint/test for both CDK (Python) and Flutter, deploy pipeline
  (manual trigger is fine for a personal project).
- CloudWatch billing alarm.
- **Outcome:** empty app that authenticates and talks to a real
  backend.

## Iteration 1 — Recipe suggestions (core loop)
- Bedrock integration for recipe suggestion generation (general model,
  prompt + RAG — see `architecture.md`).
- Time-boxed spike: evaluate a Hugging Face cookery model via Bedrock
  Custom Model Import against the same prompts; keep only if it
  demonstrably wins (see `decisions.md`). Scoped to suggestion
  generation only, not photo-to-recipe (iteration 3).
- `Household` / `User` / `WeeklyPlan` / `Suggestion` / `Recipe` data
  model in DynamoDB.
- "Suggest N recipes for the week" + per-suggestion refresh.
- Flutter: weekly plan screen, refresh button per slot.
- **Outcome:** owner gets a real week of suggestions and can refresh
  individual ones.

## Iteration 2 — Preferences and dismissal memory
- Temporary vs. permanent dismissal, reason capture UI.
- Dismissal reasons fed back into the suggestion prompt/RAG context.
- **Outcome:** suggestions visibly improve/avoid known dislikes over
  time.

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

## Iteration 5 — Price comparison
- Retailer adapters (read-only): match shopping list items to
  retailer catalog/products, compute basket totals, for Tesco,
  Sainsbury's, Asda, and Waitrose.
- Spike: check feasibility of Amazon.co.uk's grocery partnerships
  (Morrisons/Co-op/Iceland + Amazon's own range) as a fifth channel;
  add an adapter if it stacks up, otherwise note why not and move on.
- Flutter: side-by-side basket comparison, owner picks one.
- **Outcome:** owner sees real comparative pricing before committing.

## Iteration 6 — Slot reservation and order placement (assisted)
- Assisted handoff per the phased posture decided in
  `decisions.md`: Gusteau prepares the chosen retailer's basket
  contents and hands off (deep link and/or a clear checklist) for the
  owner to reserve the slot and pay themselves on the retailer's own
  app/site.
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
