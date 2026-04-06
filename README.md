# git-cowork

Git workflow toolkit for Claude Cowork. Guided commits, pull requests, and repo orientation — with built-in handling for FUSE/virtiofs sandboxed environments.

## What's included

### Skills

| Skill | Trigger phrases | What it does |
|-------|----------------|--------------|
| `/commit` | "commit", "save my changes", "git commit" | Guided staging and committing with smart grouping, safety checks, and convention-aware message drafting |
| `/pr` | "create a PR", "open a pull request", "submit PR" | Guided pull request creation with structured descriptions, push handling, and template support |
| `/status` | "what's the status", "where are we", "orient me" | Comprehensive repo overview — branch, working tree, recent history, stashes, and health checks |

### References

| Document | What it covers |
|----------|---------------|
| `references/git-explained.md` | Git from first principles — mental model, essential workflow, collaboration, advanced concepts, and sandboxed environment gotchas |

### Key features

**FUSE lock detection** — All skills check for stale `.git/*.lock` files before running any git command. In sandboxed environments (Cowork, remote containers), lock files from previous sessions can persist and block all git operations. The plugin catches this early and guides you through the fix, preventing cascading failures.

**Convention-aware** — The commit skill reads `CLAUDE.md` and `README` for repo-specific commit conventions (message format, co-author tags, excluded files, grouped commit preferences) and follows them automatically.

**Safety-first** — Never auto-pushes. Never uses `git add .` or `git add -A`. Warns about secrets, large binaries, and detached HEAD. Proposes grouped commits for unrelated changes. Always asks for confirmation before executing.

## Installation

### Claude Desktop (Cowork)

Open the `.plugin` file in Claude Desktop, or install from the plugin marketplace:

```
/plugin install git-cowork
```

### Claude Code CLI

Copy the skills to your global skills directory:

```bash
# Clone the repo
git clone https://github.com/montymerlin/git-cowork-plugin.git

# Copy skills to Claude Code's global config
cp -r git-cowork-plugin/skills/* ~/.claude/skills/
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

## License

MIT
