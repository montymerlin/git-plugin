# Setup Guide

**git-plugin** — Git workflow toolkit for local terminal hosts and constrained sandboxes. Guided commits, pull requests, and repo orientation with AGENTS.md-aware convention discovery.

---

## Quick Install (for AI agents)

If you're an AI agent that has been asked to install this plugin, follow this decision tree. **Detect the host first**, then pick the matching path. Only ask the user the questions explicitly listed below — everything else can be inferred.

```
1. Detect host:
   ├── Cowork (Claude Desktop, sandboxed)
   │     → Path A: Cowork upload
   │     → No questions needed; proceed.
   │
   ├── Claude Code CLI (terminal, has `claude` command)
   │     → Path B: claude plugins install
   │     → ASK USER: "Install globally (available in every project)
   │                  or locally (this project only)?"
   │       • global → `claude plugins install github.com/montymerlin/git-plugin`
   │       • local  → symlink `ln -s <path> ./.claude/plugins/git-plugin`
   │
   ├── Codex (terminal, has `codex` command or $CODEX_HOME set)
   │     → Path C: bash scripts/install_codex_skills.sh --from-github
   │     → No questions needed.
   │
   ├── Cursor / VS Code
   │     → NOT COMPATIBLE (no skill UI). Tell the user; suggest Claude Code instead.
   │
   └── Unknown / custom Agent SDK host
         → Path D: Raw skills — copy `skills/*/SKILL.md` into the host's skill dir.
```

**Host detection signals:**
- `$CLAUDE_COWORK == "1"` or `mount | grep virtiofs` matches → Cowork
- `command -v claude` succeeds and not Cowork → Claude Code CLI
- `command -v codex` succeeds or `$CODEX_HOME` is set → Codex
- Otherwise → ask the user which environment they're in.

---

## Compatibility Matrix

| Host                  | Status         | Notes                                                |
|:---------------------|:---------------|:-----------------------------------------------------|
| **Cowork**           | ✓              | Upload `.plugin` from `_dist/`; slash commands `/commit`, `/pr`, `/status` |
| **Claude Code CLI**  | ✓              | `claude plugins install …`; skills load automatically |
| **Codex**            | ✓ partial      | `scripts/install_codex_skills.sh`; Codex-only, no local terminal lock handling |
| **Cursor / VS Code** | ✗              | Not compatible (no skill slash-command UI in these hosts) |
| **Agent SDK**        | ✓              | Standard plugin loader; use raw skills from `skills/` |
| **Anthropic API**    | partial        | Manual skill loading via SKILL.md into system prompts |

---

## Install Paths

### Cowork (Claude Desktop)

**Best UX**: one-click install, automatic skill discovery in `/` menu.

You need a `.plugin` zip to upload. Get one of these three ways:

**Option 1 — pre-built release (preferred when available):**
Download `git-<version>.plugin` from the GitHub Releases page of `montymerlin/git-plugin`.

**Option 2 — built locally from this repo:**

```bash
git clone https://github.com/montymerlin/git-plugin.git
cd git-plugin
zip -r /tmp/git-0.4.0.plugin . \
  -x "*.DS_Store" "*/__pycache__/*" "*.pyc" ".git/*" "node_modules/*" "*.log" "_dist/*"
```

The output `/tmp/git-0.4.0.plugin` is your upload artifact.

**Option 3 — built by the workspace `cowork-plugin-packager` skill** (montymerlinHQ collaborators only):
The packaged file lives at `ops/plugins/_dist/git-0.4.0.plugin` after running the skill.

Then upload:

1. Open Claude Desktop → **Cowork** → **Plugins** (sidebar).
2. Click **+ Add plugin** → **Upload a file** → select the `.plugin`.
3. Confirm. Skills appear immediately under `/commit`, `/pr`, `/status`.

For organization-wide install: **Organization settings** → **Plugins** → **Add plugins** → **Upload a file**.

**Pre-upload verification (recommended):**

```bash
# Confirm the manifest is at the zip root (must show .claude-plugin/plugin.json)
unzip -l /tmp/git-0.4.0.plugin | head -20

# Confirm size is under 50 MB
du -h /tmp/git-0.4.0.plugin
```

**Known quirks**:
- File size limit: **50 MB**. (git-plugin packages to ~25 KB so this is never an issue.)
- Some Claude Desktop builds reject `.plugin` at the upload dialog despite accepting it. Workaround: rename to `.zip` (contents identical). Tracked in [anthropics/claude-code#28337](https://github.com/anthropics/claude-code/issues/28337) and [#40414](https://github.com/anthropics/claude-code/issues/40414).
- The `.plugin` zip must have `.claude-plugin/plugin.json` at **top level** (not nested inside an extra parent directory). The `zip` command above is run from inside the plugin dir specifically to avoid this.

---

### Claude Code CLI

**Best for**: developers in the terminal.

Two install scopes — **ask the user which one fits**:

- **Global** (available in every project on this machine): use `claude plugins install …`
- **Local** (this project only, lives in `./.claude/plugins/`): symlink the repo into the project

**Global install** from the public repo:

```bash
claude plugins install github.com/montymerlin/git-plugin
```

Or via marketplace JSON (for org-internal distribution):

```bash
claude plugins marketplace add git-plugin --url <marketplace.json>
claude plugins install git-plugin
```

**Local install** (project-scoped):

```bash
git clone https://github.com/montymerlin/git-plugin.git ~/src/git-plugin
mkdir -p ./.claude/plugins
ln -s ~/src/git-plugin ./.claude/plugins/git-plugin
```

Skills load automatically once installed. Type `/commit`, `/pr`, `/status` in Claude Code chat.

---

### Codex

Codex reads global Codex skill stubs that source from a vendor-cloned git-plugin repo.

```bash
bash scripts/install_codex_skills.sh --from-github
```

This script:
1. Clones (or updates) `git-plugin` to `~/.codex/vendor_imports/repos/git-plugin/`.
2. Links skills into `~/.codex/skills/git-commit/`, `git-pr/`, `git-status/`.
3. Injects skill UI stubs that source from the vendor repo.

Restart Codex to pick up new skills.

**Note**: Codex skills run in a terminal without sandbox constraints, so lock-file handling is like local terminal hosts (see "Host-aware lock handling" below).

---

### Cursor / VS Code

**Not compatible.** These hosts use MCP servers but do not load Claude plugin skill slash-commands. If a future version of git-plugin includes an MCP server, you can wire it into `.cursor/mcp.json` or `~/.continue/config.json`, but the `/commit`, `/pr`, `/status` UI would not be available.

---

### Raw Skills (Any Host)

For hosts that don't support Claude plugin manifests, use raw markdown skills directly:

1. Copy `skills/commit/SKILL.md`, `skills/pr/SKILL.md`, `skills/status/SKILL.md` into your host's skill directory.
2. Copy `references/` (optional, for extra context).
3. The skills invoke git via bash; ensure `git` (and `gh` for `/pr`) are in `PATH`.

This is the fallback for Agent SDK custom hosts and direct Anthropic API integration.

---

## Runtime Requirements

- **git** — any recent version
- **gh** — required for `/pr` (pull request creation); install from https://cli.github.com/

---

## Host-aware Lock Handling

This plugin distinguishes between **local terminal hosts** (Claude Code, Codex, Cursor) and **Cowork sandboxes**.

### Local Terminal Hosts
Claude Code, Codex, and Cursor can remove stale `.git/*.lock` files inline. If `/commit`, `/pr`, or `/status` encounter a lock file, the skill will offer to clear it and retry.

### Cowork Sandbox
Cowork-style sandboxed environments cannot remove `.git/*.lock` files from inside the session. The skills stop, report the lock file path, and ask you to clear it from a local terminal:

```bash
# From your local terminal:
rm /path/to/repo/.git/*.lock
```

Then return to Cowork and retry the skill.

---

## Conventions & Repo Discovery

The plugin reads local repository conventions from:
1. `AGENTS.md` (preferred)
2. `CLAUDE.md` (fallback)
3. `README.md` (last resort)

When you use `/commit` or `/pr`, the skill scans the target repo for these files to discover commit/PR naming conventions, co-author preferences, and branch strategies. This allows the same plugin to adapt to different repos without manual configuration.

---

## License

MIT
