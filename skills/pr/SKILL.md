---
name: pr
description: >
  Create a pull request with a well-structured description. Use when the user says
  "create a PR", "open a pull request", "submit PR", "make a PR", "pr this",
  "push and PR", or wants to create a pull request on GitHub. Requires the gh CLI.
---

# Guided Pull Request Workflow

Create well-structured pull requests with meaningful descriptions. Follow these steps in order.

## Step 1: Detect environment and handle stale lock files

**This step is mandatory before any git operation.**

First detect the host environment:

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

- **`cowork`:** A PR needs `git push` and `gh`, neither of which can run in the sandbox (the workspace mount denies `unlink`, and the sandbox has no GitHub credentials). Do **not** stop and do **not** try to remove locks — instead, do all the read-only analysis (Steps 2–5) and emit a **handoff** in Step 6 for the user to run on the host. Just note any present lock files; the handoff folds in a `rm -f .git/*.lock` line.

Continue to Step 2.

## Step 2: Check for repo conventions

Check if the current repo has PR conventions defined in its AGENTS.md, CLAUDE.md, or README. Look for sections like "Pull request conventions", "PR template", or "Contributing guidelines". If found, follow those conventions.

Also check for a PR template:

```bash
ls .github/pull_request_template.md .github/PULL_REQUEST_TEMPLATE.md .github/PULL_REQUEST_TEMPLATE/ 2>/dev/null
```

If a template exists, read it and use its structure.

## Step 3: Gather context

Run these commands in parallel:

```bash
git status
```

```bash
git branch -vv
```

```bash
git log --oneline -10
```

Determine:

- **Current branch** and whether it tracks a remote
- **Base branch** — usually `main` or `master`. Check which exists:
  ```bash
  git rev-parse --verify main 2>/dev/null && echo "main" || echo "master"
  ```
- **Whether there are uncommitted changes** — if so, ask the user if they want to commit first (invoke the commit skill)
- **Whether the branch needs to be pushed** — check if the remote tracking branch is behind

## Step 4: Analyse the changes

Get the full picture of what this PR contains:

```bash
git log --oneline <base-branch>..HEAD
```

```bash
git diff --stat <base-branch>..HEAD
```

For understanding the substance of changes, read the diff:

```bash
git diff <base-branch>..HEAD
```

If the diff is very large (50+ files), focus on the `--stat` output and commit messages to understand the scope rather than reading the full diff.

## Step 5: Draft the PR

Draft a title and description based on the changes:

**Title rules:**
- Under 70 characters
- Use imperative mood ("Add feature" not "Added feature")
- Be specific — "Add FUSE lock detection to commit workflow" not "Update git stuff"

**Description structure:**

```markdown
## Summary
<1-3 bullet points explaining what and why>

## Changes
<Brief description of the key changes, grouped logically>

## Test plan
<How to verify this works — steps, commands, or checklist>
```

If the repo has a PR template, use that structure instead.

Present the draft to the user:

```
PR plan:
- Base: main ← feature-branch
- Title: "..."
- Description: [show draft]
- Needs push: yes/no
```

**Wait for user confirmation.** Adjust if requested.

## Step 6: Execute

Branch on `GIT_ENV` from Step 1.

### Step 6 (local): push and create the PR

Push if needed:

```bash
git push -u origin <branch-name>
```

Create the PR:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
<description body>
EOF
)"
```

If targeting a non-default base branch, add `--base <branch>`.

### Step 6 (cowork): generate the PR handoff prompt

Push and `gh pr create` can't run in the sandbox, and a fresh Claude Code session will choose better mechanics than predefined commands. Produce **one deliverable**: a single, self-contained **handoff prompt** the user pastes into a Claude Code chat opened in the repo. Render it inside a fenced code block so it's one-click copyable. Carry the context you have from the session so Claude Code doesn't rebuild it from the diff. Never use a sandbox path (`/sessions/...`, `/mnt/.virtiofs-root/...`) — reference the repo by name/host path.

The prompt must include: framing (opening a PR for work from a separate session, no prior context); the repo; the branch and base; a short why-focused summary of what the PR contains; the PR title; the full PR description (delimited with sentinel lines, not nested backticks); and instructions to push the branch, open the PR with `gh` following any repo PR template/conventions, report the PR URL, and not merge. Let Claude Code pick the commands.

**Template:**

```text
You're opening a PR for work from a separate Cowork session — no prior
context, so it's all here.

Repo: <repo-name> (<path-on-host if known>)
Branch: <branch> → base <base-branch>

What this PR contains:
- <why-focused summary line(s)>

PR title: <title>

PR description:
=== DESCRIPTION START ===
<description body>
=== DESCRIPTION END ===

Then: clear any stale .git/*.lock, push the branch, and open the PR with gh
(follow any PR template/conventions in the repo). Use whatever commands you
judge best. Report the PR URL. Don't merge.
```

`gh` must be installed and authenticated on the host (`gh auth login`).

## Step 7: Report

- **`local`:** Show the user the PR URL. If `gh pr create` returns the URL, present it directly. Otherwise run `gh pr view --web`.
- **`cowork`:** Confirm the handoff is ready to run on the host; offer to re-read state afterward to verify the branch pushed.

**Do NOT merge** unless the user explicitly asks. Creating and merging are separate decisions.

## Edge cases

- **No gh CLI:** If `gh` is not available, tell the user to install it (`brew install gh` or see https://cli.github.com) and authenticate (`gh auth login`). Do not attempt to create PRs via the API manually.
- **No remote:** If the repo has no remote configured, tell the user and stop.
- **Uncommitted changes:** Ask whether to commit first, stash, or proceed without them.
- **Branch is main/master:** Warn the user — PRs from the default branch are unusual. Ask if they meant to create a feature branch first.
- **Auth failure:** If `gh` returns an auth error, tell the user to run `gh auth login` and try again.
