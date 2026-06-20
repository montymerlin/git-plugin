# Decisions — git-plugin

Architectural decisions for the git-plugin, in lightweight ADR format.

---

## Decision 001 — Adopted agentic scaffold (2026-04-21)

**Context:** The plugin had a README but no CLAUDE.md, no decision log, no changelog, and future skill ideas were buried in a README section. As the plugin considers new skills (review, branch, sync, release, diff), conventions need to be explicit.

**Decision:** Add the standard agentic scaffold (CLAUDE.md, CHANGELOG.md, DECISIONS.md, ROADMAP.md). Migrate the README's "Roadmap" section into ROADMAP.md proper so future directions have a structured home with the ROADMAP → DECISIONS pipeline.

**Consequences:**
- Agent sessions have explicit safety principles and conventions documented in CLAUDE.md
- Future skills are tracked with statuses rather than a flat bullet list in the README
- Pre-scaffold version history is reconstructed in CHANGELOG from git log
- Adds four small files; README's roadmap section can be simplified to a pointer

**Alternatives Considered:**
- *Leave as-is* — workable at four skills, but would become unwieldy as the roadmap grows
- *Just add CLAUDE.md* — misses the opportunity to establish the full decision/roadmap pipeline

---

## Decision 002 — Environment-aware lock file handling (2026-04-21)

**Context:** The plugin was originally built for Cowork, where the filesystem is FUSE/virtiofs-mounted. In that environment, stale `.git/*.lock` files cannot be removed from within a session — any attempt returns "Operation not permitted." The safe move is to stop and ask the user to clear them from their local terminal. This was the original skill behaviour, hardcoded for all environments.

When the plugin expanded to Claude Code CLI (and Cursor), this became too conservative. Claude Code CLI has full filesystem access and can remove lock files inline without user intervention. Forcing users to manually clear lock files in an environment that doesn't need that restriction is unnecessary friction.

**Decision:** All skills that touch git detect the host environment before handling lock files:
```bash
if [ "${CLAUDE_COWORK}" = "1" ] || mount 2>/dev/null | grep -q virtiofs; then
  GIT_ENV="cowork"
else
  GIT_ENV="claude-code"
fi
```
Claude Code / Cursor (`GIT_ENV=claude-code`): remove stale lock files inline and continue. Cowork (`GIT_ENV=cowork`): stop and ask the user to clear them externally.

**Consequences:**
- Claude Code and Cursor users get a smoother experience — no unnecessary manual step
- Cowork users retain the safe fallback that matches their environment's constraints
- Detection relies on `CLAUDE_COWORK` env var (if Anthropic sets it) and `virtiofs` mount check as fallback — the fallback is slightly fragile (any virtiofs mount triggers Cowork mode, not only Anthropic's)
- Known limitation: a developer running Docker Desktop with virtiofs could get a false-positive Cowork detection in Claude Code CLI

**Alternatives Considered:**
- *Always escalate to user* — too conservative for CLI environments that can handle it
- *Always remove inline* — breaks silently in Cowork where removal returns "Operation not permitted"
- *Separate skills per environment* — doubles maintenance burden for identical workflows

---

## Decision 003 — Move logchange to agentic-scaffold-plugin (2026-04-21)

**Context:** The `logchange` skill maintains CHANGELOG.md. It was originally included in this plugin because it was useful alongside git workflows. However, CHANGELOG.md is created by `agentic-scaffold-plugin`'s `/init` skill — the scaffold creates the artifact, and logchange keeps it current. They're two phases of the same artifact lifecycle and were in different plugins.

**Decision:** Remove `logchange` from `git-plugin` and add it to `agentic-scaffold-plugin` as `agentic-scaffold:logchange`. The git-plugin CHANGELOG documents the removal; agentic-scaffold v0.4.0 documents the addition.

**Consequences:**
- Artifact lifecycle is co-located: init creates CHANGELOG.md, logchange maintains it, both in agentic-scaffold-plugin
- git-plugin stays focused on git operations (commit, PR, repo orientation)
- Users who had logchange symlinked to git-plugin need to update the symlink — in montymerlinHQ, `.claude/skills/logchange` was rewired to the new location
- logchange is now namespaced as `agentic-scaffold:logchange` rather than `git:logchange`

**Alternatives Considered:**
- *Keep in git-plugin* — pragmatic but conceptually muddled; the artifact lifecycle reasoning is cleaner
- *Standalone plugin* — overkill for a single skill

---

## Decision 004 — Dual-distribution standardization (2026-04-21)

**Context:** The plugin already had a marketplace.json and dual-install instructions in README.md. However, CLAUDE.md lacked an explicit Distribution section. As the full plugin portfolio standardised on a consistent distribution pattern, git-plugin needed the same CLAUDE.md treatment for consistency.

**Decision:** Add a Distribution section to CLAUDE.md covering Claude Code CLI (`claude plugins install`), Cowork (`.plugin` zip), and auto-update behaviour. No marketplace.json or README changes needed — those were already in place.

**Consequences:**
- CLAUDE.md now explicitly documents both install paths and auto-update behaviour
- Agent sessions have distribution context without needing to read README
- Pattern is consistent across all six plugins in the portfolio

**Alternatives Considered:**
- *Leave as-is* — the info was in README already, but agents read CLAUDE.md, not README

---

## Decision 005 — Canonicalize git-plugin instructions around AGENTS.md (2026-04-22)

**Context:** The plugin already worked across multiple hosts, but its repo conventions were still Claude-first. `CLAUDE.md` was the only canonical instruction file, the skills looked for target-repo conventions only in `CLAUDE.md` or README, and the commit workflow still carried Claude-specific co-author assumptions in its default examples. That conflicts with the newer compatibility-layer pattern adopted across the plugin portfolio.

**Decision:** Make `AGENTS.md` the canonical instruction file for the repo. Keep `CLAUDE.md` as a thin wrapper. Update the skills so they look for repo conventions in `AGENTS.md`, `CLAUDE.md`, or `README.md`, in that order. Add Codex install/update scripts and remove the hardcoded Claude co-author default from the commit workflow.

**Consequences:**
- The repo matches the same canonical-file pattern as mdpowers and agentic-scaffold
- Target repos using AGENTS.md get first-class convention discovery from commit and PR workflows
- Claude-specific metadata stays where it belongs: `.claude-plugin/`
- Codex can consume the same skills directly through workspace symlinks or vendor installs
- The actual git workflow stays stable; this is mostly a documentation and convention-source migration

**Alternatives Considered:**
- *Leave git-plugin on the old pattern* — would keep reintroducing CLAUDE-first assumptions into cross-host workflows
- *Support only AGENTS.md and drop CLAUDE.md checks entirely* — too abrupt; compatibility-layer discovery is more practical

---

## Decision 006 — Cowork commit/PR handoff instead of lock-stop (2026-06-20)

**Context:** The `cowork` branch of the `commit` and `pr` skills stopped on any stale `.git/*.lock` and asked the user to clear it from a local terminal (Decision 002). Live testing on the Cowork sandbox showed this was treating a symptom. The sandbox mounts the workspace over virtiofs/FUSE with `unlink` denied outright — files can be created and written, but not deleted or renamed away. The consequence for git: a commit's first write may land, but git can't remove its own `HEAD.lock` / `index.lock` / temp objects afterward, so the very next operation dies with "Unable to create '...lock': File exists" — and nothing in the sandbox can clear it. Separately, the sandbox carries no GitHub credentials, so `push` and `gh` can't authenticate. In short, in-session git writes can't be made to work in Cowork by any means available to a skill; the constraint sits below the skill layer.

**Decision:** In `cowork`, stop attempting git writes entirely. The skills do all the read-only work in-session (status, diff, convention discovery, analysis, message/PR drafting) and emit a single, context-rich **handoff prompt** the user pastes into a Claude Code chat opened in the repo, which runs the commit on the host. The prompt deliberately does **not** prescribe git commands: a fresh Claude Code session knows the repo and chooses better mechanics than the sandbox can predefine, and predefined commands risk being stale or wrong. What the prompt *does* carry is the thing only the originating session has — a why-focused summary of the work and a fully-drafted commit message — so Claude Code commits efficiently without reconstructing intent from a large diff. The prompt still names the explicit files to stage and any exclusions (the safety rails), and forbids sandbox paths, since it executes on the host.

**Consequences:**
- Cowork users get what they actually want — a complete, conventions-correct commit/PR they can run in one paste — instead of a dead-end instruction to clear locks.
- The division of labour is principled: the prompt owns *substance* (intent, message, file scope); Claude Code owns *mechanics* (the git commands). Neither reconstructs what the other already knows.
- The skills never wedge the repo by half-completing a write on the mount.
- `local` behaviour is unchanged.
- The handoff is a workaround for a platform limitation, not a fix. If Anthropic lifts the `unlink` restriction (see anthropics/claude-code issue #55206), the `cowork` branch can collapse back to a direct commit. The fork is kept deliberately thin to make that reversal cheap.
- Detection still relies on the `CLAUDE_COWORK` env var or a `virtiofs` mount match — Decision 002's known fragility carries over.

**Alternatives Considered:**
- *Keep the lock-stop* — honest about the symptom but useless: clearing locks in Cowork is impossible, and even if cleared the next write re-wedges.
- *Try the commit and fall back on failure* — risks leaving the repo in a stale-lock state the user must clear on the host anyway; worse UX than not writing at all.
- *Clone to sandbox-native storage, commit there, push* — no push credentials in the sandbox, and the working copy lives on the mount; syncing back is brittle. Not viable.
- *Emit literal git commands for the user to run* — brittle and redundant: predefining commands from inside the sandbox second-guesses Claude Code and risks stale or wrong invocations. Handing over intent + a drafted message and letting Code choose the commands is more robust. (This was the v0.5.0 first cut, revised before release.)
