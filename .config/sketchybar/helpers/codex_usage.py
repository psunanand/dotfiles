#!/usr/bin/env python3

"""Read Codex account rate limits through the local app-server."""

from __future__ import annotations

from datetime import datetime
import json
import os
from pathlib import Path
import queue
import shutil
import subprocess
import sys
import threading
from typing import Any


DEFAULT_TIMEOUT_SECONDS = 3.0


class CodexUsageError(RuntimeError):
    """A recoverable error while querying Codex usage."""


def timeout_seconds() -> float:
    value = os.environ.get("CODEX_USAGE_TIMEOUT_SECONDS")
    if value is None:
        return DEFAULT_TIMEOUT_SECONDS

    try:
        timeout = float(value)
    except ValueError:
        return DEFAULT_TIMEOUT_SECONDS

    return timeout if timeout > 0 else DEFAULT_TIMEOUT_SECONDS


def codex_binary() -> str:
    configured = os.environ.get("CODEX_BIN")
    if configured:
        return os.path.expanduser(configured)

    if found := shutil.which("codex"):
        return found

    standalone = Path.home() / ".local" / "bin" / "codex"
    if standalone.is_file():
        return str(standalone)

    raise CodexUsageError("Could not find the codex executable")


def send(process: subprocess.Popen[str], message: dict[str, Any]) -> None:
    assert process.stdin is not None
    process.stdin.write(f"{json.dumps(message)}\n")
    process.stdin.flush()


def read_response(
    process: subprocess.Popen[str], expected_id: int, timeout: float
) -> dict[str, Any]:
    assert process.stdout is not None

    while True:
        lines: queue.Queue[str] = queue.Queue(maxsize=1)
        reader = threading.Thread(target=lambda: lines.put(process.stdout.readline()), daemon=True)
        reader.start()
        try:
            line = lines.get(timeout=timeout)
        except queue.Empty:
            raise CodexUsageError("Timed out waiting for Codex app-server")

        if not line:
            raise CodexUsageError("Codex app-server closed unexpectedly")

        try:
            message = json.loads(line)
        except json.JSONDecodeError as error:
            raise CodexUsageError("Codex app-server sent invalid JSON") from error

        if message.get("id") != expected_id:
            continue
        if "error" in message:
            raise CodexUsageError("Codex app-server request failed")

        result = message.get("result")
        if not isinstance(result, dict):
            raise CodexUsageError("Codex app-server returned an invalid response")
        return result


def format_reset(timestamp: object) -> str:
    if not isinstance(timestamp, int):
        return "unknown"

    try:
        return datetime.fromtimestamp(timestamp).strftime("%a %H:%M")
    except (OverflowError, OSError, ValueError):
        return "unknown"


def window_labels(duration_minutes: object) -> tuple[str, str]:
    if duration_minutes == 300:
        return "5-hour", "5h"
    if duration_minutes == 10080:
        return "Weekly", "W"
    if isinstance(duration_minutes, int) and duration_minutes > 0:
        if duration_minutes % 1440 == 0:
            days = duration_minutes // 1440
            return f"{days}-day", f"{days}d"
        if duration_minutes % 60 == 0:
            hours = duration_minutes // 60
            return f"{hours}-hour", f"{hours}h"
        return f"{duration_minutes}-minute", f"{duration_minutes}m"
    return "Usage", "Usage"


def format_window(window: object) -> dict[str, int | str] | None:
    if not isinstance(window, dict):
        return None

    used_percent = window.get("usedPercent")
    if not isinstance(used_percent, (int, float)) or isinstance(used_percent, bool):
        return None

    remaining = max(0, min(100, round(100 - used_percent)))
    label, short_label = window_labels(window.get("windowDurationMins"))
    return {
        "label": label,
        "short_label": short_label,
        "remaining": remaining,
        "reset": format_reset(window.get("resetsAt")),
    }


def rate_limits(result: dict[str, Any]) -> dict[str, Any]:
    by_limit_id = result.get("rateLimitsByLimitId")
    if isinstance(by_limit_id, dict) and isinstance(by_limit_id.get("codex"), dict):
        return by_limit_id["codex"]

    legacy = result.get("rateLimits")
    if isinstance(legacy, dict):
        return legacy

    raise CodexUsageError("Codex app-server returned no rate-limit data")


def usage_snapshot(result: dict[str, Any]) -> dict[str, list[dict[str, int | str]]]:
    limits = rate_limits(result)
    windows = [
        formatted
        for key in ("primary", "secondary")
        if (formatted := format_window(limits.get(key))) is not None
    ]
    return {"windows": windows}


def terminate(process: subprocess.Popen[str]) -> None:
    if process.poll() is not None:
        return

    process.terminate()
    try:
        process.wait(timeout=0.5)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait()


def main() -> int:
    process: subprocess.Popen[str] | None = None

    try:
        process = subprocess.Popen(
            [codex_binary(), "app-server", "--stdio"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            bufsize=1,
        )
        timeout = timeout_seconds()

        send(
            process,
            {
                "method": "initialize",
                "id": 1,
                "params": {
                    "clientInfo": {
                        "name": "sketchybar_codex_usage",
                        "title": "SketchyBar Codex Usage",
                        "version": "0.1.0",
                    }
                },
            },
        )
        read_response(process, 1, timeout)
        send(process, {"method": "initialized", "params": {}})
        send(process, {"method": "account/rateLimits/read", "id": 2, "params": None})

        print(json.dumps(usage_snapshot(read_response(process, 2, timeout))))
        return 0
    except (CodexUsageError, OSError) as error:
        print(json.dumps({"error": str(error)}))
        return 1
    finally:
        if process is not None:
            terminate(process)


if __name__ == "__main__":
    sys.exit(main())
