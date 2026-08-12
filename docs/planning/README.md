# Gusteau — Planning

Gusteau is a personal (single-user) meal-planning and grocery-ordering Android
app, replacing Gousto/HelloFresh-style subscription boxes with a system that:

- suggests recipes each week using a Bedrock-hosted LLM,
- learns from what gets dismissed and why,
- can reconstruct a recipe from a photo (recipe card or a plate of food),
- consolidates ingredients across the week into a shopping list,
- compares that basket's price across multiple supermarkets, and
- reserves a delivery slot and places the order.

This directory is the living plan. Nothing here is implemented until the
plan is marked ready and the owner says go — see [status](#status) below.

## Documents

| Doc | Purpose |
|---|---|
| [`requirements.md`](./requirements.md) | Feature list as agreed so far, with MVP vs. later tagging |
| [`architecture.md`](./architecture.md) | System design: Flutter app, AWS/CDK backend, Bedrock LLM, data model |
| [`risks-and-open-questions.md`](./risks-and-open-questions.md) | Things that need a decision before build starts, especially around supermarket automation and payment security |
| [`iterations.md`](./iterations.md) | Build order, broken into iterations, each independently shippable to the owner's own phone |
| [`decisions.md`](./decisions.md) | Log of decisions made during planning, once resolved (ADR-style) |

## Status

**Planning — draft 1.** Requirements captured from the initial brief.
Key open questions (supermarket automation approach, target retailers,
LLM strategy, household scope) are not yet resolved — see
`risks-and-open-questions.md`. Nothing should be built until this doc
says "ready to implement" and the owner confirms.

## Ground rules for this plan

- Single user, personal use — no multi-tenancy, no public sign-up.
- Security is a first-class requirement, not a later pass, because a
  real debit card and real supermarket accounts are involved.
- Every iteration should end with something the owner can actually use
  on their phone, even if later iterations replace parts of it.
- Prefer boring, inspectable infrastructure (CDK, managed AWS services)
  over cleverness, given this is operated by one person.
