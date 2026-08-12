# Decisions log

Resolved decisions move here from `risks-and-open-questions.md`, in
the order they were made. Each entry: the question, what was decided,
and why — so we don't relitigate it later without a reason.

## 2026-08-12 — Ordering automation posture

**Decided:** Phased. Start with assisted handoff (Gusteau builds the
compared basket, hands off to the retailer's own app/site for the
owner to do the final add-to-basket-and-pay step) for every retailer.
Revisit full automation per-retailer later only where it looks
technically viable and the owner is comfortable with the ToS/security
tradeoff.

**Why:** lowest risk and fastest to ship, while still delivering most
of the value (comparison + list-building, which is the tedious part).
Keeps iteration 6 scoped and avoids taking on standing retailer
credential access before it's proven necessary.

## 2026-08-12 — Target retailers

**Decided:** Tesco, Sainsbury's, Asda, and Waitrose as the initial
set, plus investigate ordering via **Amazon.co.uk's grocery
partnerships** (Morrisons, Co-op, Iceland are all orderable through
Amazon as of 2026, alongside Amazon's own grocery range) as a
potentially efficient fifth channel — one integration against Amazon's
checkout could stand in for several retailer brands at once. Needs a
short technical spike in iteration 5 to confirm feasibility before
committing to it as a channel.

**Why:** covers the major UK grocers the owner is likely to actually
use, with Amazon flagged as worth investigating rather than committed
to, since its viability as an automatable/assistable channel hasn't
been checked yet.

## 2026-08-12 — LLM strategy for recipe suggestions

**Decided:** Primary path is a strong general multimodal model on
Bedrock (e.g. Claude) with cookery-focused prompting and RAG
grounding, per `architecture.md`. In parallel, run a small **evaluation
spike in iteration 1** trying an off-the-shelf, cookery-specialised
open model from Hugging Face (see `architecture.md` for candidates and
why none is an obvious drop-in win) via Bedrock Custom Model Import,
and only keep it in the design if it demonstrably beats prompt+RAG on
a general model for recipe-generation quality.

**Why:** the owner asked to explore off-the-shelf/Hugging Face
options specifically. Research during planning found existing
"specialist cookery" models on Hugging Face are small (560M–1.1B
parameter), narrowly trained (e.g. diabetic-friendly recipes, one
regional cuisine), and text-only — none are multimodal, which rules
each out as a full replacement given the photo-to-recipe requirement.
Treating it as a time-boxed spike honours the request without
gambling the core suggestion feature on an unproven small model.

## 2026-08-12 — Household / multi-user scope

**Decided:** structure the whole system as multi-user/multi-household
from the start (proper `Household` and `User` entities, per-user
preferences and dismissals), even though it will likely only ever run
for a household of one. Not building a public sign-up flow or
multi-tenant marketing site — just not hard-coding a single-user
assumption into the data model or auth.

**Why:** cheap to do correctly now, expensive to retrofit later, and
the owner wants the option open even if it's never released.
Raises a follow-on open question — see `risks-and-open-questions.md`
— about whether a weekly plan is one shared plan for the whole
household or one per member; captured there rather than assumed.
