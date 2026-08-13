"""Gusteau's entire AWS footprint: a thin, authenticated proxy in front of
Bedrock, plus a monthly spend guard. See docs/planning/architecture.md,
"Backend — AWS, CDK (Python)" and "Cost and frugality".

Deliberately absent: DynamoDB, S3, Secrets Manager, VPC, Cognito. There is
no data store because the device is the system of record (local-first —
see docs/planning/decisions.md).

One correction from the original planning docs, made during
implementation: the plan called for an "API Gateway HTTP API" with an API
key in a usage plan. HTTP APIs (API Gateway v2) do not support API keys
or usage plans — that's a REST API (v1) feature only. This stack uses a
REST API instead, which is the only way to get the "usage plan IS the
rate limit and quota, configured declaratively" property the plan was
actually after. The cost difference (REST ~$3.50/million requests vs.
HTTP ~$1.00/million) is irrelevant at personal-use volumes.
"""

from __future__ import annotations

import aws_cdk as cdk
from aws_cdk import CfnOutput, Duration, RemovalPolicy, Stack
from aws_cdk import aws_apigateway as apigw
from aws_cdk import aws_budgets as budgets
from aws_cdk import aws_iam as iam
from aws_cdk import aws_lambda as lambda_
from aws_cdk import aws_logs as logs
from constructs import Construct


class ProxyStack(Stack):
    def __init__(
        self,
        scope: Construct,
        construct_id: str,
        *,
        monthly_budget_usd: float,
        monthly_request_quota: int,
        budget_alert_email: str | None,
        # Placeholder pending the model-tier spike in decisions.md
        # ("Validate 'generic model is good enough' before building on
        # it") — a single config value, trivially changed once the
        # owner runs it. Not a Bedrock model *name* on its own always
        # works as a modelId; some models need a full inference-profile
        # ARN instead. Confirm the exact string works with `converse()`
        # in the deploy region before relying on it.
        bedrock_model_id: str = "anthropic.claude-haiku-4-5-20251001-v1:0",
        **kwargs,
    ) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # --- Inference proxy Lambda -----------------------------------
        #
        # A thin relay: the app assembles the full Converse request
        # (system prompt, messages, the Recipe tool schema) on-device —
        # see architecture.md, "The structured-output contract" and "On-
        # device prompt assembly". This Lambda only enforces which model
        # actually gets called (server-side — see bedrock_model_id
        # above) and relays Bedrock's response, including its real
        # errors, back unparaphrased.
        proxy_fn = lambda_.Function(
            self,
            "InferenceProxy",
            function_name="gusteau-inference-proxy",
            runtime=lambda_.Runtime.PYTHON_3_13,
            architecture=lambda_.Architecture.ARM_64,  # cheaper, and plenty for this workload
            handler="handler.handler",
            code=lambda_.Code.from_asset("gusteau_infra/lambda/inference_proxy"),
            timeout=Duration.seconds(25),  # REST API integration hard-caps at 29s
            memory_size=256,
            # Explicit log group rather than log_retention=, which is
            # deprecated and (worse) provisions a second, hidden Lambda
            # behind the scenes just to set the retention policy.
            log_group=logs.LogGroup(
                self,
                "InferenceProxyLogs",
                retention=logs.RetentionDays.TWO_WEEKS,
                removal_policy=RemovalPolicy.DESTROY,
            ),
            environment={
                "BEDROCK_MODEL_ID": bedrock_model_id,
            },
        )
        # Least-privilege IAM: scoped to InvokeModel on foundation
        # models and inference profiles in this region only — not a
        # wildcard across actions/resources, but also not pinned to one
        # exact model ARN yet, since bedrock_model_id above is still a
        # placeholder pending the spike. Narrow this further once that
        # settles. See architecture.md, "Security posture".
        proxy_fn.add_to_role_policy(
            iam.PolicyStatement(
                actions=["bedrock:InvokeModel"],
                resources=[
                    f"arn:{self.partition}:bedrock:{self.region}::foundation-model/*",
                    f"arn:{self.partition}:bedrock:{self.region}:{self.account}:inference-profile/*",
                ],
            )
        )

        # --- REST API ----------------------------------------------------
        api = apigw.RestApi(
            self,
            "GusteauApi",
            rest_api_name="gusteau-inference-proxy",
            description="Gusteau inference proxy — relays requests from the app to Bedrock.",
            endpoint_types=[apigw.EndpointType.REGIONAL],
            cloud_watch_role=True,
            deploy_options=apigw.StageOptions(
                stage_name="prod",
                logging_level=apigw.MethodLoggingLevel.INFO,
                metrics_enabled=True,
                # Per-stage throttle defaults; the usage plan below is the
                # real (per-API-key) control, but these bound the API as a
                # whole regardless of key.
                throttling_rate_limit=5,
                throttling_burst_limit=10,
                access_log_destination=apigw.LogGroupLogDestination(
                    logs.LogGroup(
                        self,
                        "ApiAccessLogs",
                        retention=logs.RetentionDays.TWO_WEEKS,
                        removal_policy=RemovalPolicy.DESTROY,
                    )
                ),
                # Token counts and latency only — never request/response
                # bodies, which would contain prompts. See "Security
                # posture" in architecture.md.
                access_log_format=apigw.AccessLogFormat.custom(
                    '{"requestId":"$context.requestId",'
                    '"status":"$context.status",'
                    '"latencyMs":"$context.responseLatency",'
                    '"apiKeyId":"$context.identity.apiKeyId"}'
                ),
            ),
        )

        health = api.root.add_resource("health")
        health.add_method(
            "GET",
            apigw.LambdaIntegration(proxy_fn),
            api_key_required=True,
        )

        generate = api.root.add_resource("generate")
        generate.add_method(
            "POST",
            apigw.LambdaIntegration(proxy_fn),
            api_key_required=True,
        )

        # --- API key + usage plan ----------------------------------------
        #
        # This is the whole auth story (see architecture.md, "Backend —
        # AWS, CDK (Python)"): one device, no personal data behind the
        # endpoint, so the only thing worth protecting is the inference
        # budget. The usage plan's quota IS the monthly cap — declarative,
        # not something the Lambda has to enforce in code.
        api_key = api.add_api_key("GusteauApiKey", api_key_name="gusteau-app")

        plan = api.add_usage_plan(
            "GusteauUsagePlan",
            name="gusteau-usage-plan",
            throttle=apigw.ThrottleSettings(rate_limit=5, burst_limit=10),
            quota=apigw.QuotaSettings(
                limit=monthly_request_quota,
                period=apigw.Period.MONTH,
            ),
        )
        plan.add_api_key(api_key)
        plan.add_api_stage(stage=api.deployment_stage)

        # --- Monthly spend guard ------------------------------------------
        #
        # AWS Budgets rather than a classic CloudWatch billing-metric
        # alarm: the CloudWatch AWS/Billing EstimatedCharges metric only
        # exists in us-east-1 and requires "Receive Billing Alerts" to be
        # manually enabled in account billing preferences first — an
        # extra manual step with no CDK equivalent. Budgets has no such
        # prerequisite and works from any deploy region.
        #
        # Budgets are USD-only (an AWS constraint, not a choice here);
        # monthly_budget_usd is an approximation of the owner's £15/month
        # figure and is worth revisiting occasionally as FX moves — see
        # docs/planning/ci-cd.md.
        notifications_with_subscribers = []
        if budget_alert_email:
            notifications_with_subscribers.append(
                budgets.CfnBudget.NotificationWithSubscribersProperty(
                    notification=budgets.CfnBudget.NotificationProperty(
                        notification_type="ACTUAL",
                        comparison_operator="GREATER_THAN",
                        threshold=80,  # % of budget — an early warning, not just a post-mortem
                        threshold_type="PERCENTAGE",
                    ),
                    subscribers=[
                        budgets.CfnBudget.SubscriberProperty(
                            subscription_type="EMAIL",
                            address=budget_alert_email,
                        )
                    ],
                )
            )
            notifications_with_subscribers.append(
                budgets.CfnBudget.NotificationWithSubscribersProperty(
                    notification=budgets.CfnBudget.NotificationProperty(
                        notification_type="ACTUAL",
                        comparison_operator="GREATER_THAN",
                        threshold=100,
                        threshold_type="PERCENTAGE",
                    ),
                    subscribers=[
                        budgets.CfnBudget.SubscriberProperty(
                            subscription_type="EMAIL",
                            address=budget_alert_email,
                        )
                    ],
                )
            )
        else:
            print(  # noqa: T201 — deliberate synth-time visibility, not app logging
                "WARNING: no budget_alert_email configured — the AWS Budget "
                "will be created with no notification subscriber. Set "
                "GUSTEAU_BUDGET_ALERT_EMAIL before deploying for real."
            )

        budgets.CfnBudget(
            self,
            "MonthlyBudget",
            budget=budgets.CfnBudget.BudgetDataProperty(
                budget_name="gusteau-monthly",
                budget_type="COST",
                time_unit="MONTHLY",
                budget_limit=budgets.CfnBudget.SpendProperty(
                    amount=monthly_budget_usd,
                    unit="USD",
                ),
            ),
            notifications_with_subscribers=notifications_with_subscribers or None,
        )

        # --- Outputs -------------------------------------------------------
        CfnOutput(self, "ApiUrl", value=api.url)
        # The key's ID, never its value — deploy logs are public on a
        # public repo. Retrieve the value from the console once, by hand.
        CfnOutput(self, "ApiKeyId", value=api_key.key_id)

        cdk.Tags.of(self).add("project", "gusteau")
