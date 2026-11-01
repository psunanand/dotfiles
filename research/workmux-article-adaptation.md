# Adapting the terminal-first AI workflow to this setup

**Question.** How should this repository use Workmux in the style described by
Fedja Minaya's terminal-first AI workflow?

**Decision informed.** Whether to use Workmux window mode or session mode, how to
structure editor/agent windows, and how to monitor agents.

**Consumer.** Direct configuration and workflow follow-up.

**Research date.** 2026-08-30.

## Article workflow

The article uses Workmux in **session mode**: every Git worktree gets its own tmux
session. Each session has an `editor` window containing Neovim above OpenCode and
a separate `zsh` window. The author's global config is:

```yaml
agent: opencode
mode: session
windows:
  - name: editor
    panes:
      - command: nvim
      - command: <agent>
        split: horizontal
        percentage: 35
        focus: true
  - name: zsh
    panes:
      - focus: true
```

The article also uses `sesh` for fuzzy session switching, OpenCode/Neovim
integration, and an OpenCode notifier for desktop notifications. Those are
separate from Workmux itself.

Source: [My terminal-first AI workflow](https://www.fedeminaya.com/blog/my-terminal-first-ai-workflow)
Source configuration: [author dotfiles Workmux config](https://github.com/fedeya/dotfiles/blob/main/dot_config/workmux/config.yaml)

## Adaptation for this repository

This repository already uses tmux and Neovim, installs Pi, and includes Codex as a
Homebrew cask. It does not currently show OpenCode or `sesh` configuration. The
closest useful adaptation is therefore:

```yaml
# ~/.config/workmux/config.yaml
nerdfont: true
agent: pi
mode: session
window_prefix: wm-
base_branch: auto
merge_strategy: rebase
merge_keep: true

windows:
  - name: editor
    panes:
      - command: nvim
      - command: <agent>
        split: horizontal
        percentage: 35
        focus: true

  - name: shell
    panes:
      - focus: true
```

`windows` must be used instead of top-level `panes` in session mode; the two are
mutually exclusive. This layout gives every branch its own tmux session, with an
editor/agent window and a separate shell window. `base_branch: auto` prevents a
new task from accidentally branching from the currently checked-out feature
branch.

The OpenCode `--port` and Neovim plugin connection in the article should not be
copied when Pi is the agent. Pi can run in the agent pane, but editor-to-agent
integration would require a separate Pi/Neovim integration. The plain tmux pane is
still a complete workflow.

## Daily workflow

From the main worktree:

```sh
# One-time agent status setup
workmux setup --hooks

# Create a feature session and switch into it
workmux add feature/add-pagination \\
  --base main \\
  --agent pi \\
  --prompt "Implement pagination and add tests."

# Start another feature without switching away from the current session
workmux add feature/fix-auth -b -a pi -p "Investigate and fix the authentication bug."

# Create a Codex session when desired
workmux add feature/review -b -a codex -p "Review the current implementation and suggest fixes."
```

Use `workmux dashboard` to monitor all sessions and agents. `workmux status` gives
a compact view, `workmux list` shows worktrees and branches, and the existing tmux
`C-a S` binding can select among sessions. `workmux open <handle>` reopens a
specific session. Workmux status hooks give Pi working/done states; Pi does not
currently provide a waiting state in Workmux.

The article's `sesh` is optional. It can later replace tmux's built-in chooser if
fuzzy session selection is important. The article's desktop notification plugin
is OpenCode-specific; Workmux dashboard/status tracking is the agent-neutral
monitoring layer.

## Project setup hooks

Do not put the article's `.env` copy or `uv sync` commands in this global config.
Add them only to a project's committed `.workmux.yaml` when that project needs
them, for example:

```yaml
files:
  copy:
    - .env.local

post_create:
  - mise trust
  - pnpm install
```

Keep secret-bearing files ignored and local. The dotfiles repository itself needs
no dependency-install hook for this initial workflow.

## Evidence limits

- The article documents one author's OpenCode-centric preferences, not required
  Workmux behavior.
- Pi status tracking can show working/done but not the same waiting state as
  Codex/Claude according to Workmux's current status documentation.
- Whether a separate Pi/Neovim integration is desirable was not investigated.

## Could not verify

- Whether `sesh` or an OS notification layer is wanted in this environment.
- Whether the user's current Pi setup has already accepted Workmux hooks.

## Confidence

**High** for the session-mode mapping and Workmux commands; **medium** for the
agent/editor layout because it substitutes Pi for the article's OpenCode setup.

## Next

Prototype session mode with one clean repository and Pi. If it feels right,
manage the global config through `.config/workmux/config.yaml` and Home Manager;
add project-specific hooks only after a real project demonstrates the need.
