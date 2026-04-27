# Changelog — git-plugin

A narrative record of how this plugin evolves. Updated after significant work sessions, not per-commit.

---

## 2026-04-27 — Plugin audit pass + skill name fix

Audited the plugin against `/create-cowork-plugin` standards. Fixed the namespaced skill `name:` frontmatter bug — all 3 SKILL.md files had `name: git:<skill>` which caused doubled runtime IDs (`git:git:commit` etc.) at install time. Per Anthropic convention, the host prepends the plugin name automatically; SKILL.md `name:` should match the bare directory name. Fixed to `commit`, `pr`, `status`.

Also added: `.gitignore` (was missing), `SETUP.md` § "Quick Install (for AI agents)" decision tree for environment-aware install routing, `SETUP.md` § "Cowork" 3-option pattern (GitHub Releases / build locally / workspace packager skill) so external users can produce a `.plugin` file without depending on this workspace, and `SETUP.md` § "Claude Code CLI" global-vs-local install split with explicit user question. AGENTS.md Canonical Structure was updated to include SETUP.md, plus a new "Packaging for Cowork" section pointing at the canonical install flow.

## 2026-04-27 — Cowork packaging: SETUP.md as setup canon

Added `SETUP.md` as the single source of truth for install pathways and host compatibility, consolidating the previous Installation, Environments, and Requirements information (including the host-aware `.git/*.lock` behavior that distinguishes local terminals from Cowork sandboxes). `README.md`'s installation section was trimmed to a brief pointer at SETUP.md. The plugin is now packaged as `git-0.4.0.plugin` in `ops/plugins/_dist/` using the new `cowork-plugin-packager` skill. No skill behavior changes.

## 2026-04-22 — v0.4.0: AGENTS.md canon and Codex install support

Reframed the plugin as a host-agnostic git workflow toolkit with Claude packaging compatibility rather than a Claude-first repo. `AGENTS.md` is now the canonical instruction file, `CLAUDE.md` is a thin compatibility wrapper, and the skills now look for repo conventions in `AGENTS.md`, `CLAUDE.md`, or `README.md` instead of assuming a Claude-specific source of truth.

Added Codex install/update scripts and removed the hardcoded Claude co-author default from the commit workflow, which makes the plugin fit better across multiple local hosts while preserving the same safety-first git behaviour. See Decision 005.

## 2026-04-21 — v0.3.1: Dual-distribution standardization

Added Distribution section to CLAUDE.md covering Claude Code CLI, Cowork, and auto-update behaviour. The plugin already had marketplace.json and dual-install README sections — this aligns CLAUDE.md with the same pattern across all six portfolio plugins. See Decision 004.

---

## 2026-04-21 — v0.3.0: Rebrand, environment-aware lock handling, marketplace

The plugin was renamed from `git-cowork` to `git-plugin`. The original name was accurate — it was built specifically to handle Cowork's sandboxed FUSE/virtiofs filesystem where stale `.git/*.lock` files can't be removed from within the session. But the skills are host-agnostic: the commit, PR, and status workflows are equally useful in Claude Code CLI and Cursor, and the Cowork-specific framing was narrowing perceived utility unnecessarily.

The most substantial change is environment-aware lock file handling across all three skills. Rather than always instructing the user to manually clear lock files, the skills now detect whether they're running in Claude Code CLI (full filesystem access, can remove lock files inline) or Cowork (FUSE/virtiofs sandbox, must ask the user to clear externally). Detection uses the `CLAUDE_COWORK` env var and a `mount | grep virtiofs` check. See Decision 002.

`logchange` was removed from this plugin and migrated to `agentic-scaffold-plugin` as `agentic-scaffold:logchange`. The rationale: logchange maintains CHANGELOG.md, which agentic-scaffold creates — they're the same artifact lifecycle and belong together. See Decision 003.

A self-hosted marketplace entry (`.claude-plugin/marketplace.json`) was added to support global installation via Claude Code's plugin system, mirroring the mdpowers-plugin pattern. The plugin can now be registered as an `extraKnownMarketplace` with `autoUpdate: true`.

---

## 2026-04-21 — v0.2.2: Adopted agentic scaffold

Added CLAUDE.md, CHANGELOG.md, DECISIONS.md, and ROADMAP.md. The plugin already had a solid README with installation docs and per-repo customisation guidance; the scaffold adds agent instructions, version tracking, and a decision log. Migrated the future skill ideas from README's roadmap section into ROADMAP.md proper. See Decision 001.

---

## Pre-scaffold history (reconstructed from git)

- **v0.2.1** — Namespace all skills with `git:` prefix for Cowork disambiguation
- **v0.2.0** — Rewrote `git-explained.md` for non-technical collaborators. Tightened secret handling in commit skill.
- **v0.1.0** — Initial release. Four skills (`commit`, `pr`, `status`, `logchange`) with FUSE lock detection, convention-aware commit messages, and safety-first staging. `logchange` works in both git repos and non-git folders.
