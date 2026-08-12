# Gusteau — Planning

Gusteau is a personal meal-planning and grocery-ordering Android app,
replacing Gousto/HelloFresh-style subscription boxes with a system that:

- suggests recipes each week using a Bedrock-hosted LLM,
- learns from what gets favourited, dismissed, and why — as a list of
  rules you can read and edit, not a hidden blob,
- can reconstruct a recipe from a photo (recipe card or a plate of food),
- consolidates ingredients across the week into a shopping list, skipping
  what's already in the cupboard, and
- turns that into a supermarket basket ready for the owner to pay for.

It is **local-first**: the phone holds the database and does the work,
and AWS is called only for what a phone can't do — LLM inference.
There is no cloud copy of your recipes, preferences, or photos.

Comparing basket prices across several supermarkets is a post-v1
enhancement — v1 goes end-to-end against Sainsbury's alone.

This directory is the living plan. Nothing here is implemented until the
plan is marked ready and the owner says go — see [status](#status) below.

## Documents

| Doc | Purpose |
|---|---|
| [`requirements.md`](./requirements.md) | Feature list as agreed so far, v1 scope and deferred items |
| [`architecture.md`](./architecture.md) | System design: Flutter app, AWS/CDK backend, Bedrock LLM, data model |
| [`risks-and-open-questions.md`](./risks-and-open-questions.md) | Open risks and resolved questions, especially around retailer data access and payment security |
| [`iterations.md`](./iterations.md) | Build order, broken into iterations, each independently shippable to the owner's own phone |
| [`decisions.md`](./decisions.md) | Log of decisions made during planning, once resolved (ADR-style) |

## Status

**Planning — scoped, no blocking unknowns.** All the originally-open
decisions are resolved (see `decisions.md`: assisted-first ordering,
LLM strategy with an upfront validation spike, no recipe corpus,
multi-household data model, household-wide dismissals and favourites,
£15/month Lambda-first budget, ingredient disambiguation, pantry
staples).

**v1 is Sainsbury's only, with no price comparison** — deliberately
scoped down so the whole loop lands end-to-end on one retailer first.
That demoted the plan's biggest risk (retailer product/price data
access, `risks-and-open-questions.md` §9) from project-threatening to
a feature-quality question with an acceptable fallback. Multi-retailer
comparison is the first post-v1 enhancement.

Nothing gets built until the owner says go.

## Ground rules for this plan

- **Local-first.** The device stores the data and does the computing;
  AWS earns its place only where the device genuinely can't do the job.
- Personal use — no public sign-up. The schema is multi-household, but
  v1 is one household on one device.
- **No hidden learned state.** Anything the app infers about the owner
  is visible and editable, including the LLM prompt itself.
- Security is a first-class requirement, not a later pass, because a
  real debit card and real supermarket accounts are involved.
- Every iteration should end with something the owner can actually use
  on their phone, even if later iterations replace parts of it.
- Prefer boring, inspectable technology over cleverness, given this is
  built and operated by one person.
