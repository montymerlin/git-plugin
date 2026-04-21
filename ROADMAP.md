# Roadmap — git-cowork

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

## Parking lot

- **Non-GitHub remote support** — The `/pr` skill currently assumes GitHub (via `gh` CLI). GitLab (`glab`), Bitbucket, and Azure DevOps have their own CLIs. `status: parked`
- **Interactive rebase guidance** — Walk non-technical users through interactive rebase for cleaning up commit history before a PR. High value but complex to guide safely. `status: parked`
- **Plugin-name rename** — The plugin is currently named `git-cowork` in the manifest, which ties it to Cowork branding. The skills are host-agnostic (they just need git and gh). Consider renaming to `git-workflows` or similar, following the mdpowers rename precedent (Decision 005 in mdpowers). `status: parked`

## Decided

- **Adopted agentic scaffold** — → Decision 001. `status: decided`
