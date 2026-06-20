# Roadmap — git-plugin

Where this plugin could go. Items here are aspirations, not commitments. When an item is evaluated, the outcome moves to the Decided section with a pointer to DECISIONS.md.

**Statuses:** `active` (in progress) · `idea` (worth evaluating) · `parked` (inspiration, no timeline) · `decided` (evaluated — see DECISIONS.md)

---

## Near-term

No active near-term items.

## Future explorations

- **`/review` skill** — Review a PR or set of changes before merging. Would read the diff, check for common issues (secrets, large files, style violations), and produce a structured review. `status: idea`
- **`/branch` skill** — Create, switch, and clean up branches with naming conventions. Include stale-branch detection and cleanup guidance. `status: idea`
- **`/sync` skill** — Pull/rebase with conflict handling guidance. Especially valuable in sandboxed environments where merge conflicts can be disorienting. `status: idea`
- **`/release` skill** — Tag and release workflow with version bumping, changelog generation, and push confirmation. Could integrate with the versioning conventions established across all plugins. `status: idea`
- **`/diff` skill** — Review changes with context before committing. More detailed than what `/commit` shows — full file-level diffs with annotation. `status: idea`
- **More host wrappers** — Extend the `AGENTS.md` canonical pattern if other tool-specific compatibility files become relevant. `status: idea`

## Parking lot

- **Non-GitHub remote support** — The `/pr` skill currently assumes GitHub (via `gh` CLI). GitLab (`glab`), Bitbucket, and Azure DevOps have their own CLIs. `status: parked`
- **Interactive rebase guidance** — Walk non-technical users through interactive rebase for cleaning up commit history before a PR. High value but complex to guide safely. `status: parked`

## Decided

- **Adopted agentic scaffold** — → Decision 001. `status: decided`
- **Environment-aware lock file handling** — Detect host and adapt lock file strategy. → Decision 002. `status: decided`
- **Plugin-name rename** — Rebranded from `git-cowork` to `git-plugin` in v0.3.0 (documented in CHANGELOG v0.3.0, not a separate decision). `status: decided`
- **logchange migration** — Moved to `agentic-scaffold-plugin` where it belongs with the CHANGELOG.md lifecycle. → Decision 003. `status: decided`
- **Dual-distribution standardization** — Added Distribution section to CLAUDE.md. → Decision 004. `status: decided`
- **Canonicalize git-plugin instructions around AGENTS.md** — → Decision 005. `status: decided`
- **Cowork commit/PR handoff** — Generate a ready-to-run handoff in the sandbox instead of stopping on locks. → Decision 006. `status: decided`
