---
name: pr
description: >
  Create a pull request with a well-structured description. Use when the user says
  "create a PR", "open a pull request", "submit PR", "make a PR", "pr this",
  "push and PR", or wants to create a pull request on GitHub. Requires the gh CLI.
---

# Guided Pull Request Workflow

Create well-structured pull requests with meaningful descriptions. Follow these steps in order.

## Step 1: Check for stale lock files

Run:

```bash
ls .git/*.lock 2>/dev/null
```

If any `.lock` files exist, stop immediately and ask the user to clear them from their local terminal (see the commit skill for full instructions). Do not proceed until confirmed.

## Step 2: Check for repo conventions

Check if the current repo has PR conventions defined in its CLAUDE.md or README. Look for sections like "Pull request conventions", "PR template", or "Contributing guidelines". If found, follow those conventions.

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

## Step 7: Report

Show the user the PR URL. If `gh pr create` returns the URL, present it directly. Otherwise run:

```bash
gh pr view --web
```

**Do NOT merge** unless the user explicitly asks. Creating and merging are separate decisions.

## Edge cases

- **No gh CLI:** If `gh` is not available, tell the user to install it (`brew install gh` or see https://cli.github.com) and authenticate (`gh auth login`). Do not attempt to create PRs via the API manually.
- **No remote:** If the repo has no remote configured, tell the user and stop.
- **Uncommitted changes:** Ask whether to commit first, stash, or proceed without them.
- **Branch is main/master:** Warn the user — PRs from the default branch are unusual. Ask if they meant to create a feature branch first.
- **Auth failure:** If `gh` returns an auth error, tell the user to run `gh auth login` and try again.
