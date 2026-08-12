"""Gusteau inference proxy — iteration 0.

Proves the path end to end (device -> API key -> API Gateway -> Lambda ->
response) with no Bedrock calls, since no model has been chosen yet (that's
the iteration-1 spike). Real generation lands here in iteration 1, per the
structured-output contract in docs/planning/architecture.md.

Stateless: nothing is stored, nothing is logged beyond token counts and
latency (handled by API Gateway access logs, not here) — never prompt or
completion bodies. See architecture.md, "Security posture".
"""

from __future__ import annotations

import json
import time
from typing import Any


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

    return _response(404, {"error": f"no route for {method} {path}"})


def _response(status_code: int, body: dict[str, Any]) -> dict[str, Any]:
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }
