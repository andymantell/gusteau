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

**Resolved 2026-08-12, then narrowed — see `decisions.md`.** Originally
Tesco, Sainsbury's, Asda, Waitrose plus an Amazon-channel spike. **v1
is now Sainsbury's only**, with the rest (and the price comparison
they existed to serve) deferred to post-v1.

## 3. LLM approach — prompt+RAG vs. fine-tuning vs. off-the-shelf

**Resolved 2026-08-12 — see `decisions.md`.** Prompt engineering on a
general multimodal Bedrock model as the primary path (no RAG — the
corpus assumption was later dropped, see §6), validated by an upfront
prompt spike, with the same spike evaluating an off-the-shelf Hugging
Face cookery model via Bedrock Custom Model Import as a possible
supplement — kept only if it demonstrably wins.

## 4. Household scope

**Resolved 2026-08-12, then reversed the same day — see
`decisions.md`.** Originally: model `Household` and `User` as
first-class from the start. Superseded by **one install, one user, no
account** — the device is the user, and there are no household, user,
or ownership concepts anywhere in the schema.

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
worth it for a personal tool. Suggestion generation relies on the
model's own knowledge plus the app's own accumulated preference and
dismissal history (which it generates itself). The app's own
accepted/photo-derived recipes can become a self-built, optional RAG
source later once there's enough history. A free ingredient/nutrition
database (e.g. Open Food Facts) remains a candidate for the
ingredient-matching problem in §8, which is a separate concern.

## 7. Budget / AWS cost expectations

**Resolved 2026-08-12 — see `decisions.md`.** Ceiling of **£15/month**.
Made much easier by the later local-first decision: with no cloud data
stores and almost no cloud compute, Bedrock tokens are essentially the
only line on the bill. See "Cost and frugality" in `architecture.md`.
A CloudWatch billing alarm at £15 plus a spend guard in the proxy
Lambda are iteration 0 requirements.

## 8. Ingredient → purchasable product matching

Turning "200g chicken thighs" into an actual orderable product/pack
size at a specific retailer is non-trivial (retailer catalog matching,
substitutions when out of stock, unit conversion). Likely to be one of
the harder pieces of the build regardless of the automation posture
chosen in Q1 — flagged here so it's not underestimated when iterations
are sized. Note it also depends entirely on §9: there's nothing to
match against without a source of product/price data.

**Design approach now decided** (2026-08-12, prompted by the "how do
you know which mince?" question) — see `architecture.md`, "Ingredient
specificity and product preferences", and `decisions.md`. In short:
generate precise ingredients up front, infer from dish context,
learn standing preferences, ask only for novel and consequential
choices, batch questions into basket review, and store preferences
retailer-neutrally so price comparison stays like-for-like.

**Still genuinely uncertain**, and only answerable once §9 settles
where catalog data comes from:

- **How good is fuzzy matching in practice?** Mapping "beef mince,
  12% fat, 500g, standard own-brand" onto a specific retailer SKU is
  the actual hard engineering, and its difficulty depends entirely on
  what the data source gives us (a structured aggregator feed is a
  very different problem from scraped search-result HTML).
- **Does an LLM call belong in the matching loop?** Plausibly a good
  fit for fuzzy product matching, but a per-line Bedrock call across
  four retailers has real token cost against the £15/month ceiling.
  Likely answer is deterministic matching first with LLM fallback for
  unresolved lines, plus caching — but this needs measuring, not
  assuming.
- **Pack-size rounding across merged recipes** interacts with waste:
  three recipes needing 300g total shouldn't order 3×500g. Rounding
  happens after merging, on the summed quantity — easy to state, worth
  testing against real weekly plans.

## 9. Sainsbury's product data access *(open — but no longer project-threatening)*

Surfaced during plan review 2026-08-12, when this was the plan's
biggest risk: price comparison needed read access to four retailers'
catalogs and prices, and none of the UK grocers offers a public
consumer API. Read-only scraping carries much of the ToS and
bot-detection exposure the assisted-handoff decision deliberately
avoided; UK grocer sites run aggressive bot protection; and a
headless-browser scraper strains the Lambda-only/£15-a-month
constraints (Chromium in Lambda is heavy, and residential proxies are
exactly the recurring cost this budget excludes).

**Dropping price comparison from v1 (see `decisions.md`) shrinks this
from a project risk to a feature-quality question**, for two reasons:
it's now one retailer instead of four, and v1 has a floor that needs
no retailer data at all — a well-ordered checklist used alongside the
Sainsbury's app is genuinely useful on its own.

So the spike ahead of iteration 5 asks a much narrower question: how
much Sainsbury's product data can we get, at what cost and fragility?
In rough order of preference:

- An aggregator or third-party grocery data API covering Sainsbury's.
- Sainsbury's unofficial mobile-app API (lighter than HTML scraping,
  still unofficial).
- Direct HTML scraping, if tolerated and cheap to run.
- No retailer data — ship the checklist floor, with pack sizes and
  approximate prices LLM-estimated and clearly labelled as estimates.

Each tier above the floor adds real value (stock awareness, true pack
sizes, a running basket total), so this is worth investigating
properly — but nothing about v1 fails if the answer is "the floor."

**Still open for post-v1 comparison work:** everything above, times
three more retailers, where the floor is *not* acceptable — a price
comparison built on estimated prices would be worse than none. That's
the bar the deferred comparison feature has to clear.

**Local-first changes one input to this spike:** fetching
from the device uses a residential mobile IP, which is far less likely
to trip bot protection than AWS IP ranges — a real point in favour of
on-device fetching. Against it, parsing logic on the device can only
be fixed by shipping a build. The spike should evaluate both.

## 10. Device loss = data loss *(open — accepted, needs mitigation)*

Local-first puts the accumulated favourites, dismissal reasons,
preference rules and ingredient preferences on the handset. That data
*is* the product's value — a year of learned preferences is not
reconstructible — and there is no server-side copy to restore from.

Mitigation ladder, cheapest first:

- **Android auto-backup**, on from iteration 1. Nearly free, but
  worth verifying it actually captures the app database rather than
  assuming it does.
- **Manual JSON export/import** the owner can run any time and store
  wherever they like. Also doubles as the migration path to a new
  phone and as an escape hatch if the app is ever abandoned. Note the
  export is plaintext.
- **Optional encrypted cloud backup**, post-v1, if local-only ever
  feels too thin. This is the same machinery sync would need (§11),
  so the two are worth designing together rather than separately.

Open question: is auto-backup plus manual export enough for the
owner's comfort, or should backup be designed in earlier? Cheap to
decide once the app is in real use and the data actually matters.

## 11. Multi-user and sync

**Closed 2026-08-12 — see `decisions.md`.** Not deferred; removed.
One install, one user, no accounts, no sync. A second device would be
a separate install with its own data, and moving phones is an
export/import (§10), not a sync.

Noted for the record: reversing this later would be a real migration —
adding ownership columns, backfilling them, and building whatever sync
mechanism multi-user implies. That cost was accepted knowingly, on the
grounds that it's overwhelmingly likely to be a single user forever,
and that carrying unused multi-tenancy through every query and screen
in the meantime is a certain cost paid against an unlikely benefit.
