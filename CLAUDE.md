# CLAUDE.md — git-plugin

Git workflow toolkit for Claude Code, Cursor, and Cowork. Guided commits, pull requests, and repo orientation — with environment-aware handling for FUSE/virtiofs sandboxed environments and standard CLI environments.

## Project Identity

- **Name:** git-plugin
- **Stack:** Claude Agent SDK plugin (skills + reference docs, no runtime dependencies beyond git and gh)
- **Purpose:** Make git workflows safe and predictable across Claude Code CLI, Cursor, and sandboxed Cowork environments. Each skill detects its host environment and adapts accordingly.
- **Repository:** https://github.com/montymerlin/git-plugin
- **License:** MIT

## Directory Structure

```
git-plugin/
├── .claude-plugin/
│   ├── plugin.json            # plugin manifest
│   └── marketplace.json       # marketplace listing
├── skills/
│   ├── commit/                # guided staging and committing
│   ├── pr/                    # guided pull request creation
│   ├── status/                # comprehensive repo orientation
│   └── logchange/             # moved to agentic-scaffold-plugin (retained here temporarily)
├── references/
│   └── git-explained.md       # git from first principles for non-technical users
├── CLAUDE.md                  # this file — agent instruction set
├── CHANGELOG.md               # narrative change history
├── DECISIONS.md               # architectural decision log
├── ROADMAP.md                 # future directions
└── README.md                  # human-facing overview
```

## Key Conventions

### Skills
- Each skill lives in `skills/<skill-name>/SKILL.md`
- Skills are namespaced as `git:<skill>` (e.g., `git:commit`, `git:pr`)
- All skills check for stale `.git/*.lock` files before running any git command — this is the single most common failure mode in sandboxed environments
- Convention-aware: the commit skill reads the workspace's `CLAUDE.md` and `README` for repo-specific commit conventions
- Note: `logchange` has moved to `agentic-scaffold-plugin` where it belongs as a repo-artifact maintenance skill

### Safety principles
- **Never auto-push.** Always confirm with the user before pushing to a remote.
- **Never `git add .` or `git add -A`.** Stage files explicitly or by logical group.
- **Warn about secrets, large binaries, and detached HEAD.** Catch problems before they're committed.
- **Propose grouped commits** for unrelated changes rather than lumping everything together.

### Versioning
- **Single source of truth:** `.claude-plugin/plugin.json` `version` field is the canonical version
- **Semver:** patch for skill tweaks, minor for new skills, major for breaking changes
- **Git tags on release:** tag every version bump (`git tag v0.3.0`)
- **Version-check before committing:** plugin.json version = latest CHANGELOG heading = commit message

### Documentation
- **README.md** — human-facing: skills table, installation, per-repo customisation
- **references/git-explained.md** — git mental model for non-technical users
- **CLAUDE.md** (this file) — agent-facing: conventions, boundaries, structure
- **DECISIONS.md** — architectural decision log
- **ROADMAP.md** — future directions
- **CHANGELOG.md** — narrative change history

## Environment Detection

Skills run in two distinct environments with different behaviours:

### Claude Code CLI / Cursor
- Bash tool has full filesystem access — stale `.git/*.lock` files **can** be removed directly
- Lock file strategy: attempt removal inline (`rm -f .git/*.lock`); only escalate to user if removal fails

### Claude Cowork (desktop sandbox)
- Filesystem is FUSE/virtiofs-mounted — lock file removal returns "Operation not permitted"
- Lock file strategy: stop immediately, tell the user the path, wait for them to remove it from their local terminal

### Detection pattern (use in any skill that touches git)
```bash
if [ "${CLAUDE_COWORK}" = "1" ] || mount 2>/dev/null | grep -q virtiofs; then
  GIT_ENV="cowork"
else
  GIT_ENV="claude-code"
fi
```
When `GIT_ENV=cowork`: ask the user to remove lock files externally.  
When `GIT_ENV=claude-code`: remove them inline and continue.

## Agent Boundaries

### Do
- Check for stale lock files before any git operation
- Detect the environment and adapt lock file handling accordingly
- Read the workspace's `CLAUDE.md` for commit conventions before drafting commit messages
- Show diffs before committing — let the user review what's being staged
- Log decisions in DECISIONS.md before implementing structural changes
- Update CHANGELOG.md after significant work sessions

### Don't
- Auto-push or auto-merge without explicit user confirmation
- Use `git add .`, `git add -A`, or `git commit -a` — always stage explicitly
- Expose credentials, tokens, or secrets found in the working tree
- Assume `gh` (GitHub CLI) is installed — check before invoking PR-related commands
- Force-push without warning and explicit confirmation

## References

- [README.md](README.md) — human-facing overview
- [references/git-explained.md](references/git-explained.md) — git from first principles
- [DECISIONS.md](DECISIONS.md) — architectural decision log
- [ROADMAP.md](ROADMAP.md) — future directions
- [CHANGELOG.md](CHANGELOG.md) — narrative change history
