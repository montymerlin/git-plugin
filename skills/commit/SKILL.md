---
name: git:commit
description: >
  Stage and commit changes with a well-crafted message. Use when the user says
  "commit", "save my changes", "commit this", "git commit", "commit what we've done",
  "stage and commit", or wants to commit work to git. Reads repo-specific commit
  conventions from CLAUDE.md if present.
---

# Guided Git Commit Workflow

Produce clean, meaningful commits with well-crafted messages. Follow these steps in order. Do not skip steps.

## Step 1: Check for stale lock files

**This step is mandatory before any git operation.** Sandboxed environments (Claude Desktop Cowork, remote containers) mount the host filesystem via FUSE/virtiofs. Lock files left by previous sessions persist and **cannot be deleted from within the sandbox** — you'll get "Operation not permitted."

Run:

```bash
ls .git/*.lock 2>/dev/null
```

If any `.lock` files exist:

1. **Stop immediately.** Do not attempt any git operations — they will fail and may create *additional* lock files, compounding the problem.
2. Tell the user which lock files exist and ask them to remove them from their local terminal:
   ```
   rm -f <repo-path>/.git/*.lock
   ```
3. Wait for the user to confirm the locks are cleared before proceeding to Step 2.

If no lock files exist, continue.

## Step 2: Check for repo conventions

Check if the current repo has commit conventions defined in its CLAUDE.md or README. Look for sections like "Commit conventions", "Git workflow", or "Committing changes". If found, follow those conventions — they override the defaults in this skill.

Common repo-specific conventions include:

- Required co-author tags
- Commit message format (conventional commits, etc.)
- Files that should never be committed
- Pre-commit checks to run
- Grouped commit preferences

## Step 3: Gather context

Run these three commands in parallel:

```bash
git status
```

```bash
git diff --stat && echo "---STAGED---" && git diff --cached --stat
```

```bash
git log --oneline -5
```

This tells you:

- What's changed (untracked, modified, staged)
- The scale of changes (files and lines)
- Recent commit style (match it)

## Step 4: Analyse and plan

Before staging anything, think through:

1. **Are there logically separate changes?** If the working tree contains unrelated changes (e.g. a bug fix AND a new feature AND a config update), propose **grouped commits** — one per logical unit. Ask the user to confirm the grouping.

2. **Are there files that should NOT be committed?** Watch for:
   - Secrets and credentials: `.env`, `.env.*`, `credentials.json`, `.github_token`, `*.key`, `*.pem`, files containing API keys or tokens
   - Large binaries or generated files
   - OS files (`.DS_Store`, `Thumbs.db`)
   - Build artifacts (`node_modules/`, `dist/`, `__pycache__/`)

   **Never commit files likely containing secrets.** If any are present, warn the user and exclude them from the commit. If the user specifically asks to commit them, confirm they understand the risk.

3. **Is this a single coherent change?** If yes, proceed to Step 5.

## Step 5: Present the commit plan

Show the user a clear summary:

```
Commit plan:
- Files to stage: [list]
- Files excluded: [list, if any]
- Commit message (draft): "..."
```

For grouped commits, show each group separately:

```
Commit 1 of 3: [description]
- Files: [list]
- Message: "..."

Commit 2 of 3: [description]
...
```

**Wait for user confirmation before proceeding.** If the user says "go ahead" or similar, execute all commits. If they want changes, adjust the plan.

## Step 6: Draft the commit message

Follow the style of recent commits in the repo (from Step 3). If no clear style exists, use these defaults:

**Format:**
```
<type>: <concise summary of why, not what>

<optional body — only if the summary isn't self-explanatory>

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Types:** `add` (new feature/file), `update` (enhance existing), `fix` (bug fix), `refactor` (restructure without behaviour change), `docs` (documentation only), `chore` (config, deps, tooling)

**Rules:**
- Focus on the *why*, not the *what* — the diff shows the what
- Keep the summary line under 72 characters
- Use imperative mood ("add feature" not "added feature")
- Don't end the summary with a period
- Include `Co-Authored-By: Claude <noreply@anthropic.com>` unless repo conventions specify otherwise

## Step 7: Execute

**Re-check for lock files before staging** — if a previous attempt in this session failed, new locks may have been created:

```bash
ls .git/*.lock 2>/dev/null
```

If locks appeared, stop and ask the user to clear them (same as Step 1).

Stage specific files (not `git add .` or `git add -A`) and commit:

```bash
git add <file1> <file2> ...
```

```bash
git commit -m "$(cat <<'EOF'
<commit message here>

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

For grouped commits, execute each group sequentially — stage, commit, then move to the next group.

## Step 8: Verify

After committing, run:

```bash
git status && git log --oneline -3
```

Confirm the commit landed correctly. Report the result to the user.

**Do NOT push** unless the user explicitly asks to push. Committing and pushing are separate decisions.

## Edge cases

- **Nothing to commit:** If `git status` shows a clean working tree, tell the user there's nothing to commit. Don't create an empty commit.
- **Merge conflicts:** If there are unresolved conflicts, surface them and help resolve before committing.
- **Detached HEAD:** Warn the user if they're in detached HEAD state — committing here is usually not what they want.
- **Large number of files:** If there are 20+ changed files, always propose grouped commits rather than one massive commit.
- **Pre-commit hooks fail:** If a commit fails due to hooks, diagnose the issue. Fix it and create a NEW commit (never `--amend` the previous commit, as the failed commit didn't land).
- **Lock files appear mid-workflow:** If a git command fails and creates new lock files, stop immediately. Tell the user to clear all `.git/*.lock` files from their local terminal before retrying. Do not attempt further git operations.
