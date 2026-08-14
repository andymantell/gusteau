"""Gusteau inference proxy.

A thin relay, deliberately with no cookery domain logic: the app
assembles the full Bedrock Converse request (system prompt, messages,
the Recipe tool schema) on-device, per
docs/planning/architecture.md, "The structured-output contract" and
"On-device prompt assembly". This Lambda's only jobs are (1) enforcing
which model actually gets called — server-side, so a compromised or
modified client can't switch to a more expensive one — and (2) relaying
Bedrock's response, including its real errors, back to the caller
unparaphrased. See architecture.md, "Error handling": "show the real
failure... Bedrock returned 400: model x not enabled in eu-west-2
rather than Couldn't get suggestions."

Stateless: nothing is stored, nothing is logged beyond token counts and
latency (handled by API Gateway access logs, not here) — never prompt
or completion bodies. See architecture.md, "Security posture".
"""

from __future__ import annotations

import json
import os
import time
from typing import Any

import boto3
from botocore.exceptions import ClientError

# Constructed lazily, not at import time: boto3.client() needs a
# resolvable region, which only exists in the real Lambda runtime (set
# automatically there) — not in pytest/CI, which imports this module
# with no AWS config at all. Also makes the client trivially mockable
# in tests.
_bedrock_client: Any = None


def _bedrock() -> Any:
    global _bedrock_client
    if _bedrock_client is None:
        # Explicit region, not the Lambda's own — BEDROCK_REGION may
        # (and currently does) point somewhere other than where this
        # function is deployed. See proxy_stack.py's bedrock_region
        # parameter for why.
        _bedrock_client = boto3.client("bedrock-runtime", region_name=os.environ["BEDROCK_REGION"])
    return _bedrock_client


# Error codes Bedrock actually returns, mapped to the HTTP status the
# app should see. Never a bare 500 for something Bedrock told us
# specifically — see architecture.md, "Distinguish transient from
# terminal".
_BEDROCK_ERROR_STATUS = {
    "ThrottlingException": 429,
    "ServiceQuotaExceededException": 429,
    "ValidationException": 400,
    "ModelErrorException": 400,
    "AccessDeniedException": 403,
    "ResourceNotFoundException": 404,
    "ModelTimeoutException": 504,
    "ModelNotReadyException": 503,
}


def handler(event: dict[str, Any], _context: Any) -> dict[str, Any]:
    path = event.get("path", "")
    method = event.get("httpMethod", "")

    if path == "/health" and method == "GET":
        body = {
            "status": "ok",
            "service": "gusteau-inference-proxy",
            "time": int(time.time()),
        }
        return _response(200, body)

    if path == "/generate" and method == "POST":
        return _generate(event)

    return _response(404, {"error": f"no route for {method} {path}"})


def _generate(event: dict[str, Any]) -> dict[str, Any]:
    try:
        request = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError as e:
        return _response(400, {"error": f"invalid JSON body: {e}"})

    messages = request.get("messages")
    if not isinstance(messages, list) or not messages:
        return _response(400, {"error": "'messages' is required and must be a non-empty list"})

    tool_config = request.get("toolConfig")
    if not isinstance(tool_config, dict) or not tool_config.get("tools"):
        return _response(400, {"error": "'toolConfig' with at least one tool is required"})

    converse_kwargs: dict[str, Any] = {
        # Server-controlled, not read from the request — see module
        # docstring. A compromised client can change prompts, not spend.
        "modelId": os.environ["BEDROCK_MODEL_ID"],
        "messages": messages,
        "toolConfig": tool_config,
    }
    system = request.get("system")
    if system is not None:
        converse_kwargs["system"] = system

    try:
        result = _bedrock().converse(**converse_kwargs)
    except ClientError as e:
        error = e.response.get("Error", {})
        code = error.get("Code", "UnknownError")
        message = error.get("Message", str(e))
        status = _BEDROCK_ERROR_STATUS.get(code, 502)
        return _response(status, {"error": f"Bedrock {code}: {message}"})

    # converse()'s response is already JSON-safe (no datetimes/bytes),
    # unlike some other boto3 APIs — plain json.dumps is fine.
    return _response(200, result)


def _response(status_code: int, body: dict[str, Any]) -> dict[str, Any]:
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }
