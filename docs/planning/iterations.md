# Iterations (draft build order)

Draft only — sizing and even ordering may change once the open
questions are resolved, especially the ordering-automation posture,
which determines how big iterations 5/6 really are. Each iteration is
meant to leave the owner with something usable on their own phone.

## Iteration 0 — Foundations
- CDK app skeleton (Python), bootstrapped in the owner's AWS account.
- Auth: Cognito user pool with a single owner account.
- API Gateway + a "hello world" Lambda, deployed via CDK.
- Flutter app skeleton: login against Cognito, one screen calling the
  API.
- CI: lint/test for both CDK (Python) and Flutter, deploy pipeline
  (manual trigger is fine for a personal project).
- CloudWatch billing alarm.
- **Outcome:** empty app that authenticates and talks to a real
  backend.

## Iteration 1 — Recipe suggestions (core loop)
- Bedrock integration for recipe suggestion generation.
- `WeeklyPlan` / `Suggestion` / `Recipe` data model in DynamoDB.
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
  → structured `Recipe`.
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
  retailer catalog/products, compute basket totals.
- Number/choice of retailers depends on open question 2.
- Flutter: side-by-side basket comparison, owner picks one.
- **Outcome:** owner sees real comparative pricing before committing.

## Iteration 6 — Slot reservation and order placement
- Depends heavily on the automation posture decided in open question 1
  (assisted handoff vs. fully automated vs. phased).
- Secrets Manager wiring for any retailer credentials in scope.
- Delivery slot reservation, order placement, audit logging of the
  money-moving steps.
- Security hardening pass end-to-end (see `risks-and-open-questions.md`
  §1 and §5) before this iteration is considered done.
- **Outcome:** owner can go from "here's my week" to "order placed"
  without leaving the flow (fully or mostly, depending on posture).

## Iteration 7+ — Backlog
Pull from the "not yet specified" list in `requirements.md` as it
firms up: nutrition tracking, pantry-staple handling, meal-repeat
rules, notifications, budget alerts, iOS, etc. Re-prioritise after
iteration 6 based on what the owner actually wants next once the core
loop is live.
