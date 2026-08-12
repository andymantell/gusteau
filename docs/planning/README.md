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
There is no cloud copy of your recipes, preferences, or photos, and
durability comes from Android Auto Backup to your own Google account.

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
single-user local-first design, dismissals and favourites,
£15/month Lambda-first budget, ingredient disambiguation, pantry
staples).

**v1 ends at a textual shopping list** — no price comparison, no
retailer integration, so it depends on nothing outside our control.
Filling the real Sainsbury's trolley is iteration 6, using an approach
worked out from the MIT-licensed
[`open-supermarkets`](https://github.com/abracadabra50/open-supermarkets)
project; multi-retailer price comparison follows after that. This
sequencing means the plan's former biggest risk (retailer data access,
`risks-and-open-questions.md` §9) is off the critical path entirely.

Nothing gets built until the owner says go.

## Ground rules for this plan

- **Local-first.** The device stores the data and does the computing;
  AWS earns its place only where the device genuinely can't do the job.
- **One install, one user, no accounts.** The device is the user;
  nothing in the schema is owned by anybody.
- **No hidden learned state.** Anything the app infers about the owner
  is visible and editable, including the LLM prompt itself.
- Security is a first-class requirement, not a later pass, because a
  real debit card and real supermarket accounts are involved.
- Every iteration should end with something the owner can actually use
  on their phone, even if later iterations replace parts of it.
- Prefer boring, inspectable technology over cleverness, given this is
  built and operated by one person.
