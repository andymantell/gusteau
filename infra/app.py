#!/usr/bin/env python3
"""CDK app entrypoint.

No AWS account ID is hardcoded here — it's resolved from the deploying
principal's environment at synth/deploy time (CDK_DEFAULT_ACCOUNT), since
this is a public repository. See docs/planning/ci-cd.md, "Public
repository considerations".
"""

import os

import aws_cdk as cdk

from gusteau_infra.proxy_stack import ProxyStack

app = cdk.App()

env = cdk.Environment(
    account=os.environ.get("CDK_DEFAULT_ACCOUNT"),
    region=os.environ.get("CDK_DEFAULT_REGION", "eu-west-2"),
)

# Only passed through if set, so ProxyStack's own default (a placeholder
# pending the model-tier spike — see proxy_stack.py and
# docs/planning/decisions.md) stays the single source of truth until the
# owner overrides it.
proxy_kwargs = {}
if "GUSTEAU_BEDROCK_MODEL_ID" in os.environ:
    proxy_kwargs["bedrock_model_id"] = os.environ["GUSTEAU_BEDROCK_MODEL_ID"]

ProxyStack(
    app,
    "GusteauProxyStack",
    env=env,
    description="Gusteau: inference proxy (API Gateway + Lambda) in front of Bedrock.",
    # AWS Budgets is USD-only. £15/month is approximated in USD and should
    # be revisited occasionally as FX moves — see docs/planning/ci-cd.md.
    monthly_budget_usd=float(os.environ.get("GUSTEAU_MONTHLY_BUDGET_USD", "19")),
    monthly_request_quota=int(os.environ.get("GUSTEAU_MONTHLY_REQUEST_QUOTA", "2000")),
    # Not committed anywhere — supplied at deploy time only. If unset, the
    # budget is still created but has no notification subscriber.
    budget_alert_email=os.environ.get("GUSTEAU_BUDGET_ALERT_EMAIL"),
    **proxy_kwargs,
)

app.synth()
