"""cdk synth as a test, not just a CLI command.

The infra-side half of "test the deterministic core hard" from
docs/planning/ci-cd.md: this can't test Bedrock output quality, but it can
assert the stack actually synthesises and — importantly — that it keeps
the architectural promises made in architecture.md: no VPC, no data
stores, an API key behind a usage plan with a real monthly quota.
"""

from __future__ import annotations

import aws_cdk as cdk
from aws_cdk.assertions import Match, Template

from gusteau_infra.proxy_stack import ProxyStack


def _synth_template() -> Template:
    app = cdk.App()
    stack = ProxyStack(
        app,
        "TestProxyStack",
        env=cdk.Environment(account="123456789012", region="eu-west-2"),
        monthly_budget_usd=19.0,
        monthly_request_quota=2000,
        budget_alert_email="test@example.com",
    )
    return Template.from_stack(stack)


def test_synthesises_without_error() -> None:
    _synth_template()


def test_exactly_one_lambda_function() -> None:
    template = _synth_template()
    template.resource_count_is("AWS::Lambda::Function", 1)


def test_lambda_has_no_vpc_config() -> None:
    template = _synth_template()
    template.has_resource_properties(
        "AWS::Lambda::Function",
        Match.not_(Match.object_like({"VpcConfig": Match.any_value()})),
    )


def test_rest_api_present_not_http_api() -> None:
    # The plan originally called for an HTTP API, which doesn't support
    # API keys or usage plans — see the module docstring in proxy_stack.py.
    template = _synth_template()
    template.resource_count_is("AWS::ApiGateway::RestApi", 1)
    template.resource_count_is("AWS::ApiGatewayV2::Api", 0)


def test_health_route_requires_api_key() -> None:
    template = _synth_template()
    template.has_resource_properties(
        "AWS::ApiGateway::Method",
        {
            "HttpMethod": "GET",
            "ApiKeyRequired": True,
        },
    )


def test_usage_plan_has_monthly_quota() -> None:
    template = _synth_template()
    template.has_resource_properties(
        "AWS::ApiGateway::UsagePlan",
        {
            "Quota": {
                "Limit": 2000,
                "Period": "MONTH",
            }
        },
    )


def test_monthly_budget_present_in_usd() -> None:
    template = _synth_template()
    template.has_resource_properties(
        "AWS::Budgets::Budget",
        {
            "Budget": Match.object_like(
                {
                    "BudgetType": "COST",
                    "TimeUnit": "MONTHLY",
                    "BudgetLimit": {"Amount": 19.0, "Unit": "USD"},
                }
            )
        },
    )


def test_no_data_stores() -> None:
    """Encodes the "no DynamoDB, no S3, no Secrets Manager, no Cognito"
    rule from architecture.md as a regression guard, not just prose."""
    template = _synth_template()
    for resource_type in (
        "AWS::DynamoDB::Table",
        "AWS::S3::Bucket",
        "AWS::SecretsManager::Secret",
        "AWS::Cognito::UserPool",
        "AWS::EC2::VPC",
    ):
        template.resource_count_is(resource_type, 0)


def test_synth_without_budget_email_still_works() -> None:
    """CI runs cdk synth with no secrets — see ci-cd.md. The stack must
    still synthesise cleanly with no alert email configured."""
    app = cdk.App()
    stack = ProxyStack(
        app,
        "TestProxyStackNoEmail",
        env=cdk.Environment(account="123456789012", region="eu-west-2"),
        monthly_budget_usd=19.0,
        monthly_request_quota=2000,
        budget_alert_email=None,
    )
    Template.from_stack(stack)
