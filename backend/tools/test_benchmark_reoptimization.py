import io
import json
import unittest
from unittest.mock import patch
from benchmark_reoptimization import fresh_event, measure, summarize


class BenchmarkTests(unittest.TestCase):
    def test_requests_cannot_reuse_an_idempotency_result(self):
        original = {"evento_id": "old", "tipo": "NUEVOS_PEDIDOS"}
        self.assertNotEqual(fresh_event(original)["evento_id"], fresh_event(original)["evento_id"])
        self.assertEqual(original["evento_id"], "old")

    def test_http_success_requires_actual_recalculation(self):
        class Response(io.BytesIO):
            status = 200
        with patch("urllib.request.OpenerDirector.open", return_value=Response(json.dumps({"rutas_reoptimizadas": []}).encode())):
            self.assertFalse(measure("http://localhost:8080", "test-only-token", {"tipo": "INCIDENTE"}, 30000)["passed"])

    def test_report_fails_on_any_sla_failure_and_uses_nearest_rank_percentile(self):
        report = summarize([{"elapsed_ms": 20, "passed": True}, {"elapsed_ms": 30001, "passed": False}], 30000)
        self.assertFalse(report["passed"])
        self.assertEqual(report["p95_ms"], 30001)


if __name__ == "__main__":
    unittest.main()
