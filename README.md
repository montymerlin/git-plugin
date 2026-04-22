# git-plugin

Git workflow toolkit for local terminal hosts and constrained sandboxes. Guided commits, pull requests, and repo orientation with explicit safety rails and host-aware lock-file handling.

## Skills

| Skill | What it does |
|------|---------------|
| `/commit` | Guided staging and committing with logical grouping, safety checks, and convention-aware message drafting |
| `/pr` | Guided pull request creation with structured descriptions, push handling, and template support |
| `/status` | Repo orientation: branch, working tree, recent history, remotes, stashes, and health checks |

## Core Behaviour

- **Safety-first** — never auto-pushes, never blanket-stages, and warns about secrets, large binaries, and detached HEAD.
- **Convention-aware** — reads repo conventions from `AGENTS.md`, `CLAUDE.md`, or `README.md` in the target repo.
- **Host-aware** — local terminal hosts can remove stale `.git/*.lock` files inline; Cowork-style sandboxes cannot.

## Environments

### Local terminal hosts

Claude Code, Codex, Cursor, and similar full local hosts can remove stale git lock files inline and continue the workflow.

### Cowork sandbox

Cowork-style sandboxed environments cannot remove stale `.git/*.lock` files from inside the session. The skills stop and ask the user to clear them from a local terminal first.

## Installation

### Claude Code CLI

```bash
claude plugins install github.com/montymerlin/git-plugin
```

### Claude Desktop (Cowork)

Install from the marketplace or package the repo for upload:

```bash
zip -r git.plugin . -x ".git/*" ".DS_Store"
```

### Codex

```bash
bash scripts/install_codex_skills.sh --from-github
```

### Other hosts

Clone the repo and load the skill folders according to the host's skill/plugin conventions.

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
