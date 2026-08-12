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

**Two decisions have since removed this from the critical path
entirely.** Dropping price comparison made it one retailer instead of
four; moving the integration to iteration 6 means **v1 doesn't touch
retailer data at all** — it ends at a textual checklist. So this is
now a question about how good iteration 6 can be, not whether the
project works.

**A concrete approach has been identified**, from reading
[`open-supermarkets`](https://github.com/abracadabra50/open-supermarkets)
(MIT) during planning — full analysis in `architecture.md`,
"Sainsbury's integration". The short version: Sainsbury's search and
basket operations are plain authenticated HTTP against
`groceries-api/gol-services`, reimplementable in Dart on-device; only
login, slots and payment need a browser, and Android WebView provides
that without Playwright or a server. The owner logs in on Sainsbury's
own page, so no password is ever stored.

The iteration-6 spike is therefore narrower again: confirm those
endpoints still behave from a Dart client on a residential connection,
and check the store-number handling.

**Residual risk, permanent:** this is an unofficial internal API,
documented by one person's repo, against a site that can change
without notice. It will break eventually. Mitigated by keeping the
iteration-5 checklist as a permanent fallback rather than deleting it
once the integration works — degradation should be "back to the
checklist for a bit", not "app is useless".

**Also noted:** the ~20-minute session expiry means re-login is a
routine part of the flow, not a one-off setup step. Worth designing
the WebView login to be fast rather than treating it as rare.

**Still open for post-v1 comparison work:** the same questions times
three more retailers, where the checklist floor is *not* an acceptable
answer — a price comparison built on estimated prices would be worse
than none. `open-supermarkets` covers Tesco and Ocado too, which is a
head start, though Tesco there uses a browser session rather than
email/password.

## 10. Device loss *(largely resolved — Android Auto Backup, with caveats to implement)*

**Resolved in principle 2026-08-12 — see `decisions.md`.** Android
Auto Backup ties app data to the owner's Google account, so device
loss is not data loss: a new phone restores the database during setup.
It's also encrypted with a key derived from the device passcode
(Android 9+), so it doesn't undo the privacy property local-first was
chosen for.

That downgrades this from the sharpest edge in the design to a set of
implementation details that must not be skipped. Full treatment in
`architecture.md`, "Backup and durability". The ones that can fail
silently:

- **SQLite WAL consistency.** Backing up the main DB file without a
  consistent `-wal` sidecar yields a stale or corrupt restore, with no
  error at backup time. Needs a WAL checkpoint before backup and
  explicit exclusion of `-wal`/`-shm`. **This is the one most likely
  to be discovered too late.**
- **25MB per-app quota**, silently truncating anything larger. Not a
  practical constraint now that photos are discarded after extraction
  — the database is text — but worth knowing the limit exists.
- **Never-tested restore.** Iteration 0 includes an actual
  install-and-restore test on a clean device, repeated when the schema
  changes.

**One more thing whose loss is expensive: the Android signing
keystore.** Android identifies an app by its signing certificate, so
losing the keystore means no upgrade can be installed over an existing
build — it must be uninstalled first, taking the local database with
it, and Auto Backup restore is tied to the same signing identity so it
won't help either. The keystore therefore belongs wherever the JSON
export is kept, not solely in GitHub secrets (which are write-only and
can't be read back). See `ci-cd.md`.

**The second layer: export/import via the system file picker.** Added
2026-08-12 — the owner can export the database (optionally with
photos) through Android's standard file-save sheet, which lists Google
Drive alongside local storage and anything else installed. No Drive
API, no OAuth, no Google Cloud project, and not locked to Drive. This
is what covers the cases Auto Backup can't: losing the Google account
itself, wanting a copy under the owner's own control, moving off the
app, or recovering the photos that the quota forces Auto Backup to
skip. See `architecture.md`.

**Residual risks, accepted:**

- Auto Backup depends on the owner's Google account remaining
  accessible. The file-picker export covers that case, provided it's
  been run and stored somewhere that isn't also the same Google
  account — hence the staleness nudge in settings.
- Up to ~24 hours of recent changes may be unbacked, since Auto Backup
  runs roughly daily on charge/idle/Wi-Fi. Immaterial for weekly meal
  planning.
- No photos are restored, because none are kept — they're discarded
  once the recipe is extracted. The recipes themselves restore fine,
  which is the part that ever mattered.

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
