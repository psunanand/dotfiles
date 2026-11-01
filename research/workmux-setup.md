# Workmux setup for parallel branches and agent monitoring

**Question.** What Workmux configuration best supports working on this repository in
parallel branches while running and monitoring multiple coding agents?

**Decision informed.** Whether to add global Workmux configuration, project-specific
`.workmux.yaml`, tmux dashboard integration, and agent status tracking.

**Consumer.** Direct configuration follow-up and daily terminal workflow.

**Research date.** 2026-08-30. Installed local version: `workmux 0.1.248`.

## Verified facts

- Workmux creates a separate Git worktree and branch for each `workmux add`, then
  pairs it with a tmux window. By default the worktree is a sibling directory named
  `<project>__worktrees`; `worktree_dir` can change this. [Workmux quick start](https://workmux.raine.dev/guide/quick-start/)
- `base_branch: auto` bases new branches on the effective main branch, using the
  configured `main_branch`, local `origin/HEAD`, `main`, or `master`. An explicit
  `workmux add --base` overrides the setting. Without this setting, Workmux uses
  the currently checked-out branch. [Configuration](https://workmux.raine.dev/guide/configuration/)
- Global configuration belongs at `~/.config/workmux/config.yaml`; project-specific
  configuration belongs in `.workmux.yaml`. Project configuration overrides global
  configuration. [Configuration](https://workmux.raine.dev/guide/configuration/)
- In window mode, Workmux creates windows in the current tmux session. Session mode
  creates a separate tmux session per worktree and supports multiple windows per
  worktree, but is tmux-only. [Session mode](https://workmux.raine.dev/guide/session-mode/)
- A pane command of `<agent>` resolves to the configured agent. Workmux also
  recognizes literal built-in commands including `pi` and `codex`, and injects
  prompts supplied with `--prompt`, `--prompt-file`, or `--prompt-editor`. [AI agents](https://workmux.raine.dev/guide/agents)
- `workmux setup` detects supported agent CLIs and installs status hooks. Pi is
  supported for working/done tracking, but does not provide a waiting state;
  Codex supports working, waiting, and done. [Status tracking](https://workmux.raine.dev/guide/status-tracking/)
- `workmux dashboard` has Agents and Worktrees views, live terminal preview, Git
  information, and actions for jumping, input, diff review, and cleanup. A tmux
  popup binding can make it quickly accessible. [Dashboard](https://workmux.raine.dev/guide/dashboard/)
- New worktrees do not contain gitignored files such as `.env` or `node_modules`.
  Workmux supports explicit `files.copy`, `files.symlink`, and `post_create`
  commands for environment setup. [Configuration](https://workmux.raine.dev/guide/configuration/)
- This repository already installs tmux through Nix and manages its configuration
  at [`.config/tmux/tmux.conf`](../.config/tmux/tmux.conf). It currently uses one
  tmux session with multiple windows, a `C-a` prefix, and custom window-status
  formats. [Local package configuration](../modules/home/packages.nix)
- This repository installs Pi through the Home Manager `mise` configuration and
  separately includes Codex in its Homebrew casks. [Local program configuration](../modules/home/programs.nix)

## Recommended configuration

Use **window mode** globally because it matches the existing tmux workflow: one
window per branch/worktree in the current session, plus a dashboard popup for
cross-window monitoring. Use Pi as the default agent and invoke Codex explicitly
when needed.

Suggested `~/.config/workmux/config.yaml`:

```yaml
nerdfont: true

# Always branch from the repository's effective main branch, not the current
# feature branch.
base_branch: auto

# Rebase is the preferred integration strategy for these short-lived branches.
merge_strategy: rebase
merge_keep: true

mode: window
window_prefix: "wm-"
window_placement: rightmost

agent: pi

panes:
  - command: <agent>
    name: agent
    focus: true
  - name: shell
    split: horizontal
    size: 20

# Keep the dashboard useful when several repositories are active.
dashboard:
  sort_mode: priority
  preview_size: 55
```

The `merge_keep: true` choice is an inference for safer review: it keeps the
worktree and branch after merging so cleanup is deliberate rather than automatic.
It can be changed to `false` once the workflow is comfortable.

## Optional project configuration

A repository-specific `.workmux.yaml` should only add project setup that is
actually required. For this dotfiles repository, no dependency-install hook is
needed. For application repositories, a pattern is:

```yaml
post_create:
  - "<global>"
  - mise use

files:
  copy:
    - .env.local

panes:
  - command: <agent>
    name: agent
    focus: true
  - command: just test --watch
    name: tests
    split: horizontal
    size: 15
  - name: shell
    split: vertical
    size: 20
```

Do not copy secrets into a committed `.workmux.yaml`; use a local global config,
ignored files, or a secret manager as appropriate. Project `panes` replace the
global pane list rather than extending it, so include the desired complete layout.

## Monitoring workflow

1. Run `workmux setup --hooks` once and accept the status integration for the
   agents in use. (`workmux setup` also installs skills; use it instead when
   those skills are wanted.) Restart existing agent sessions afterward.
2. Add a popup binding to the managed tmux configuration:

   ```tmux
   bind C-s display-popup -h 30 -w 100 -E "workmux dashboard"
   ```

   The current tmux prefix is `C-a`, so the dashboard is `prefix`, then `Ctrl-s`.
3. Add a branch from the main worktree:

   ```sh
   workmux add feature/example -p "Implement the example feature"
   ```

4. Keep the current window while launching agents in the background:

   ```sh
   workmux add feature/pi-task -b -a pi -p "Implement task A"
   workmux add feature/codex-task -b -a codex -p "Implement task B"
   ```

   Each command creates an isolated worktree and tmux window. Use `workmux
   dashboard` to inspect status and live output, `workmux status` for a compact
   status view, and `workmux list` for worktree/branch state.
5. Review and merge one branch at a time with `workmux merge <handle>`, then
   deliberately remove completed worktrees when appropriate.

For multiple agents working on the same conceptual task, repeated `--agent`
flags create separate worktrees, which is safer than sharing a worktree. The
coordinator pattern should keep the main worktree as the review/orchestration
branch and let each agent modify only its own worktree.

## Existing tmux status-format consideration

Workmux normally modifies the current tmux session's window-status format to add
status icons. This repository has custom `window-status-format` and
`window-status-current-format` settings. If automatic modification does not
coexist cleanly with the custom format, set `status_format: false` in the global
Workmux config and add `#{@workmux_status}` explicitly to both existing tmux
formats, following the official example in [Status tracking](https://workmux.raine.dev/guide/status-tracking/).

## Assessment

The smallest useful setup is global `agent: pi`, `base_branch: auto`, window mode,
a two-pane agent/shell layout, `workmux setup`, and the dashboard popup. Add
project-specific hooks only when a project needs dependencies, services, or
ignored files. Use `--agent codex` for selected tasks rather than making every
worktree start multiple agents.

## Evidence limits

- Workmux documentation describes supported commands and configuration but does
  not establish that every Pi distribution or wrapper exposes identical lifecycle
  events. The local Pi installation is managed through `mise`, so status-hook
  behavior should be verified after `workmux setup`.
- The recommended pane sizes, merge strategy, and window placement are workflow
  preferences based on the current tmux configuration, not requirements.

## Could not verify

- Whether the current Pi installation has already received Workmux status hooks.
- Whether the current tmux session is using a status format already modified by
  Workmux.
- Whether each future project needs `.env` copying or dependency symlinking.

## Confidence

**High** for Workmux's worktree, tmux, agent, dashboard, and configuration behavior
based on first-party documentation and the locally installed CLI. **Medium** for
the final layout because agent command preferences and project setup requirements
are personal/workspace-specific.

## Open questions

- Should Pi remain the default agent, or should Codex be the default for this
  user's normal tasks?
- Should status icons be merged into the current custom tmux status line or left
  to Workmux's automatic session-level modification?
- Which repositories, if any, require copying `.env` files or running setup hooks?

## Next

Prototype the global config and tmux popup without adding project-specific hooks;
run `workmux setup`, create one test worktree with `workmux add -b`, and verify
status in `workmux dashboard`. If the behavior is satisfactory, declaratively
manage `~/.config/workmux/config.yaml` and the tmux binding through this dotfiles
repository.
