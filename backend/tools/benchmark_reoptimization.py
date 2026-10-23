"""Measure real HTTP latency of prepared reoptimization events on a dedicated test/staging dataset.

Standard library only. Never prints the bearer token or order/driver data.
Each event receives a fresh id so an idempotent replay cannot masquerade as a fast recalculation.
"""
import argparse
from concurrent.futures import ThreadPoolExecutor
import json
import math
import os
from pathlib import Path
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, request, fp, code, message, headers, new_url):
        return None


def fresh_event(payload):
    event = dict(payload)
    event["evento_id"] = str(uuid.uuid4())
    return event


def measure(base_url, token, payload, sla_ms):
    event = fresh_event(payload)
    request = urllib.request.Request(
        base_url.rstrip("/") + "/api/v1/rutas/reoptimizar",
        data=json.dumps(event).encode("utf-8"),
        headers={"Content-Type": "application/json", "Authorization": "Bearer " + token},
        method="POST",
    )
    started = time.perf_counter()
    status, changed, server_ms = None, 0, None
    error = None
    try:
        with urllib.request.build_opener(NoRedirect()).open(request, timeout=sla_ms / 1000) as response:
            status = response.status
            body = json.loads(response.read())
            changed = len(body.get("rutas_reoptimizadas", []))
            server_ms = body.get("tiempo_calculo_ms")
    except urllib.error.HTTPError as failure:
        status, error = failure.code, "http_error"
    except (urllib.error.URLError, TimeoutError, OSError, ValueError):
        error = "network_timeout_or_invalid_response"
    elapsed = (time.perf_counter() - started) * 1000
    if error is None and changed == 0:
        error = "no_affected_route_recalculated"
    return {
        "evento_id": event["evento_id"], "tipo": event.get("tipo"), "http_status": status,
        "elapsed_ms": round(elapsed, 3), "server_calculation_ms": server_ms,
        "changed_routes": changed, "error": error,
        "passed": error is None and status == 200 and elapsed < sla_ms,
    }


def summarize(samples, sla_ms):
    values = sorted(sample["elapsed_ms"] for sample in samples)
    return {
        "samples": len(samples), "sla_ms": sla_ms,
        "max_ms": max(values), "p95_ms": values[max(0, math.ceil(len(values) * .95) - 1)],
        "passed": all(sample["passed"] for sample in samples), "results": samples,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-url", required=True, help="Staging/test origin, e.g. https://staging.example.test")
    parser.add_argument("--events", required=True, type=Path, help="JSON array of independent, prepared events; mutates their test routes")
    parser.add_argument("--concurrency", type=int, default=1)
    parser.add_argument("--sla-ms", type=int, default=30000)
    parser.add_argument("--output", type=Path, default=Path("target/reoptimization-staging.json"))
    args = parser.parse_args()
    origin = urllib.parse.urlsplit(args.base_url)
    if origin.scheme not in ("http", "https") or not origin.netloc or origin.path not in ("", "/") or origin.username or origin.query or origin.fragment:
        parser.error("base-url must be an HTTP(S) origin without credentials, path or query")
    if not 1 <= args.concurrency <= 16 or not 0 < args.sla_ms <= 30000:
        parser.error("concurrency must be 1..16 and sla-ms 1..30000")
    token = os.environ.get("PATHSEEK_BENCH_TOKEN", "")
    if not token:
        parser.error("Set PATHSEEK_BENCH_TOKEN to an ADMIN/OPERADOR JWT for the test environment")
    events = json.loads(args.events.read_text(encoding="utf-8-sig"))
    if not isinstance(events, list) or not events or any(not isinstance(event, dict) for event in events):
        parser.error("events must be a nonempty JSON array of event objects")
    with ThreadPoolExecutor(max_workers=args.concurrency) as workers:
        samples = list(workers.map(lambda event: measure(args.base_url, token, event, args.sla_ms), events))
    report = summarize(samples, args.sla_ms)
    report["concurrency"] = args.concurrency
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps({key: value for key, value in report.items() if key != "results"}))
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
