# gusteau

A personal meal-planning and grocery-ordering app: Bedrock-powered recipe
suggestions, a Flutter Android client, and AWS infrastructure via CDK
(Python).

Planning lives in [`docs/planning/`](./docs/planning/) — start there for
the design, decisions, and iteration breakdown. Iteration 0
(foundations) is built; see `docs/planning/README.md#status` for exactly
what's done and what's left as manual setup.

## Layout

- `app/` — the Flutter (Android) client
- `infra/` — the AWS CDK app (Python) for the inference proxy
- `.github/workflows/` — CI, deploy, and release pipelines