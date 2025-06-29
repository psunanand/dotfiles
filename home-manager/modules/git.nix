{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.git = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Git";
    };
  };

  config = lib.mkIf config.git.enable {
    # Version controla: https://git-scm.com
    programs.git = {
      enable = true;
      userName = "psunanand";
      userEmail = "p.sunanand@gmail.com";
      extraConfig = {
        init = {
          defaultBranch = "main";
        };

        core = {
          editor = "${lib.getExe pkgs.neovim}";
          pager = "${lib.getExe pkgs.delta}";
          # Treat spaces before tabs and all kinds of trailing whitespace as an error
          # [default] trailing-space: looks for spaces at the end of a line
          # [default] space-before-tab: looks for spaces before tabs at the beginning of a line
          whitespace = "space-before-tab,-indent-with-non-tab,trailing-space";
          # Make `git rebase` safer on MacOS: <http://www.git-tower.com/blog/make-git-rebase-safe-on-osx/>
          trustctime = false;
        };

        pull = {
          rebase = "interactive";
        };

        push = {
          autoSetupRemote = true;
          followTags = true;
        };

        interactive = {
          diffFilter = "delta --color-only";
        };

        merge = {
          tool = "nvimdiff";
          conflictstyle = "zdiff3";
        };

        rebase = {
          autosquash = true;
          autoStash = true;
        };

        delta = {
          enable = true;
          options = {
            navigate = true;
            dark = true;
            side-by-side = true;
            line-numbers = true;
          };
        };

        commit = {
          verbose = true;
          template = builtins.toFile "commit-template.txt" ''
            # <type>(<scope>): <subject> (Max 50 chars)
            # Summary, imperative, start upper case, don't end with a period
            # <------------------------------------------------>

            # <body> (Wrap at 72 chars)
            # Explain *what* and *why* this change was made (not *how*).
            # <---------------------------------------------------------------------->

            # Examples of <type>:
            #   feat     (new feature)
            #   fix      (bug fix)
            #   docs     (documentation changes)
            #   style    (formatting, etc; no code change)
            #   refactor (refactoring code)
            #   test     (adding tests, refactoring tests)
            #   chore    (updating dependencies, build tasks, etc)
          '';
        };

        rerere = {
          enabled = true;
          autoupdate = true;
        };

        branch.sort = "-committerdate";
        tag.sort = "version:refname";

        blame = {
          coloring = "repeatedLines";
          markIgnoredLines = true;
          markUnblamables = true;
        };

        fetch = {
          prune = true;
          pruneTags = true;
        };

      };

      ignores = [
        ".git"
        ".vim"
        ".idea/"
        "out/"
        "local.properties"
        "/.ipynb_checkpoints"
        "*.o"
        "*.so"
        "*.7z"
        "*.dmg"
        "*.gz"
        "*.iso"
        "*.rar"
        "*.tar"
        "*.zip"
        ".DS_Store"
        ".DS_Store?"
        "Icon?"
        "Thumbs.db"
        "**/__pycache__/**"
        "*.py[cod]"
        "*$py.class"
        ".Python"
        "build/**"
        "dist/**"
        "sdist/"
        "wheels/"
        "node_modules/"
      ];

      # Take some from https://github.com/mathiasbynens/dotfiles/blob/0cd43d175a25c0e13e1e06ab31ccfd9f0169cf73/.gitconfig.
      aliases = {
        # Add
        a = "add";
        aa = "add --all";
        au = "add --update";

        # Blame, following history across renames.
        bl = "blame -w -C -C -C";

        # Undo
        u = "reset --soft HEAD~1";

        # View abbreviated SHA, description, and history graph of the latest 20 commits.
        l = "log --pretty=oneline -n 20 --graph --abbrev-commit";

        # View the current working tree status using the short format.
        s = "status -s";

        # Show the diff between the latest commit and the current state.
        d = "!git diff-index --quiet HEAD -- || clear; git --no-pager diff --patch-with-stat";

        # `git di $number` shows the diff between the state `$number` revisions ago and the current state.
        di = "!d() { git diff --patch-with-stat HEAD~$1; }; git diff-index --quiet HEAD -- || clear; d";

        # Pull in remote changes for the current repository and all its submodules.
        pl = "pull --recurse-submodules";

        # Clone a repository including all submodules.
        c = "clone --recursive";

        # Commit
        co = "commit -v";
        coa = "commit -v --amend";

        # Push
        p = "push";
        po = "push origin";
        pf = "push --force-with-lease";

        # Switch to a branch, creating it if necessary.
        go = "!f() { git checkout -b \"$1\" 2> /dev/null || git checkout \"$1\"; }; f";

        # Show verbose output about tags, branches or remotes
        tags = "tag -l";
        branches = "branch --all";
        remotes = "remote --verbose";

        # List aliases.
        aliases = "config --get-regexp alias";

        # Amend the currently staged files to the latest commit.
        amend = "commit --amend --reuse-message=HEAD";

        # Interactive rebase with the given number of latest commits.
        reb = "!r() { git rebase -i HEAD~$1; }; r";

        # Find branches containing commit
        fb = "!f() { git branch -a --contains $1; }; f";

        # Find commits by source code
        fc = "!f() { git log --pretty=format:'%C(yellow)%h  %Cblue%ad  %Creset%s%Cgreen  [%cn] %Cred%d' --decorate --date=short -S$1; }; f";

        # Find commits by commit message
        fm = "!f() { git log --pretty=format:'%C(yellow)%h  %Cblue%ad  %Creset%s%Cgreen  [%cn] %Cred%d' --decorate --date=short --grep=$1; }; f";

        # Remove branches that have already been merged with main.
        dm = "!git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";

        # Show the user email for the current repository.
        whoami = "config user.email";
      };
    };

    programs.lazygit = {
      enable = true;
      settings = {
        gui.theme = {
          lightTheme = false;
        };
      };
    };
  };
}
