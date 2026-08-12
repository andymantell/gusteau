# Requirements

Captured from the initial brief on 2026-08-12. This is the raw feature
list, lightly organised. It will grow as the owner thinks of more.
Each item is tagged `[MVP]`, `[later]`, or `[open]` (needs a decision
before it can be tagged either way) — tags will be filled in once the
open questions in `risks-and-open-questions.md` are resolved.

## Platform / stack (given, not negotiable)

- Backend infrastructure defined as code with **AWS CDK, Python**.
- Client is a **Flutter** app, **Android** only for now.
- Recipe/ingredient intelligence runs on **AWS Bedrock**.

## Recipe suggestions

- Suggest **N recipes per week** (N configurable).
- Each suggestion can be **refreshed** independently — swap just that
  one recipe for a different suggestion — repeatable until the owner
  is happy with the week's line-up.
- Dismissing a suggestion has two modes:
  - **Temporary** — not this week, but it can come back in a future week.
  - **Permanent** — never suggest this again, and **record a reason**
    (e.g. "too spicy", "don't like okra", "takes too long on a
    weeknight"). Reasons are structured/stored so they can be fed back
    into future LLM prompts as standing preferences, not just used to
    filter a blocklist.

## Recipe capture from a photo

- Photograph a **recipe card** (or any written recipe) → LLM extracts
  a structured recipe (ingredients + method).
- Photograph **a plate of food** → LLM does its best to infer a recipe
  that would recreate it.
- Both flows produce the same structured recipe object the rest of the
  system uses, so a photo-derived recipe can be added to the week just
  like an LLM-suggested one.

## Shopping list generation

- Recognise ingredients that are **shared across multiple recipes** in
  the week and combine them into a single line with a summed quantity,
  rather than ordering the same ingredient several times.
- Produce sensible **purchasable quantities** (e.g. round up to pack
  sizes actually sold), not just raw recipe quantities.

## Ordering

- Compare the **total basket price** for the week's shopping list
  across **several supermarkets**.
- Owner **chooses** which supermarket to order from (not fully
  automatic choice).
- **Reserve a delivery slot.**
- **Complete the order** end-to-end.

## Security

- Called out explicitly as a top priority because a real debit card
  and real supermarket accounts are involved. Concrete requirements
  are being worked out in `risks-and-open-questions.md` and will land
  here once agreed — expect items like: no raw card data ever stored
  by Gusteau, retailer credentials in a managed secret store, app-level
  auth/biometric gate, encrypted transport and storage, least-privilege
  IAM, audit logging of anything that spends money.

## Not yet specified (owner to flesh out over time)

- Nutrition tracking / dietary constraints (allergies, macros, calories).
- Portion counts / household size per meal.
- Handling of pantry staples already owned (don't reorder olive oil
  every week).
- Meal history / repeats — how often the same recipe is allowed to
  reappear.
- Notifications (e.g. "your basket is ready to review", "slot booked").
- What happens if a chosen delivery slot disappears mid-checkout.
- Budget cap / spend alerts.
- iOS, at some point ("Android app" only for now).
