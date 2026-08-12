# Requirements

Captured from the initial brief on 2026-08-12 and updated as planning
decisions land. It will grow as the owner thinks of more. What's in
scope for MVP versus later is expressed by the build order in
`iterations.md` (iterations 0–6 are the MVP; the backlog section is
"later") rather than by per-item tags here.

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
  - Both kinds of dismissal apply to the whole household, not just
    the member who dismissed it — see `decisions.md`. Who dismissed
    it and why is still recorded.
- Any good recipe can be **saved as a favourite**, regardless of where
  it came from (LLM suggestion, photo-to-recipe, or manual entry).
  Favouriting applies household-wide, mirroring dismissal.
- When planning a week, the owner can **fill some of the N slots from
  favourites** directly instead of an LLM suggestion, and have the LLM
  **fill the remaining slots** — aware of which favourites have
  already been picked for that week, so it can plan the rest around
  them (variety, and ideally shared ingredients) rather than
  suggesting blind. See `decisions.md` for how this fits the existing
  refresh mechanic rather than being a separate planning mode.

## Recipe content

- Every `Recipe` — LLM-suggested, photo-derived, or manual — includes
  **method steps sufficient to actually recreate the dish**, not just
  a title and ingredient list.
- Written for **someone who already knows how to cook**: no explaining
  basic technique ("dice the onion", "bring to the boil" needs no
  further comment), no padding, no hand-holding tone. What it must
  include is whatever actually varies dish-to-dish and would trip up
  a competent cook guessing blind — specific temperatures and times,
  ordering that matters, and any technique or step that's easy to
  get wrong or skip for *this* dish (e.g. resting the meat, reducing a
  sauce to a specific consistency, when to deglaze). Terse and
  information-dense over narrated and long.
- Ingredients are specified **precisely enough to buy**, not just to
  cook: "500g beef mince, 12% fat", not "mince". The model knows what
  the dish wants, so making it say so up front removes most shopping
  ambiguity before it exists.
- Both rules apply uniformly regardless of source, so they're shared
  "house style" instructions in both the suggestion-generation prompt
  and the photo-to-recipe extraction prompt — see `architecture.md`.

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
- **Resolve ambiguous ingredients without nagging.** "Mince" has to
  become a specific, orderable product (which meat, what fat content,
  which product tier). The app resolves this by generating precise
  ingredients in the first place, inferring from dish context where a
  photographed recipe is vague, and applying standing household
  preferences — **asking only when a choice is genuinely new and
  consequential, and remembering the answer permanently.** Questions
  are batched into the basket-review step, never interrupting meal
  planning. See `architecture.md`, "Ingredient specificity and product
  preferences."
- Every basket line is shown resolved to a real product with a
  sensible default, with **guessed lines visually flagged** so
  correcting one is easy but never mandatory.

## Pantry staples

- **Don't reorder things already in the cupboard.** Olive oil, salt,
  spices, flour, condiments and similar are marked as household
  staples and excluded from the weekly basket by default.
- **Threshold-aware, not blunt:** "2 tbsp olive oil" is skipped, but a
  recipe wanting 500ml is ordered. Same for butter, flour, and
  anything else that's a staple in small amounts and a shop in large
  ones.
- **Excluded items are disclosed, not hidden** — the basket review
  shows an "assumed you already have these" section, each item one tap
  from being added back.
- **One-tap "running low"** on any staple, available whenever the
  owner notices, adds it to the next basket. The owner is a better
  stock sensor than any estimate.
- **Soft depletion nudge** as a backstop ("~30 meals since you last
  bought olive oil"), framed plainly as a guess.
- **No full inventory tracking** — deliberately rejected as too much
  logging burden for a personal tool; see `decisions.md`.
- Staples list is **seeded automatically** from a sensible default
  pantry at setup and refined by the same ask-once-remember-forever
  mechanic as ingredient preferences — no forty-item setup chore.

## Ordering

**v1 is Sainsbury's only, with no price comparison** — see
`decisions.md`. Multi-retailer comparison is a post-v1 enhancement.

- Turn the week's shopping list into a **Sainsbury's basket**, matched
  to real products where retailer data allows, with a checklist floor
  that works even if it doesn't (see `risks-and-open-questions.md`
  §9).
- **Reserve a delivery slot and complete the order** as an assisted
  handoff: Gusteau prepares the basket, the owner does the final
  pay/confirm on Sainsbury's own app/site. Fully automated checkout
  stays a possible later step, not assumed. See `decisions.md` and
  `risks-and-open-questions.md` §1.

### Deferred to post-v1

- Compare **total basket price across several supermarkets** (Tesco,
  Asda, Waitrose, plus the Amazon.co.uk grocery-partnership channel),
  with the owner choosing which to order from.
- Comparison must be **like-for-like** — the same product tier at each
  retailer, not one's value range against another's premium. Where a
  retailer has no equivalent, say so rather than silently
  substituting. (The retailer-neutral preference storage this needs is
  already being built in v1.)

## Household / multi-user

- Data model and auth are built as multi-household/multi-user from
  the start, not hard-coded to a single owner — see `decisions.md`.
  In practice this will likely only ever run for one household.
- No public sign-up flow; this stays a personal tool.
- One shared weekly plan per household; dismissals (temporary or
  permanent) apply household-wide — see `decisions.md`.

## Security

- Called out explicitly as a top priority because a real debit card
  and real supermarket accounts are involved.
- Under the assisted-handoff posture, MVP Gusteau holds **no card data
  and no retailer credentials at all** — payment and retailer login
  only ever happen on the retailer's own app/site. Standing hard
  rules (never store card data; credentials only ever in a managed
  secret store, and only if automation is ever added; biometric gate;
  least-privilege IAM; audit logging of money-adjacent events) are
  specified in `architecture.md`, "Security posture."

## Not yet specified (owner to flesh out over time)

- Nutrition tracking / dietary constraints (allergies, macros, calories).
- Portion counts / household size per meal.
- Meal history / repeats — how often the same recipe is allowed to
  reappear.
- Notifications (e.g. "your basket is ready to review", "slot booked").
- What happens if a chosen delivery slot disappears mid-checkout.
- Budget cap / spend alerts.
- iOS, at some point ("Android app" only for now).
