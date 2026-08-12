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

**Resolved 2026-08-12 — see `decisions.md`.** Prompt engineering on a
general multimodal Bedrock model as the primary path (no RAG — the
corpus assumption was later dropped, see §6), validated by an upfront
prompt spike, with the same spike evaluating an off-the-shelf Hugging
Face cookery model via Bedrock Custom Model Import as a possible
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

**Addressed 2026-08-12.** Under the assisted-handoff posture, payment
never touches Gusteau at all — the owner pays on the retailer's own
checkout. The requested hard rule is now stated as standing policy in
`architecture.md` ("Security posture") and `requirements.md`: Gusteau
never asks for, stores, or transmits card details, under any future
posture; if automation is ever added, payment rides entirely on the
method already saved on the retailer account.

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
are sized. Note it also depends entirely on §9: there's nothing to
match against without a source of product/price data.

## 9. Where does product & price data come from? *(open — biggest remaining risk)*

Surfaced during plan review 2026-08-12. The assisted-handoff decision
(§1) resolved the ToS/fragility problem for *checkout* — but iteration
5's price comparison still needs **read access to four retailers'
product catalogs and prices**, and none of Tesco, Sainsbury's, Asda,
or Waitrose offers a public consumer API for that. Read-only scraping
carries much of the same ToS/bot-detection exposure the ordering
decision deliberately avoided, just at lower stakes; UK grocer sites
are known to run aggressive bot protection; and a headless-browser
scraper strains the Lambda-only/£15-month constraints (Chromium in
Lambda is possible but heavy, and residential proxies — the usual
workaround for bot detection — are exactly the kind of recurring cost
this budget excludes).

Options to evaluate in a **feasibility spike that should happen before
iteration 5 is committed to, not during it**:

- Third-party grocery price-comparison APIs/aggregators (paid or free
  tiers) that already solve retailer data access.
- Unofficial retailer mobile-app APIs (lighter than HTML scraping,
  still unofficial).
- Direct HTML scraping where a retailer tolerates it.
- Amazon-channel pricing (§2 spike) as a partially-API-shaped path.
- Honest fallbacks if per-retailer access fails: fewer retailers in
  the comparison, cached/periodic rather than live prices, or
  LLM-estimated typical prices clearly labelled as estimates.

Until this spike is done, **iteration 5 is the highest-risk part of
the plan** and should be assumed to potentially land in a reduced form
(fewer retailers, or approximate prices). Iterations 0–4 and 6 do not
depend on it: the weekly-plan/shopping-list core is fully usable with
a handoff checklist even if price comparison ends up degraded.
