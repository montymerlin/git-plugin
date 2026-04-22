# AGENTS.md — git-plugin

Canonical repo instructions for `git-plugin`.

## Project Identity

- **Name:** git-plugin
- **Type:** Host-agnostic git workflow skills repo with Claude plugin packaging compatibility
- **Version:** 0.4.0
- **Stack:** Markdown skills + reference docs + lightweight install scripts

## Canonical Structure

```
git-plugin/
├── .claude-plugin/
│   ├── plugin.json          # Claude plugin packaging metadata
│   └── marketplace.json     # Claude marketplace listing
├── skills/
│   ├── commit/
│   ├── pr/
│   └── status/
├── references/
│   └── git-explained.md
├── scripts/
│   ├── install_codex_skills.sh
│   └── update_codex_skills.sh
├── AGENTS.md                # Canonical repo instructions
├── CLAUDE.md                # Claude compatibility wrapper
├── CHANGELOG.md
├── DECISIONS.md
├── ROADMAP.md
└── README.md
```

## Canonical Rules

- `AGENTS.md` is the canonical instruction file for this repo.
- `CLAUDE.md` is a thin compatibility layer that points Claude-family hosts back to `AGENTS.md`.
- `skills/` is the canonical source of shared workflows.
- `.claude-plugin/` is Claude-specific packaging metadata, not the source of truth for skill logic.
- Repo-specific commit or PR conventions should be discovered from `AGENTS.md`, `CLAUDE.md`, or `README.md` in the target repo, in that order.

## Runtime Conventions

- This repo has no heavy runtime path requirements; skills are markdown-first.
- Distinguish between two effective host modes:
  - `local` — full local terminal hosts such as Claude Code, Codex, or Cursor
  - `cowork` — constrained sandbox where stale `.git/*.lock` files cannot be removed inline
- Use host-aware lock handling, but avoid Claude-first naming where a more general term works.

## Documentation Rules

- README.md is human-facing.
- AGENTS.md is the canonical agent-facing document.
- CLAUDE.md exists for compatibility only and should stay short.
- DECISIONS.md logs major structural choices before implementation.
- ROADMAP.md holds future ideas until they become decisions.
- CHANGELOG.md records narrative milestones after significant work.

## Design Principles

1. **Safety-first git workflows** — no auto-push, no blanket staging, no secret leakage.
2. **Compatibility layers, not duplicate sources** — host-specific files should point to canonical files.
3. **Progressive disclosure** — keep root instructions concise and push detail into skills and references.
4. **Convention awareness** — local repo conventions override plugin defaults.
5. **Cross-host portability** — local terminal hosts should share the same workflow unless a real sandbox constraint requires divergence.

## Boundaries

### Do
- Preserve explicit staging and confirmation steps
- Read target-repo conventions before drafting commit and PR text
- Keep lock-file handling honest to the actual host constraints
- Update docs and metadata together when conventions change

### Don't
- Reintroduce `CLAUDE.md` as the canonical repo instruction file
- Hardcode Claude-specific co-author assumptions
- Auto-push or auto-merge without explicit user confirmation
- Use `git add .`, `git add -A`, or similar blanket staging shortcuts
