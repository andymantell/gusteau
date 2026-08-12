# Risks and open questions

These need owner decisions before the plan can be called "ready to
implement." Resolved items have moved to `decisions.md` and are kept
here only as a pointer, with any follow-on questions they raised.
Biggest remaining one first.

## 1. Supermarket ordering automation — how far do we actually automate?

**Resolved 2026-08-12 — see `decisions.md`.** Phased, assisted-first:
Gusteau builds and compares the basket, then hands off to the
retailer's own app/site for the owner to complete payment, for every
retailer initially. Fully automated checkout for a given retailer is a
later, separate decision per retailer — not assumed here.

## 2. Which supermarkets to target first

**Resolved 2026-08-12 — see `decisions.md`.** Tesco, Sainsbury's,
Asda, Waitrose, plus a spike (iteration 5) to check whether ordering
via Amazon.co.uk's grocery partnerships (Morrisons/Co-op/Iceland, plus
Amazon's own grocery range) is a viable fifth channel.

## 3. LLM approach — prompt+RAG vs. fine-tuning vs. off-the-shelf

**Resolved 2026-08-12 — see `decisions.md`.** Prompt engineering + RAG
on a general multimodal Bedrock model as the primary path, with a
time-boxed iteration-1 spike evaluating an off-the-shelf Hugging Face
cookery model via Bedrock Custom Model Import as a possible
supplement — kept only if it demonstrably wins.

## 4. Household scope

**Resolved 2026-08-12 — see `decisions.md`.** Model `Household` and
`User` as first-class from the start, even though it'll likely only
ever run for a household of one.

**Follow-on question this raised — resolved 2026-08-12, see
`decisions.md`.** A `WeeklyPlan` is a single shared plan for the whole
household, and dismissing a recipe (temporary or permanent) removes it
for everyone, not just the member who dismissed it.

## 5. Payment mechanics, concretely

Given posture B or C above, "payment" may never touch Gusteau at all
for a while (the owner pays on the retailer's own checkout). If/when
posture A is used for any retailer, need to confirm: Gusteau relies
entirely on a payment method already saved on the retailer account
(never asks for or stores a card number itself). Worth stating as a
hard rule regardless of posture, so it's never revisited under
convenience pressure later.

## 6. Recipe/nutrition data source for grounding

**Resolved 2026-08-12 — see `decisions.md`.** No external recipe
corpus for MVP — the owner doesn't have one and sourcing one isn't
worth it for a single-household tool. Suggestion generation relies on
the model's own knowledge plus the household's own preference/
dismissal history (which the app generates itself). The app's own
accepted/photo-derived recipes can become a self-built, optional RAG
source later once there's enough history. A free ingredient/nutrition
database (e.g. Open Food Facts) remains a candidate for the
ingredient-matching problem in §8, which is a separate concern.

## 7. Budget / AWS cost expectations

**Resolved 2026-08-12 — see `decisions.md`.** Ceiling of **£15/month**.
Achievable by design — Lambda-only compute, no VPC/NAT, no ALB, no
always-on containers, DynamoDB on-demand — see "Cost and frugality" in
`architecture.md`. CloudWatch billing alarm at £15 is an iteration 0
requirement.

## 8. Ingredient → purchasable product matching

Turning "200g chicken thighs" into an actual orderable product/pack
size at a specific retailer is non-trivial (retailer catalog matching,
substitutions when out of stock, unit conversion). Likely to be one of
the harder pieces of the build regardless of the automation posture
chosen in Q1 — flagged here so it's not underestimated when iterations
are sized.
