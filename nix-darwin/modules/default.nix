{
  lib,
  ...
}:
let
  currentDirectory = ./.;
  # Don't need to traverse into subdirectories
  moduleNixFiles = map (fname: currentDirectory + "/${fname}") (
    builtins.filter (fname: lib.hasSuffix ".nix" fname && fname != "default.nix") (
      builtins.attrNames (builtins.readDir currentDirectory)
    )
  );

in
{
  imports = moduleNixFiles;
}
