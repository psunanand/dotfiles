{
	username,
	...
}:
{
 	nix = {
		settings = {
		trusted-users = [username];
		experimental-features = "nix-command flakes";
		# Not working on MacOS: https://github.com/NixOS/nix/issues/7273		
		auto-optimise-store = false;
		warn-dirty = false;

		# https://jackson.dev/post/nix-reasonable-defaults/
		connect-timeout = 5;
		log-lines = 25;
		min-free = 128000000; # 128MB
		max-free = 1000000000; # 1GB
	};

    # on schedule detect files with identical contents and hard link to a single copy to save disk space by default nix.optimise.interval
    # similar to `auto-optimise-store = true;` but doesn't corrupt nix-store
    optimise = {
	automatic = true;
	interval.Hour = 6;
    };

    # automatically run garbage collector
    gc = {
	automatic = true;
	interval.Hour = 6;
	options = "--delete-older-than 7d";
    };


};
}
