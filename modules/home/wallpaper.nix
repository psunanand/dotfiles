{ lib, pkgs, username, ... }:

let
  wallpaper = ../../wallpapers/green_forest_2.png;
  wallpaperDirectory = "/Users/${username}/Pictures/Wallpapers";
  appliedWallpaper = "${wallpaperDirectory}/green_forest_2.png";
  logFile = "/Users/${username}/Library/Logs/nix-wallpaper.log";
  setWallpaper = pkgs.writeShellScript "set-wallpaper" ''
    timestamp() {
      /bin/date '+%Y-%m-%dT%H:%M:%S%z'
    }

    echo "$(timestamp): setting wallpaper to ${appliedWallpaper}"
    if /usr/bin/osascript -e 'tell application "System Events" to set picture of every desktop to POSIX file "${appliedWallpaper}"'; then
      current_picture="$(/usr/bin/osascript -e 'tell application "System Events" to get picture of every desktop')"
      echo "$(timestamp): wallpaper set; macOS reports $current_picture"
    else
      status=$?
      echo "$(timestamp): failed to set wallpaper (exit $status)" >&2
      exit "$status"
    fi
  '';
in
{
  home.activation.installWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    /usr/bin/install -d -m 0755 "${wallpaperDirectory}"
    /usr/bin/install -m 0644 "${wallpaper}" "${appliedWallpaper}"
  '';

  # A LaunchAgent has the logged-in user's Aqua session, unlike nix-darwin's
  # root activation script. macOS may still ask the user to permit osascript
  # automation of System Events the first time this runs.
  launchd.agents.set-wallpaper = {
    enable = true;
    config = {
      Label = "org.nixos.set-wallpaper";
      ProgramArguments = [ "${setWallpaper}" ];
      RunAtLoad = true;
      ProcessType = "Interactive";
      StandardOutPath = logFile;
      StandardErrorPath = logFile;
    };
  };
}
