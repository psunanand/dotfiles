{
  inputs,
  username,
  hostname,
  system,
  ...
}:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";

    sharedModules = [
      inputs.mac-app-util.homeManagerModules.default
    ];

    extraSpecialArgs = {
      inherit inputs username hostname system;
    };

    users.${username}.imports = [
      ../home
    ];
  };
}
