# Risks and open questions

These need owner decisions before the plan can be called "ready to
implement." Biggest one first.

## 1. Supermarket ordering automation — how far do we actually automate?

UK grocers (Tesco, Sainsbury's, Asda, Morrisons, Ocado, Waitrose) do
not publish a public API for building a basket and checking out as a
consumer. That leaves three realistic approaches, with very different
risk profiles:

- **A. Fully automated (headless browser / private API calls).**
  Gusteau logs into the retailer as the owner and drives the whole
  flow — add to basket, pick slot, pay — without a human in the loop.
  Most convenient, but: almost certainly against the retailer's terms
  of service for automated access, fragile (breaks whenever the
  retailer changes their site/adds bot detection), and the highest
  security blast radius since the backend needs standing access to
  the retailer session/credentials.
- **B. Assisted handoff.** Gusteau builds the compared/chosen basket
  and shopping list, then hands off to the retailer's own app/site
  (deep link, or just a checklist) for the owner to do the final
  add-to-basket-and-pay tap themselves. Safer (no ToS/bot-detection
  problem, no stored retailer credentials, no payment automation to
  secure), but "complete the order" becomes "get it 95% of the way
  there" rather than fully hands-off.
- **C. Phased.** Start with B for every retailer (ships fast, low
  risk), then selectively move specific retailers to A later if/where
  it's viable and the owner is comfortable with the risk (e.g. only
  for a retailer with a more tolerant stance, or if a legitimate
  partner API turns up).

**Decision needed:** which posture to plan around. This affects almost
everything downstream — the ordering service's design, whether Fargate
(long-lived browser sessions) is needed at all, and the security model.

## 2. Which supermarkets to target first

Affects how many "retailer adapters" iteration 5/6 need to build, and
which ones are even feasible under whichever posture is chosen above.
Likely candidates: Tesco, Sainsbury's, Asda, Ocado, Morrisons. Some
have historically been more or less tolerant of automated access than
others — worth checking per-retailer once the posture (question 1) is
decided.

## 3. LLM approach — prompt+RAG vs. fine-tuning

Covered in `architecture.md`. Recommendation is prompt engineering +
retrieval on a general Bedrock model to start. Needs a confirm/veto.

## 4. Household scope

Is this genuinely single-user, or does "my personal use" include
catering for a partner/household with their own likes, dislikes, and
dismissal reasons? Affects the data model (does a `Dismissal` belong
to a user, or is there only ever one implicit user) and the suggestion
prompt (whose preferences count). Cheap to build in a second profile
now vs. bolt it on later.

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
