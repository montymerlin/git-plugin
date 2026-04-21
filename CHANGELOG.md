# Changelog — git-plugin

A narrative record of how this plugin evolves. Updated after significant work sessions, not per-commit.

---

## 2026-04-21 — adopted agentic scaffold

Added CLAUDE.md, CHANGELOG.md, DECISIONS.md, and ROADMAP.md. The plugin already had a solid README with installation docs and per-repo customisation guidance; the scaffold adds agent instructions, version tracking, and a decision log. Migrated the future skill ideas from README's roadmap section into ROADMAP.md proper. See Decision 001.

---

## Pre-scaffold history (reconstructed from git)

- **v0.2.1** — Namespace all skills with `git:` prefix for Cowork disambiguation
- **v0.2.0** — Rewrote `git-explained.md` for non-technical collaborators. Tightened secret handling in commit skill.
- **v0.1.0** — Initial release. Four skills (`commit`, `pr`, `status`, `logchange`) with FUSE lock detection, convention-aware commit messages, and safety-first staging. `logchange` works in both git repos and non-git folders.
