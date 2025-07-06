set quiet
set shell := ["bash", "-c"]

help:
    just --list

clean:
    just warn "cleaning up nix garbage..."
    sudo nix-collect-garbage -d

[macos]
install-darwin profile:
    if ! type darwin-rebuild >/dev/null 2>&1; then \
      just info "installing nix-darwin and applying the configurations/settings according to `profile`..." \
      && sudo nix run nix-darwin/master#darwin-rebuild \
        --extra-experimental-features 'nix-command flakes' \
        -- switch --flake '.#{{profile}}'; \
    fi

[macos]
update-darwin profile:
    just info "re-applying nix-darwin configurations/settings..."
    sudo darwin-rebuild switch --flake '.#{{profile}}'

update-flake:
    just info "update nix flake lock file"
    nix flake update

BLUE := '\033[1;30;44m'
YELLOW := '\033[1;30;43m'
RED := '\033[1;30;41m'
RESET := '\033[0m'

[private]
info msg:
    echo -e "{{BLUE}} INFO {{RESET}} {{msg}}"

[private]
warn msg:
    echo -e "{{YELLOW}} WARN {{RESET}} {{msg}}"

[private]
error msg:
    echo -e "{{RED}} ERR {{RESET}} {{msg}}"
