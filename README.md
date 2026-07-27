# git-plugin

Git workflow toolkit for local terminal hosts and constrained sandboxes. Guided commits, deliberate merges, pull requests, and repo orientation with explicit safety rails and host-aware lock-file handling.

## Skills

| Skill | What it does |
|------|---------------|
| `/commit` | Guided staging and committing with logical grouping, safety checks, and convention-aware message drafting |
| `/merge` | Safe branch integration with ancestry-aware strategy, conflict review, and human-readable merge messages |
| `/pr` | Guided pull request creation with structured descriptions, push handling, and template support |
| `/status` | Repo orientation: branch, working tree, recent history, remotes, stashes, and health checks |

## Core Behaviour

- **Safety-first** — never auto-pushes, never blanket-stages, and warns about secrets, large binaries, and detached HEAD.
- **Deliberate merges** — preserves fast-forwards, explains required merge commits in plain language, and keeps push and branch cleanup separately authorised.
- **Convention-aware** — reads repo conventions from `AGENTS.md`, `CLAUDE.md`, or `README.md` in the target repo.
- **Host-aware** — local terminal hosts perform approved Git writes directly; Cowork-style sandboxes (where the mount blocks `unlink`) get a context-rich commit/merge/PR handoff prompt for Claude Code instead.

## Environments

### Local terminal hosts

Claude Code, Codex, Cursor, and similar full local hosts can remove stale git lock files inline and continue the workflow.

### Cowork sandbox

Cowork's workspace mount denies `unlink`, so git writes can't complete in-session and there are no push credentials. Instead of stopping, the `commit`, `merge`, and `pr` skills do all the read-only analysis and emit a single context-rich **handoff prompt** you paste into Claude Code — it carries the session's intent and drafted message or strategy, so Code can act without rebuilding context from the diff, and picks the Git mechanics itself. See Decisions 006 and 007.

## Installation

See [SETUP.md](SETUP.md) for full install details across Cowork, Claude Code, Codex, Cursor, and other hosts.

**TL;DR**:
- **Claude Code CLI**: `claude plugins install github.com/montymerlin/git-plugin`
- **Cowork**: Upload `git-0.6.0.plugin` from `ops/plugins/_dist/` to Claude Desktop → Plugins.
- **Codex**: `bash scripts/install_codex_skills.sh --from-github`

## Requirements

- `git` — any recent version
- `gh` — required for `/pr`

## Repo Conventions

- `AGENTS.md` is canonical for this repo.
- `CLAUDE.md` is a compatibility wrapper.
- `.claude-plugin/` is packaging metadata, not the source of truth for skill behaviour.
- `references/git-explained.md` is supporting guidance, not a runtime dependency.

## License

MIT
