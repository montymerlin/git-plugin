# git-plugin

Git workflow toolkit for Claude Code, Cursor, and Cowork. Guided commits, pull requests, and repo orientation — with environment-aware handling for FUSE/virtiofs sandboxed environments.

## What's included

### Skills

| Skill | Trigger phrases | What it does |
|-------|----------------|--------------|
| `/commit` | "commit", "save my changes", "git commit" | Guided staging and committing with smart grouping, safety checks, and convention-aware message drafting |
| `/pr` | "create a PR", "open a pull request", "submit PR" | Guided pull request creation with structured descriptions, push handling, and template support |
| `/status` | "what's the status", "where are we", "orient me" | Comprehensive repo overview — branch, working tree, recent history, stashes, and health checks |
| `/logchange` | "logchange", "update changelog", "what's changed" | *(moved to agentic-scaffold-plugin)* Maintain a human-readable CHANGELOG.md — distills git history into high-level summaries |

### References

| Document | What it covers |
|----------|---------------|
| `references/git-explained.md` | Git from first principles — mental model, essential workflow, collaboration, advanced concepts, and sandboxed environment gotchas |

### Key features

**Environment-aware lock file handling** — All skills detect whether they're running in Claude Code CLI/Cursor (full filesystem access) or Cowork (FUSE/virtiofs sandbox) and handle stale `.git/*.lock` files accordingly. In CLI environments, locks are removed inline and the workflow continues. In Cowork, the skill stops immediately and tells you exactly which file to remove from your local terminal.

**Convention-aware** — The commit skill reads `CLAUDE.md` and `README` for repo-specific commit conventions (message format, co-author tags, excluded files, grouped commit preferences) and follows them automatically.

**Safety-first** — Never auto-pushes. Never uses `git add .` or `git add -A`. Warns about secrets, large binaries, and detached HEAD. Proposes grouped commits for unrelated changes. Always asks for confirmation before executing.

## Environments

### Claude Code CLI / Cursor
- Bash tool has full filesystem access
- Stale lock files are removed inline and the workflow continues automatically

### Claude Cowork (desktop sandbox)
- Filesystem is FUSE/virtiofs-mounted — direct lock file removal is not permitted from within the agent
- Skills stop and ask you to run `rm -f <repo-path>/.git/*.lock` from your local terminal, then continue once confirmed

## Installation

### Claude Desktop (Cowork)

Open the `.plugin` file in Claude Desktop, or install from the plugin marketplace:

```
/plugin install git
```

### Claude Code CLI

Copy the skills to your global skills directory:

```bash
# Clone the repo
git clone https://github.com/montymerlin/git-plugin.git

# Copy skills to Claude Code's global config
cp -r git-plugin/skills/* ~/.claude/skills/
```

Or install as a project-level plugin by copying the plugin directory into your project.

## Per-repo customisation

The commit skill checks your repo's `CLAUDE.md` for a "Commit conventions" section. Add one to override the plugin's defaults:

```markdown
## Commit conventions

**Message format:**
- Use conventional commits: `feat:`, `fix:`, `docs:`, `chore:`
- Always include `Co-Authored-By: Claude <noreply@anthropic.com>`

**Rules:**
- Never commit `.env` or `credentials.json`
- Group research edits and config changes into separate commits
```

The PR skill similarly checks for PR templates in `.github/pull_request_template.md`.

## Requirements

- **git** — any recent version
- **gh** (GitHub CLI) — required for the `/pr` skill. Install: `brew install gh` or see [cli.github.com](https://cli.github.com)

## Roadmap

Future skills under consideration:

- `/review` — Review a PR or set of changes before merging
- `/branch` — Create/switch/clean up branches with naming conventions
- `/sync` — Pull/rebase with conflict handling guidance
- `/release` — Tag and release workflow
- `/diff` — Review changes with context before committing

## License

MIT
