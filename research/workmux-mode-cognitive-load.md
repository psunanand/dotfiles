# Workmux session mode versus window mode

**Question.** Which Workmux mode has the lower mental workload for this setup,
while preserving parallel work and agent monitoring?

**Decision informed.** Whether to use the article's session-mode layout or keep
Workmux's default window mode.

**Consumer.** Workmux configuration and workflow choice.

**Research date.** 2026-08-30. Local versions checked: Workmux 0.1.248 and tmux 3.7b.

## Verified facts

- Workmux defaults to creating a tmux window in the current session. Session mode
  creates a separate tmux session for each worktree. [Workmux session mode](https://workmux.raine.dev/guide/session-mode/)
- In session mode, multiple windows are configured with `windows`; this is
  mutually exclusive with top-level `panes`. Session mode is tmux-only. [Workmux session mode](https://workmux.raine.dev/guide/session-mode/)
- Workmux stores the mode per worktree. `open`, `close`, `remove`, and `merge`
  remember the mode used when that worktree was created. [Workmux session mode](https://workmux.raine.dev/guide/session-mode/)
- Workmux's dashboard can monitor agents and worktrees across sessions, show live
  terminal previews, send input, and jump to a selected agent. A dashboard popup
  binding is officially documented. [Workmux dashboard](https://workmux.raine.dev/guide/dashboard/)
- Workmux supports `base_branch: auto`, which uses the effective main branch
  rather than the currently checked-out branch. [Workmux configuration](https://workmux.raine.dev/guide/configuration/)
- tmux groups windows into sessions; a window groups panes. tmux provides both
  session selection and window selection. [tmux Getting Started](https://github.com/tmux/tmux/wiki/Getting-Started)
- The user's current tmux config already uses `C-a` as prefix and binds `C-a S`
  to `choose-tree -sZ`, a session chooser. It also has Vim-style pane navigation
  and a custom status line. [Local tmux config](../.config/tmux/tmux.conf)
- The user's installed Workmux is `0.1.248`; tmux is `3.7b`.

## Cognitive-load assessment

These conclusions are inferences from the navigation structures and the user's
existing configuration, not measured human-factors results.

### Window mode

```text
one tmux session
  ├── main window
  ├── feature-a window
  └── feature-b window
```

Advantages:

- One navigation level: switch windows/tabs.
- Lower setup and navigation overhead for a small number of agents.
- All agents are naturally visible in one session and are easy to cycle through.
- Matches Workmux's default behavior and requires only top-level `panes` config.

Costs:

- The session's window list becomes a shared mixed list of main, editor, shell,
  and agent contexts.
- A feature needing several windows is less self-contained; adding windows can
  clutter the shared session.
- Context separation is visual/conventional rather than a separate tmux session.

### Session mode

```text
main session
feature-a session
  ├── editor window
  └── shell window
feature-b session
  ├── editor window
  └── shell window
```

Advantages:

- Each feature is a complete context with its own windows, history, and layout.
- Switching sessions makes it harder to accidentally edit or run commands in the
  wrong feature.
- It matches the supplied terminal-first article and is useful when the human
  actively works inside several features, not merely monitors agents.
- Workmux remembers the mode per worktree, so lifecycle commands do not need a
  mode flag after creation.

Costs:

- Adds a navigation level: select a session, then a window, then a pane.
- More sessions can make session selection harder without a chooser/dashboard.
- It requires tmux and uses `windows` configuration instead of simpler `panes`.
- The article's lower cognitive load also comes from OpenCode/Neovim integration,
  notifications, and sesh; session mode alone does not provide those benefits.

## Recommendation

For the stated goal of reducing mental workload while actively monitoring several
agents, start with **window mode** and Workmux's dashboard. It has fewer navigation
objects and works with the current single-session tmux configuration. Use `-b` to
leave the current window focused and `workmux dashboard` to monitor all agents.

Choose **session mode** only when each feature needs its own editor, shell, dev
server, or longer-lived context. It is the right reproduction of the supplied
Fedja Minaya article, but it is not automatically lower-workload for a user who
mostly wants a central agent queue.

A reversible compromise is to keep window mode as the global default and create
individual sessions when needed:

```yaml
mode: window
```

```sh
workmux add feature/isolated --mode session -a pi -p "Work in an isolated feature session."
```

Because mode is stored per worktree, a worktree created in session mode continues
to be handled as a session by later lifecycle commands.

## Suggested low-overhead setup

```yaml
# ~/.config/workmux/config.yaml
nerdfont: true
agent: pi
mode: window
base_branch: auto
merge_strategy: rebase
merge_keep: true

panes:
  - command: <agent>
    focus: true
  - split: horizontal
    percentage: 35
```

Use the existing `C-a S` binding for session selection only when an isolated
session was explicitly requested. Add the official dashboard popup binding only
if desired:

```tmux
bind C-s display-popup -h 30 -w 100 -E "workmux dashboard"
```

Useful aliases are deliberately small:

```nix
wm = "workmux";
wma = "workmux add";
wmd = "workmux dashboard";
wms = "workmux status";
wml = "workmux list";
wmo = "workmux open";
```

## Evidence limits

- No controlled study or quantitative measurement of cognitive load was found or
  performed; the recommendation is a workflow inference.
- The article's subjective claim that sessions reduce workload depends on tools
  besides Workmux, including OpenCode integration, notifications, and sesh.
- Monitoring behavior depends on agent status hooks; Pi's status model is less
  expressive than agents with a waiting state.

## Could not verify

- Which number of concurrent feature sessions causes the user to prefer session
  mode over window mode.
- Whether a Workmux sidebar or dashboard would be preferred over the current tmux
  chooser after daily use.

## Confidence

**Medium-high.** Workmux and tmux mechanics are directly documented and locally
verified; the mental-workload recommendation is an explicit, reversible inference.

## Open questions

- How many concurrent agents will normally run?
- Will the user actively edit inside each feature or mainly monitor agents?
- Is an always-visible sidebar preferable to opening the dashboard on demand?

## Next

Prototype the recommended window-mode setup with two agents. If the shared window
list becomes confusing or each feature needs multiple windows, switch the global
config to session mode or use `--mode session` for selected worktrees.
