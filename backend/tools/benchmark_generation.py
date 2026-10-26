"""Measure real HTTP latency of route generation (EN-001/EN-005) on a dedicated test/staging dataset.

Standard library only. Never prints the bearer token or order/driver data.
Run against a dedicated environment: every generation consumes PENDIENTE orders.
If --seed N is given, N synthetic orders are created through the API before each run.
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


def seed_order(base_url, token, index):
    payload = {
        "cliente_id": "bench-" + str(uuid.uuid4()),
        "direccion": "Carga sintetica " + str(index),
        "gps_lat": -12.06 - (index % 40) * 0.0009,
        "gps_lon": -75.20 - (index % 30) * 0.0006,
        "peso": 10,
        "volumen": 1,
        "ventana_inicio": "07:00",
        "ventana_fin": "23:00",
        "prioridad": "EXPRESS" if index % 5 == 0 else "ESTANDAR",
        "tipo_producto": "NO_PERECEDERO",
    }
    request = urllib.request.Request(
        base_url.rstrip("/") + "/api/v1/pedidos",
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json", "Authorization": "Bearer " + token},
        method="POST",
    )
    with urllib.request.build_opener(NoRedirect()).open(request, timeout=60) as response:
        if response.status != 201:
            raise RuntimeError("seed failed with HTTP " + str(response.status))


def seed_orders(base_url, token, count):
    for index in range(count):
        seed_order(base_url, token, index)


def measure_generation(base_url, token, sla_ms, seed):
    if seed:
        seed_orders(base_url, token, seed)
    request = urllib.request.Request(
        base_url.rstrip("/") + "/api/v1/rutas/generar",
        data=b"",
        headers={"Authorization": "Bearer " + token},
        method="POST",
    )
    started = time.perf_counter()
    status, created, server_ms = None, 0, None
    error = None
    try:
        with urllib.request.build_opener(NoRedirect()).open(request, timeout=sla_ms / 1000) as response:
            status = response.status
            body = json.loads(response.read())
            created = len(body.get("rutas", []))
            server_ms = body.get("tiempo_calculo_ms")
    except urllib.error.HTTPError as failure:
        status, error = failure.code, "http_error"
    except (urllib.error.URLError, TimeoutError, OSError, ValueError):
        error = "network_timeout_or_invalid_response"
    elapsed = (time.perf_counter() - started) * 1000
    if error is None and created == 0:
        error = "no_route_generated"
    return {
        "http_status": status, "elapsed_ms": round(elapsed, 3),
        "server_calculation_ms": server_ms, "created_routes": created,
        "error": error, "passed": error is None and status == 201 and elapsed < sla_ms,
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
    parser.add_argument("--runs", type=int, default=20, help="Generation runs to measure")
    parser.add_argument("--sla-ms", type=int, default=45000)
    parser.add_argument("--concurrency", type=int, default=1)
    parser.add_argument("--seed", type=int, default=0, help="Synthetic PENDIENTE orders created per run (0 = dataset already prepared)")
    parser.add_argument("--output", type=Path, default=Path("target/generation-staging.json"))
    args = parser.parse_args()
    origin = urllib.parse.urlsplit(args.base_url)
    if origin.scheme not in ("http", "https") or not origin.netloc or origin.path not in ("", "/") or origin.username or origin.query or origin.fragment:
        parser.error("base-url must be an HTTP(S) origin without credentials, path or query")
    if not 1 <= args.runs <= 100 or not 1 <= args.concurrency <= 16 or not 0 < args.sla_ms <= 60000 or args.seed < 0 or args.seed > 2000:
        parser.error("runs must be 1..100, concurrency 1..16, sla-ms 1..60000 and seed 0..2000")
    token = os.environ.get("PATHSEEK_BENCH_TOKEN", "")
    if not token:
        parser.error("Set PATHSEEK_BENCH_TOKEN to an ADMIN/OPERADOR JWT for the test environment")
    runs = list(range(args.runs))
    with ThreadPoolExecutor(max_workers=args.concurrency) as workers:
        samples = list(workers.map(lambda _: measure_generation(args.base_url, token, args.sla_ms, args.seed), runs))
    report = summarize(samples, args.sla_ms)
    report["concurrency"] = args.concurrency
    report["seeded_orders_per_run"] = args.seed
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps({key: value for key, value in report.items() if key != "results"}))
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
