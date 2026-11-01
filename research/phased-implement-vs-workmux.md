# Phased implementation workflow versus Workmux

**Question.** Is Raine's phased implementation workflow part of Workmux?

**Research date.** 2026-08-30.

## Answer

It is part of the **Workmux ecosystem**, but not part of the Workmux CLI itself.

- **Workmux** provides the worktree/tmux control plane and lifecycle commands:
  `add`, `status`, `wait`, `capture`, `send`, `run`, `merge`, and `remove`.
- **Workmux skills** provide reusable agent workflows such as `/workmux`,
  `/worktree`, `/coordinator`, `/merge`, `/rebase`, and `/open-pr`.
- **`/phased-implement`** is a separate skill in the `raine/consult-llm`
  repository. It uses Workmux to create a DAG of implementation phases, dispatch
  independent phase agents, wait for them, verify result sentinels, merge phases
  serially, and run final validation.
- **`consult-llm`** is a separate second-opinion/review tool used optionally by
  that workflow. It is not required for ordinary Workmux use.

Sources:

- [Phased implementation workflow](https://raine.dev/blog/phased-implement-workflow/)
- [`phased-implement` source](https://github.com/raine/consult-llm/blob/main/skills/phased-implement/SKILL.md)
- [Workmux skills](https://workmux.raine.dev/guide/skills)

## Relevance to this setup

`workmux setup --skills` can install Workmux skills into Pi's
`~/.pi/agent/skills/`, including `/worktree`, `/coordinator`, `/merge`, and
`/workmux`. It does not make the separate `consult-llm` phased skill part of the
Workmux CLI. The current `consult-llm install-skills` implementation targets
Claude Code, OpenCode, and Codex, not Pi, and its installer source does not list
`phased-implement` among the automatically installed skills.

Therefore the practical progression is:

1. Start with Workmux plus Pi's `/worktree` skill for delegation.
2. Use `/coordinator` when Pi should manage spawning, monitoring, and merging.
3. Add/adapt `/phased-implement` only for large, clearly decomposable tasks that
   need a dependency DAG, result sentinels, serialized merges, and external
   review.

The phased workflow is overkill for small changes and requires stricter planning
than ordinary Workmux use.

## Evidence limits

- The blog describes the author's workflow, not a compatibility guarantee for
  every agent runtime.
- Manual adaptation of the phased skill to Pi was not tested.

## Confidence

**High** that the workflow is separate from the Workmux binary and built on
Workmux primitives. **Medium** for turnkey Pi support because the current
`consult-llm` installer does not target Pi or list this skill.
