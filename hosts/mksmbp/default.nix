{
  inputs,
  username,
  ...
}:

{
  imports = [
    ../../modules/darwin
  ];

  users.users.${username}.home = "/Users/${username}";

  system = {
    primaryUser = username;
    configurationRevision =
      if inputs.self ? rev then
        inputs.self.rev
      else if inputs.self ? dirtyRev then
        inputs.self.dirtyRev
      else
        null;
    stateVersion = 6;
  };
}
