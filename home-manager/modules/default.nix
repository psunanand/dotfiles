{
  lib,
  ...
}:
let
  currentDirectory = ./.;

  scanModuleNixFiles =
    directory:
    lib.flatten (
      lib.mapAttrsToList (
        fname: type:
        let
          path = "${directory}/${fname}";
        in
        if type == "directory" then
          scanModuleNixFiles path
        else if type == "regular" && lib.hasSuffix ".nix" fname && fname != "default.nix" then
          [ path ]
        else
          [ ]
      ) (builtins.readDir directory)
    );
in
{
  imports = scanModuleNixFiles currentDirectory;
}
