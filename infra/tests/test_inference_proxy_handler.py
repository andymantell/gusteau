"""Unit tests for the inference proxy Lambda's own logic — routing,
request validation, and Bedrock error-code mapping. Complements
test_proxy_stack.py, which only tests the CDK synth output; this tests
the actual handler code that runs. See docs/planning/ci-cd.md,
"Testing strategy" — never call a live LLM in CI, but the deterministic
logic around it is tested hard.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path
from unittest.mock import MagicMock

import pytest
from botocore.exceptions import ClientError

# The Lambda asset directory isn't a Python package (CDK bundles its
# contents wholesale as the deployment root) — added to sys.path so it
# can be imported directly, like the real Lambda runtime does.
_LAMBDA_DIR = (
    Path(__file__).resolve().parent.parent / "gusteau_infra" / "lambda" / "inference_proxy"
)
sys.path.insert(0, str(_LAMBDA_DIR))

import handler  # noqa: E402 — must follow the sys.path.insert above


@pytest.fixture(autouse=True)
def _model_id(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.setenv("BEDROCK_MODEL_ID", "test-model-id")


@pytest.fixture(autouse=True)
def _reset_bedrock_singleton() -> None:
    # Each test that touches Bedrock injects its own mock client; make
    # sure one test's mock can't leak into the next via the lazy-init
    # singleton.
    handler._bedrock_client = None
    yield
    handler._bedrock_client = None


def _event(path: str, method: str, body: dict | None = None) -> dict:
    return {
        "path": path,
        "httpMethod": method,
        "body": json.dumps(body) if body is not None else None,
    }


def test_health_route_unchanged() -> None:
    response = handler.handler(_event("/health", "GET"), None)
    assert response["statusCode"] == 200
    body = json.loads(response["body"])
    assert body["status"] == "ok"


def test_unknown_route_is_404() -> None:
    response = handler.handler(_event("/nonsense", "GET"), None)
    assert response["statusCode"] == 404


def test_generate_rejects_missing_messages() -> None:
    response = handler.handler(_event("/generate", "POST", {"toolConfig": {"tools": [{}]}}), None)
    assert response["statusCode"] == 400
    assert "messages" in json.loads(response["body"])["error"]


def test_generate_rejects_empty_messages() -> None:
    response = handler.handler(
        _event("/generate", "POST", {"messages": [], "toolConfig": {"tools": [{}]}}), None
    )
    assert response["statusCode"] == 400


def test_generate_rejects_missing_tool_config() -> None:
    response = handler.handler(
        _event("/generate", "POST", {"messages": [{"role": "user", "content": []}]}), None
    )
    assert response["statusCode"] == 400
    assert "toolConfig" in json.loads(response["body"])["error"]


def test_generate_rejects_invalid_json_body() -> None:
    event = {"path": "/generate", "httpMethod": "POST", "body": "not json"}
    response = handler.handler(event, None)
    assert response["statusCode"] == 400


def test_generate_calls_bedrock_with_server_side_model_id_not_client_supplied() -> None:
    mock_client = MagicMock()
    mock_client.converse.return_value = {"output": {"message": {"content": []}}}
    handler._bedrock_client = mock_client

    request_body = {
        "messages": [{"role": "user", "content": [{"text": "hi"}]}],
        "toolConfig": {"tools": [{"toolSpec": {"name": "submit_recipe"}}]},
        # A client trying to pick its own (possibly more expensive) model
        # must be ignored — the server-side env var wins.
        "modelId": "client-supplied-model-should-be-ignored",
    }
    response = handler.handler(_event("/generate", "POST", request_body), None)

    assert response["statusCode"] == 200
    mock_client.converse.assert_called_once()
    assert mock_client.converse.call_args.kwargs["modelId"] == "test-model-id"


def test_generate_passes_through_optional_system_prompt() -> None:
    mock_client = MagicMock()
    mock_client.converse.return_value = {"output": {"message": {"content": []}}}
    handler._bedrock_client = mock_client

    request_body = {
        "system": [{"text": "You are a cookery expert."}],
        "messages": [{"role": "user", "content": [{"text": "hi"}]}],
        "toolConfig": {"tools": [{"toolSpec": {"name": "submit_recipe"}}]},
    }
    handler.handler(_event("/generate", "POST", request_body), None)

    assert mock_client.converse.call_args.kwargs["system"] == [
        {"text": "You are a cookery expert."}
    ]


@pytest.mark.parametrize(
    ("bedrock_code", "expected_status"),
    [
        ("ThrottlingException", 429),
        ("ServiceQuotaExceededException", 429),
        ("ValidationException", 400),
        ("AccessDeniedException", 403),
        ("ResourceNotFoundException", 404),
        ("ModelTimeoutException", 504),
        ("ModelNotReadyException", 503),
        ("SomeBrandNewExceptionAwsAddsLater", 502),
    ],
)
def test_generate_maps_bedrock_errors_to_specific_http_statuses(
    bedrock_code: str, expected_status: int
) -> None:
    mock_client = MagicMock()
    mock_client.converse.side_effect = ClientError(
        {"Error": {"Code": bedrock_code, "Message": f"{bedrock_code} happened"}},
        "Converse",
    )
    handler._bedrock_client = mock_client

    request_body = {
        "messages": [{"role": "user", "content": [{"text": "hi"}]}],
        "toolConfig": {"tools": [{"toolSpec": {"name": "submit_recipe"}}]},
    }
    response = handler.handler(_event("/generate", "POST", request_body), None)

    assert response["statusCode"] == expected_status
    # The real Bedrock error, not a paraphrase — see architecture.md,
    # "Error handling".
    body = json.loads(response["body"])
    assert bedrock_code in body["error"]
    assert f"{bedrock_code} happened" in body["error"]
