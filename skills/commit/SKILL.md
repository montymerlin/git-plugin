---
name: commit
description: >
  Stage and commit changes with a well-crafted message. Use when the user says
  "commit", "save my changes", "commit this", "git commit", "commit what we've done",
  "stage and commit", or wants to commit work to git. Reads repo-specific commit
  conventions from AGENTS.md, CLAUDE.md, or README if present. In sandboxed hosts
  (Cowork) where git writes cannot complete, produces a context-rich commit handoff
  prompt for Claude Code instead of attempting the commit.
---

# Guided Git Commit Workflow

Produce clean, meaningful commits with well-crafted messages. Follow these steps in order. Do not skip steps.

The workflow runs in one of two modes, chosen automatically in Step 1:

- **`local`** — full local terminal hosts (Claude Code, Codex, Cursor). The skill stages and commits directly.
- **`cowork`** — sandboxed hosts (Claude Cowork) where the workspace is mounted with `unlink` denied: files can be created but not deleted, so git cannot complete a commit. It leaves stale `.git/*.lock` files it can't remove, which wedges the next git operation. In this mode the skill does **not** attempt any git write. It performs all the read-only work — status, diff, convention discovery, analysis, message drafting — and emits a single, context-rich **handoff prompt** the user pastes into Claude Code, which runs the commit on the host.

Steps 2–6 are read-only and identical in both modes. Only Step 1 and Step 7 differ by environment.

## Step 1: Detect environment and handle stale lock files

**This step is mandatory before any git operation.**

Detect the host environment:

```bash
if [ "${CLAUDE_COWORK}" = "1" ] || mount 2>/dev/null | grep -q virtiofs; then
  GIT_ENV="cowork"
else
  GIT_ENV="local"
fi
```

Then check for lock files:

```bash
ls .git/*.lock 2>/dev/null
```

**Handling:**

- **`local`:** If lock files exist, remove them inline and continue:
  ```bash
  rm -f .git/*.lock
  echo "Removed stale lock files, continuing."
  ```

- **`cowork`:** Do **not** stop, and do **not** try to remove them — the sandbox can't (`rm` returns "Operation not permitted"). You will not write to the repo in this mode, so existing locks don't block the read-only work ahead. Just record which lock files are present; the handoff prompt tells Claude Code to clear them on the host before committing.

Continue to Step 2.

## Step 2: Check for repo conventions

Check if the current repo has commit conventions defined in its AGENTS.md, CLAUDE.md, or README. Look for sections like "Commit conventions", "Git workflow", or "Committing changes". If found, follow those conventions — they override the defaults in this skill.

Common repo-specific conventions include:

- Required co-author tags
- Commit message format (conventional commits, etc.)
- Files that should never be committed
- Pre-commit checks to run
- Grouped commit preferences

## Step 3: Gather context

Run these three commands in parallel (all read-only — they work in both modes):

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

In `cowork`, also lean on what you already know from the working session itself — the *why* behind the changes — since that context is the most valuable thing the handoff prompt can carry.

## Step 4: Analyse and plan

Before staging anything, think through:

1. **Are there logically separate changes?** If the working tree contains unrelated changes (e.g. a bug fix AND a new feature AND a config update), propose **grouped commits** — one per logical unit. Ask the user to confirm the grouping.

2. **Are there files that should NOT be committed?** Watch for:
   - Secrets and credentials: `.env`, `.env.*`, `credentials.json`, `.github_token`, `*.key`, `*.pem`, files containing API keys or tokens
   - Large binaries or generated files
   - OS files (`.DS_Store`, `Thumbs.db`)
   - Build artifacts (`node_modules/`, `dist/`, `__pycache__/`)
   - Stray scratch/test files left in the tree (e.g. throwaway directories, `*.lock` debris)

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

**Wait for user confirmation before proceeding.** In `local` mode, "proceeding" means executing the commits (Step 7 local). In `cowork` mode, "proceeding" means emitting the handoff prompt (Step 7 cowork) — the user reviews it before pasting it into Claude Code, which is the equivalent gate.

## Step 6: Draft the commit message

Follow the style of recent commits in the repo (from Step 3). If no clear style exists, use these defaults:

**Format:**
```
<type>: <concise summary of why, not what>

<optional body — only if the summary isn't self-explanatory>

```

**Types:** `add` (new feature/file), `update` (enhance existing), `fix` (bug fix), `refactor` (restructure without behaviour change), `docs` (documentation only), `chore` (config, deps, tooling)

**Rules:**
- Focus on the *why*, not the *what* — the diff shows the what
- Keep the summary line under 72 characters
- Use imperative mood ("add feature" not "added feature")
- Don't end the summary with a period

In `cowork`, draft the **full** message here — including a substantive body — because you have the session context Claude Code won't. A rich message now saves Claude Code from reconstructing intent from the diff later.

## Step 7: Execute

Branch on `GIT_ENV` from Step 1.

### Step 7 (local): stage and commit

**Re-check for lock files before staging** — if a previous attempt in this session failed, new locks may have been created:

```bash
ls .git/*.lock 2>/dev/null
```

If locks appeared, remove them (`rm -f .git/*.lock`) and continue.

Stage specific files (not `git add .` or `git add -A`) and commit:

```bash
git add <file1> <file2> ...
```

```bash
git commit -m "$(cat <<'EOF'
<commit message here>
EOF
)"
```

For grouped commits, execute each group sequentially — stage, commit, then move to the next group.

### Step 7 (cowork): generate the commit handoff prompt

Do **not** run `git add`, `git commit`, or `git push` — they cannot complete on the mounted filesystem, and a partial attempt leaves stale locks that wedge the repo. And do **not** hand the user literal git commands to run: a fresh Claude Code session knows the repo and its conventions and will pick better mechanics than you can predefine from inside the sandbox.

Instead produce **one deliverable**: a single, self-contained **handoff prompt** the user copies into a Claude Code chat opened in the repo. Your advantage is context — you watched the session happen. Pack that context into the prompt so Claude Code grasps intent quickly and can use the diff to verify the change rather than to reconstruct what happened. The prompt carries the substance (what changed, why, which files, the message); Claude Code decides the mechanics.

**Render the prompt inside a fenced code block** so it's one-click copyable. It must include:

1. **Framing** — one line telling Claude Code it's committing work from a separate session and has no prior context, so everything it needs is below.
2. **Repo** — the repo name and, if known, its path on the user's machine. Never a sandbox path (`/sessions/...`, `/mnt/.virtiofs-root/...`) — those don't exist on the host.
3. **Session summary** — 2–5 lines on what was done and *why*, in enough detail that Claude Code grasps intent from the summary and can use the diff to verify it. This is the whole point of the handoff.
4. **What to commit** — the explicit files to stage, and anything to exclude (secrets, scratch, ambiguous untracked items, submodule pointers). State these as intent ("stage these / exclude these"), not as `git add` commands.
5. **The commit message** — the full message drafted in Step 6. Delimit it with sentinel lines (`=== MESSAGE START ===` / `=== MESSAGE END ===`) rather than nested backticks, since the whole prompt is already in a code block.
6. **Instructions to Claude Code** — clear any stale `.git/*.lock` first, follow the repo's AGENTS.md/CLAUDE.md commit conventions, commit the staged files, then push; report the resulting commit hash. Explicitly tell it to choose whatever git commands it judges best.

For grouped commits, describe each group (summary + files + message) in order within the same prompt, and tell Claude Code to make them separate commits.

**Template:**

```text
You're committing work from a separate Cowork session — you have no prior
context, so the summary below explains the intent. Review the staged diff to
confirm it matches this summary before committing.

Repo: <repo-name> (<path-on-host if known>)

What happened this session:
- <why-focused summary line>
- <...>

Commit this:
- Stage: <explicit files>
- Exclude: <files/dirs, if any, and why>

Commit message:
=== MESSAGE START ===
<type>: <subject>

<body>
=== MESSAGE END ===

Then: clear any stale .git/*.lock, follow this repo's AGENTS.md / CLAUDE.md
commit conventions, review the staged diff as a sanity check, commit the
staged files, and push. Use whatever git commands you judge best. Report the
commit hash.
```

The explicit staged-file list and the drafted message are the safety rails — keep them precise and faithful to Steps 4–6. Everything about *how* to run git is Claude Code's call.

## Step 8: Verify

- **`local`:** run `git status && git log --oneline -3`, confirm the commit landed, and report. Do **not** push unless the user explicitly asks — committing and pushing are separate decisions.
- **`cowork`:** you did not write, so there is nothing to verify in-session. Tell the user the handoff prompt is ready to paste into Claude Code, and offer to re-read `git status` / `git log` afterward (reads work in the sandbox) to confirm the commit landed and the tree is clean.

## Edge cases

- **Nothing to commit:** If `git status` shows a clean working tree, tell the user there's nothing to commit. Don't create an empty commit (or an empty handoff).
- **Merge conflicts:** If there are unresolved conflicts, surface them and help resolve before committing. In `cowork`, note that the resolution also needs to happen on the host.
- **Detached HEAD:** Warn the user if they're in detached HEAD state — committing here is usually not what they want.
- **Large number of files:** If there are 20+ changed files, always propose grouped commits rather than one massive commit.
- **Pre-commit hooks fail:** (`local`) If a commit fails due to hooks, diagnose the issue, fix it, and create a NEW commit (never `--amend` the previous commit, as the failed commit didn't land). In `cowork`, mention any hooks the repo defines so the user expects them to run on the host.
- **Lock files appear mid-workflow:** In `local`, if a git command fails and creates new lock files, remove them and retry. In `cowork` you don't run writes, so the skill won't create locks; the handoff prompt tells Claude Code to clear any pre-existing ones.
