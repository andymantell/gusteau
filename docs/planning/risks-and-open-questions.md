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

**Follow-on question this raises, still open:** is a `WeeklyPlan` a
single shared plan for the whole household (one set of N meals
everyone eats, like a Gousto box), or does each member get their own
plan? The brief as written ("suggest N recipes each week... I choose")
reads like a single shared household plan with preferences pooled
from all members, which is the working assumption for the data model
in `architecture.md` — flagging here so it's an explicit assumption
to confirm, not a silent one. Also open: for a *permanent* dismissal,
does it apply household-wide (nobody gets that recipe again) or only
to the member who dismissed it?

## 5. Payment mechanics, concretely

Given posture B or C above, "payment" may never touch Gusteau at all
for a while (the owner pays on the retailer's own checkout). If/when
posture A is used for any retailer, need to confirm: Gusteau relies
entirely on a payment method already saved on the retailer account
(never asks for or stores a card number itself). Worth stating as a
hard rule regardless of posture, so it's never revisited under
convenience pressure later.

## 6. Recipe/nutrition data source for RAG grounding

Suggestion quality depends on what the retrieval corpus is grounded
in. Options: a licensed recipe dataset, scraping (own legal/ToS
questions again), or leaning on the LLM's own knowledge with less
retrieval. Needs a decision once approach to Q3 is confirmed.

## 7. Budget / AWS cost expectations

Bedrock calls, Fargate (if needed for browser automation), S3/DynamoDB
are all pay-as-you-go. For a single user this should be cheap, but
worth the owner setting a rough monthly ceiling and a CloudWatch
billing alarm as part of iteration 0.

## 8. Ingredient → purchasable product matching

Turning "200g chicken thighs" into an actual orderable product/pack
size at a specific retailer is non-trivial (retailer catalog matching,
substitutions when out of stock, unit conversion). Likely to be one of
the harder pieces of the build regardless of the automation posture
chosen in Q1 — flagged here so it's not underestimated when iterations
are sized.
