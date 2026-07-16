#!/usr/bin/env python3

import os
from pathlib import Path
import stat
import subprocess
import tempfile
import textwrap
import unittest


ROOT = Path(__file__).resolve().parents[1]
PLUGINS = ROOT / "plugins"


FAKE_AEROSPACE = r"""#!/usr/bin/env bash
printf '%s\n' "$*" >> "$AEROSPACE_LOG"

if [[ "$*" == "list-workspaces --focused" ]]; then
  printf '%s\n' "$MOCK_FOCUSED_WORKSPACE"
elif [[ "$*" == 'list-workspaces --monitor all --format %{workspace} %{monitor-appkit-nsscreen-screens-id}' ]]; then
  printf '%b' "$MOCK_WORKSPACES"
elif [[ "$*" == $'list-windows --monitor all --format %{workspace}\t%{app-name}' ]]; then
  printf '%b' "$MOCK_WINDOWS"
fi
"""


FAKE_SKETCHYBAR = r"""#!/usr/bin/env bash
printf '%s\n' "$*" >> "$SKETCHYBAR_LOG"
"""


FAKE_OSASCRIPT = r"""#!/usr/bin/env bash
printf '%s\n' "$*" >> "$OSASCRIPT_LOG"
if [[ "$*" == *"output volume of"* ]]; then
  printf '%s\n' "$MOCK_VOLUME"
fi
"""


FAKE_PMSET = r"""#!/usr/bin/env bash
printf '%b' "$MOCK_BATTERY"
"""


class PluginCommandTests(unittest.TestCase):
    def make_command(self, directory, name, contents):
        command = Path(directory) / name
        command.write_text(textwrap.dedent(contents))
        command.chmod(command.stat().st_mode | stat.S_IXUSR)

    def environment(self, directory):
        return os.environ | {
            "PATH": f"{directory}:{os.environ['PATH']}",
            "CONFIG_DIR": str(ROOT),
            "NAME": "test_item",
            "SKETCHYBAR_LOG": str(Path(directory) / "sketchybar.log"),
            "AEROSPACE_LOG": str(Path(directory) / "aerospace.log"),
            "OSASCRIPT_LOG": str(Path(directory) / "osascript.log"),
            "MOCK_FOCUSED_WORKSPACE": "2",
            "MOCK_WORKSPACES": "1 1\n2 1\n3 1\n4 1\n5 1\n6 1\n7 1\n",
            "MOCK_WINDOWS": "",
            "MOCK_VOLUME": "50",
            "MOCK_BATTERY": (
                "Now drawing from 'AC Power'\n"
                " -InternalBattery-0 (id=1)\\t100%; discharging; "
                "11:52 remaining present: true\n"
            ),
            "SKETCHYBAR_STATE_DIR": str(directory),
        }

    def run_plugin(self, plugin, **overrides):
        with tempfile.TemporaryDirectory() as directory:
            self.make_command(directory, "sketchybar", FAKE_SKETCHYBAR)
            self.make_command(directory, "osascript", FAKE_OSASCRIPT)
            self.make_command(directory, "pmset", FAKE_PMSET)
            environment = self.environment(directory) | overrides

            result = subprocess.run(
                ["bash", str(PLUGINS / plugin)],
                capture_output=True,
                check=False,
                env=environment,
                text=True,
            )
            sketchybar_log = Path(environment["SKETCHYBAR_LOG"])
            return result, sketchybar_log.read_text() if sketchybar_log.exists() else ""

    def run_workspace_observer(self, **overrides):
        with tempfile.TemporaryDirectory() as directory:
            self.make_command(directory, "aerospace", FAKE_AEROSPACE)
            self.make_command(directory, "sketchybar", FAKE_SKETCHYBAR)
            environment = self.environment(directory) | overrides

            result = subprocess.run(
                ["bash", str(PLUGINS / "aerospace.sh")],
                capture_output=True,
                check=False,
                env=environment,
                text=True,
            )
            sketchybar_log = Path(environment["SKETCHYBAR_LOG"])
            aerospace_log = Path(environment["AEROSPACE_LOG"])
            return (
                result,
                sketchybar_log.read_text() if sketchybar_log.exists() else "",
                aerospace_log.read_text() if aerospace_log.exists() else "",
            )

    def test_focused_empty_workspace_remains_visible(self):
        result, sketchybar, _ = self.run_workspace_observer()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("--set space.2", sketchybar)
        self.assertIn("background.color=0xffa7c080", sketchybar)
        self.assertRegex(sketchybar, r"--set space\.1 .*drawing=off")

    def test_apps_are_deduplicated_and_overflow_follows_two_icons(self):
        result, sketchybar, aerospace = self.run_workspace_observer(
            MOCK_FOCUSED_WORKSPACE="1",
            MOCK_WINDOWS=(
                "1\\tGoogle Chrome\\n"
                "1\\tGoogle Chrome\\n"
                "1\\tkitty\\n"
                "1\\tNotes\\n"
                "1\\tSlack\\n"
            ),
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(sketchybar.count("icon.background.image=app.Google Chrome"), 1)
        self.assertIn("icon.background.image=app.kitty", sketchybar)
        self.assertIn("label=+2", sketchybar)
        self.assertEqual(aerospace.count("list-windows"), 1)
        self.assertIn("list-windows --monitor all", aerospace)

    def test_workspace_and_apps_follow_aerospace_monitor_assignment(self):
        result, sketchybar, _ = self.run_workspace_observer(
            MOCK_FOCUSED_WORKSPACE="7",
            MOCK_WORKSPACES="1 1\n2 1\n3 1\n4 1\n5 1\n6 1\n7 42\n",
            MOCK_WINDOWS="7\\tkitty\\n",
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertRegex(sketchybar, r"--set space\.7 .*display=42")
        self.assertRegex(sketchybar, r"--set space\.7\.app1 .*display=42")

    def test_battery_accepts_pmset_tab_before_percentage(self):
        result, sketchybar = self.run_plugin("battery.sh", NAME="battery")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("--set battery icon=", sketchybar)
        self.assertIn("label=100%", sketchybar)

    def test_front_app_updates_only_the_dynamic_app_segment(self):
        result, sketchybar = self.run_plugin(
            "front_app.sh",
            NAME="front_app",
            INFO="Safari",
            SENDER="front_app_switched",
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("label=Safari", sketchybar)
        self.assertIn("icon.background.image=app.Safari", sketchybar)
        self.assertNotIn("front_app.badge", sketchybar)
        self.assertNotIn("background.border_width", sketchybar)

    def test_every_right_side_popup_uses_the_shared_right_aligned_style(self):
        config = (ROOT / "sketchybarrc").read_text()

        ui = (PLUGINS / "ui.sh").read_text()
        self.assertIn("popup.align=right", ui)

        for item in ("clock", "battery", "volume", "network", "usage", "codex_usage"):
            block = config.split(f"sketchybar --add item {item} right", 1)[1].split(
                "sketchybar --add item ", 1
            )[0]
            self.assertIn('${POPUP_STYLE[@]}', block, item)

    def test_popup_rows_use_fixed_width_muted_semantic_icons(self):
        config = (ROOT / "sketchybarrc").read_text()
        ui = (PLUGINS / "ui.sh").read_text()

        self.assertIn("icon.drawing=on", ui)
        self.assertIn("icon.width=16", ui)
        self.assertIn('icon.color="$THEME_MUTED"', ui)
        self.assertIn('local icon="$3"', config)
        self.assertIn('icon="$icon"', config)

        expected_rows = (
            "clock.popup.date clock",
            "clock.popup.time clock",
            "battery.popup.power battery",
            "battery.popup.estimate battery",
            "volume.popup.level volume",
            "network.popup.ssid network",
            "network.popup.speed network",
            "usage.popup.cpu usage",
            "usage.popup.ram usage",
            "usage.popup.disk usage",
            "codex_usage.popup.primary codex_usage",
            "codex_usage.popup.primary_reset codex_usage",
            "codex_usage.popup.secondary codex_usage",
            "codex_usage.popup.secondary_reset codex_usage",
        )
        for row in expected_rows:
            self.assertRegex(config, rf"add_popup_row {row} \S+")

    def test_front_app_has_stable_active_badge_and_group(self):
        config = (ROOT / "sketchybarrc").read_text()

        self.assertRegex(
            config,
            r"(?s)--add item front_app\.badge left.*?display=active.*?label=ACTIVE",
        )
        self.assertRegex(
            config,
            r"(?s)--add item front_app left.*?display=active.*?script=\"\$PLUGIN_DIR/front_app\.sh\"",
        )
        self.assertRegex(
            config,
            r"(?s)--add bracket front_app\.group front_app\.badge front_app.*?display=active",
        )
        group = config.split("--add bracket front_app.group", 1)[1].split(
            "# Right-side items", 1
        )[0]
        self.assertIn("background.height=26", group)
        self.assertIn("background.corner_radius=8", group)
        self.assertIn('"background.color=$THEME_POPUP"', group)
        self.assertIn('"background.border_color=$THEME_FOCUSED"', group)
        self.assertIn("background.border_width=1", group)

    def test_battery_formats_power_state_and_remaining_time_compactly(self):
        result, sketchybar = self.run_plugin("battery.sh", NAME="battery")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("label=AC Power · Discharging", sketchybar)
        self.assertIn("label=11h 52m remaining", sketchybar)

    def test_battery_uses_clear_fallbacks_without_an_estimate(self):
        result, sketchybar = self.run_plugin(
            "battery.sh",
            NAME="battery",
            MOCK_BATTERY=(
                "Now drawing from 'Battery Power'\n"
                " -InternalBattery-0 (id=1)\\t43%; charged; (no estimate) "
                "present: true\n"
            ),
        )

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("label=Battery Power · Charged", sketchybar)
        self.assertIn("label=Estimate unavailable", sketchybar)

    def test_volume_does_not_subscribe_to_or_advertise_scrolling(self):
        config = (ROOT / "sketchybarrc").read_text()
        volume_script = (PLUGINS / "volume.sh").read_text()

        volume_block = config.split("sketchybar --add item volume right", 1)[1].split(
            "sketchybar --add item network right", 1
        )[0]
        self.assertNotIn("mouse.scrolled", volume_block)
        self.assertNotIn("volume.popup.hint", volume_block)
        self.assertNotIn("Scroll to adjust", volume_script)


if __name__ == "__main__":
    unittest.main()
