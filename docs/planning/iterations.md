# Iterations (build order)

Each iteration leaves the owner with something usable on their own
phone. The planning decisions shaping this order are in
`decisions.md`.

**v1 ends at a textual shopping list** (iteration 5) — no price
comparison and no retailer integration, so it depends on nothing
outside our control. Sainsbury's basket integration is iteration 6,
deliberately after the core concept has proved itself in real use.

## Iteration 0 — Foundations
- Flutter app skeleton with the **local SQLite layer** (Drift or
  equivalent) and migration tooling — this is the system of record, so
  it gets set up properly on day one.
- **Android Auto Backup, configured properly** — explicit
  `dataExtractionRules`/`fullBackupContent`, a `BackupAgent` that
  checkpoints the SQLite WAL before backup, `-wal`/`-shm` excluded,
  photos excluded from the 25MB quota. Then an **actual
  install-and-restore test on a clean device** to prove it works, not
  assume it (see `architecture.md`, "Backup and durability").
- CDK app skeleton (Python): API Gateway HTTP API with an API key and
  usage plan, plus the **inference proxy Lambda** — no VPC, no NAT, no
  ALB, no data stores, no Cognito. See `architecture.md`.
- App stores its API key in the Android Keystore, calls the proxy and
  gets a round-trip response back.
- CI: lint/test for both Flutter and CDK (Python); manual-trigger
  deploy is fine for a personal project.
- CloudWatch billing alarm at **£15/month**, plus the proxy's own rate
  limit and spend guard (see `decisions.md`).
- **Outcome:** an app with a real local database that can reach
  Bedrock through an authenticated proxy, on infrastructure costing
  close to £0.

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
- `Settings` / `WeeklyPlan` / `Suggestion` / `Recipe` in the local
  schema, including default portions and meals per week, and the
  per-week overrides of both.
- On-device prompt assembly; the proxy relays it to Bedrock.
- "Suggest N recipes for the week" + per-suggestion refresh, with the
  week's portion count fed into the generation prompt so recipes come
  back at the right quantities (see `architecture.md`, "Portions and
  recipe scaling").
- Flutter: settings screen (default portions, default meals per week);
  weekly plan screen with both overridable for the week being planned,
  pre-filled from defaults, and a refresh button per slot.
- **Outcome:** owner gets a real week of suggestions and can refresh
  individual ones.

## Iteration 2 — Preferences: favourites, dismissals, editable prompt
- Temporary vs. permanent dismissal, reason capture UI.
- Favouriting a recipe (works on any `Recipe` regardless of source),
  stored locally.
- **`PreferenceRule` list and its screen** — the personalised prompt
  as an editable list rather than a hidden blob: rules created
  visibly from permanent dismissals, hand-addable, each one editable /
  disableable / reorderable / deletable, with a "see the full
  assembled prompt" view. Dismissed recipes get their own reviewable
  list so a block can be lifted independently of its rule. See
  `architecture.md`.
- Slot refresh gains a second source: fill from favourites instead of
  asking the LLM, so a week can be planned as a mix of both — see
  `architecture.md`.
- Rescaling: a favourite picked for a week whose portion count differs
  from the recipe's `serves` is re-expressed via one LLM call and
  cached as a variant, so it's free on every later reuse.
- Dismissal reasons (negative) and favourites (positive) both fed back
  into the suggestion prompt context; when the LLM fills remaining
  slots it's given the recipes already sitting in the other slots for
  that week.
- **Outcome:** suggestions visibly improve/avoid known dislikes over
  time, and the owner can build a week around known favourites instead
  of always starting from a blank LLM suggestion.

## Iteration 3 — Photo-to-recipe
- Photo capture (recipe card and food), resized and compressed
  on-device, sent through the proxy to Bedrock → structured `Recipe`
  stored locally. **Photos stay on the device** — no S3. Simple,
  general-purpose prompt — no cookery specialisation or preference
  grounding needed (see `architecture.md`), so this doesn't depend on
  iteration 1's LLM spike.
- Photos written to a backup-excluded directory (the 25MB Auto Backup
  quota won't take them), with the UI saying plainly that a restored
  install keeps the recipes but not the original snapshots.
- Slot into the weekly plan alongside LLM-suggested recipes.
- **Outcome:** owner can photograph something and get a usable recipe
  back, added to their week.

## Iteration 4 — Shopping list generation
All on-device — this iteration adds no AWS resources.

- Ingredient normalisation and cross-recipe merging for a week's plan.
- Purchasable-quantity rounding, applied to merged totals so three
  recipes needing 300g between them don't order three packs.
- `IngredientPreference` store plus the ask-once-remember-forever
  flow: resolve from the recipe, infer from dish context, apply
  standing preferences, and ask only for novel consequential choices —
  batched into the review screen (see `architecture.md`, "Ingredient
  specificity and product preferences").
- `PantryStaple` store and staple exclusion: LLM-seeded default pantry
  at setup, quantity thresholds so small usages are skipped but bulk
  ones ordered, one-tap "running low", and the soft depletion nudge
  (see `architecture.md`, "Pantry staples"). Exclusion runs before
  retailer matching.
- Flutter: shopping list / basket review screen — every line resolved
  with a default, guessed lines flagged and one-tap correctable, plus
  a collapsed "assumed you already have these" section for skipped
  staples. Editable list screens for `IngredientPreference` and
  `PantryStaple`, per the no-hidden-learned-state principle.
- JSON export/import of the local database — the escape hatch for
  Google-account loss and data portability, now that Auto Backup
  carries the main durability load (`risks-and-open-questions.md` §10).
- **Outcome:** one clean shopping list per week instead of per-recipe
  lists; the app stops asking about mince after the first time, and
  stops trying to sell you olive oil you already have.

## Iteration 5 — Textual shopping list and handoff (completes v1)
Deliberately the simple version: **no retailer integration at all**,
so v1 carries zero dependency on Sainsbury's internals and the core
concept gets to prove itself first.

- A well-ordered, grouped shopping checklist — ordered to match how
  you actually shop, one-tap copy per line — used alongside the
  Sainsbury's app.
- Order state tracked in Gusteau (`Order`: prepared → handed-off →
  confirmed, plus abandoned), so history is useful from day one.
- Security pass end-to-end before this is done (see
  `risks-and-open-questions.md` §5) — no card data, no retailer
  credentials, nothing to review beyond the app itself.
- **Outcome:** the complete loop, on foot — suggestions → week plan →
  shopping list → shop → order placed by you. **This is v1**, and it
  is fully usable indefinitely if the integration below never happens.

## Iteration 6 — Sainsbury's basket integration (first post-v1 target)
Only once the base concept is stable and in real weekly use. Design is
worked out in `architecture.md`, "Sainsbury's integration".

- **Spike first** (`risks-and-open-questions.md` §9): confirm the
  `open-supermarkets`-documented endpoints still behave, from a Dart
  client on a residential connection.
- WebView login against Sainsbury's own page — the owner types their
  password into Sainsbury's form, the app keeps only the session
  cookies. No stored password.
- Dart HTTP client against `groceries-api/gol-services`: resolve
  shopping-list lines to real products, fill the real trolley, show
  real prices and a running total.
- Hand off in the WebView at the trolley page for slot choice and
  payment.
- **Keep the iteration-5 checklist as a permanent fallback** — this is
  an unofficial API and will break sooner or later.
- Thin seam at the adapter boundary so a second retailer is an
  addition, not a refactor — a seam, not a plugin framework.
- **Outcome:** the basket is genuinely filled at Sainsbury's before
  you take over; you pick a slot and pay.

## Post-v1 backlog
Re-prioritise once the core loop is live and actually being used
weekly. Known candidates, roughly in the order they seem worth doing:

- **Price comparison across retailers** (deferred from v1 — see
  `decisions.md`): add Tesco, Asda, Waitrose adapters plus the
  Amazon.co.uk grocery-partnership channel spike, side-by-side basket
  totals, owner picks. `open-supermarkets` also covers Tesco and Ocado,
  so the same source is a head start here. Requires like-for-like
  matching (already designed for: see `architecture.md`, "Ingredient
  specificity and product preferences").
- **Fully automated checkout** for a specific retailer, if ever wanted
  — separately scoped, with its own security review (`decisions.md`).
- From the "not yet specified" list in `requirements.md`: nutrition
  and dietary constraints, portion counts, meal-repeat rules,
  notifications, budget alerts, delivery-slot-disappears handling,
  iOS.
