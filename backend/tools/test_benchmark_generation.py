import io
import json
import unittest
from unittest.mock import patch
from benchmark_generation import measure_generation, summarize


class GenerationBenchmarkTests(unittest.TestCase):
    def test_success_requires_at_least_one_generated_route(self):
        class Response(io.BytesIO):
            status = 201
        with patch("urllib.request.OpenerDirector.open", return_value=Response(json.dumps({"rutas": [], "tiempo_calculo_ms": 10}).encode())):
            self.assertFalse(measure_generation("http://localhost:8080", "test-only-token", 45000, 0)["passed"])

    def test_http_error_is_not_passed(self):
        class Response(io.BytesIO):
            status = 403
        with patch("urllib.request.OpenerDirector.open", return_value=Response(b"{}")):
            self.assertFalse(measure_generation("http://localhost:8080", "test-only-token", 45000, 0)["passed"])

    def test_report_uses_nearest_rank_p95(self):
        report = summarize([{"elapsed_ms": 100, "passed": True}, {"elapsed_ms": 45001, "passed": False}], 45000)
        self.assertFalse(report["passed"])
        self.assertEqual(report["p95_ms"], 45001)


if __name__ == "__main__":
    unittest.main()
