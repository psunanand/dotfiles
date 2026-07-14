#!/usr/bin/env python3

import json
import os
from pathlib import Path
import stat
import subprocess
import sys
import tempfile
import textwrap
import unittest


HELPER = Path(__file__).resolve().parents[1] / "helpers" / "codex_usage.py"


FAKE_CODEX = """\
#!/usr/bin/env python3
import json
import os
import sys
import time

response = json.loads(os.environ["FAKE_CODEX_RESPONSE"])

for line in sys.stdin:
    message = json.loads(line)
    if message.get("id") == 1:
        print(json.dumps({"id": 1, "result": {}}), flush=True)
    elif message.get("id") == 2:
        if response == "timeout":
            time.sleep(10)
        elif response == "error":
            print(json.dumps({"id": 2, "error": {"message": "not signed in"}}), flush=True)
        else:
            print(json.dumps({"id": 2, "result": response}), flush=True)
"""


class CodexUsageHelperTests(unittest.TestCase):
    def run_helper(self, response):
        with tempfile.TemporaryDirectory() as temp_dir:
            codex = Path(temp_dir) / "codex"
            codex.write_text(textwrap.dedent(FAKE_CODEX))
            codex.chmod(codex.stat().st_mode | stat.S_IXUSR)

            environment = os.environ | {
                "CODEX_BIN": str(codex),
                "CODEX_USAGE_TIMEOUT_SECONDS": "0.5",
                "FAKE_CODEX_RESPONSE": json.dumps(response),
                "TZ": "UTC",
            }
            return subprocess.run(
                [sys.executable, str(HELPER)],
                capture_output=True,
                check=False,
                env=environment,
                text=True,
                timeout=5,
            )

    def test_labels_a_single_weekly_window_from_its_duration(self):
        result = self.run_helper(
            {
                "rateLimitsByLimitId": {
                    "codex": {
                        "primary": {
                            "usedPercent": 28,
                            "resetsAt": 0,
                            "windowDurationMins": 10080,
                        }
                    }
                },
            }
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            json.loads(result.stdout),
            {
                "windows": [
                    {
                        "label": "Weekly",
                        "short_label": "W",
                        "remaining": 72,
                        "reset": "Thu 00:00",
                    }
                ]
            },
        )

    def test_preserves_primary_and_secondary_windows_in_duration_order(self):
        result = self.run_helper(
            {
                "rateLimits": {
                    "primary": {
                        "usedPercent": 11,
                        "resetsAt": 0,
                        "windowDurationMins": 300,
                    },
                    "secondary": {
                        "usedPercent": 61,
                        "resetsAt": 0,
                        "windowDurationMins": 10080,
                    },
                }
            }
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            json.loads(result.stdout),
            {
                "windows": [
                    {
                        "label": "5-hour",
                        "short_label": "5h",
                        "remaining": 89,
                        "reset": "Thu 00:00",
                    },
                    {
                        "label": "Weekly",
                        "short_label": "W",
                        "remaining": 39,
                        "reset": "Thu 00:00",
                    },
                ]
            },
        )

    def test_reports_unavailable_windows_without_inventing_values(self):
        result = self.run_helper({"rateLimits": {"primary": None, "secondary": None}})

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout), {"windows": []})

    def test_reports_json_rpc_errors(self):
        result = self.run_helper("error")

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(
            json.loads(result.stdout), {"error": "Codex app-server request failed"}
        )

    def test_times_out_when_app_server_stops_responding(self):
        result = self.run_helper("timeout")

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(json.loads(result.stdout), {"error": "Timed out waiting for Codex app-server"})


if __name__ == "__main__":
    unittest.main()
