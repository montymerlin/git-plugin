---
name: git:status
description: >
  Get a comprehensive overview of the current git repo state. Use when the user says
  "what's the status", "where are we", "git status", "what's changed", "orient me",
  "what branch am I on", or at the start of a session when the user wants to understand
  the current state of the repo before doing work.
---

# Git Status Overview

Provide a comprehensive, human-readable orientation to the current repo state. Useful at the start of any session in a local terminal host or Cowork.

## Step 1: Check for stale lock files

Run:

```bash
ls .git/*.lock 2>/dev/null
```

If any exist, warn the user immediately — these will block all git operations. Detect the environment to advise the correct fix:

```bash
if [ "${CLAUDE_COWORK}" = "1" ] || mount 2>/dev/null | grep -q virtiofs; then
  GIT_ENV="cowork"
else
  GIT_ENV="local"
fi
```

- **Local terminal host (`GIT_ENV=local`):** Remove inline: `rm -f .git/*.lock`
- **Cowork (`GIT_ENV=cowork`):** Ask the user to run `rm -f <repo-path>/.git/*.lock` from their local terminal

Report the lock status regardless, then continue gathering the rest of the overview.

## Step 2: Gather repo state

Run these commands in parallel:

```bash
git branch -vv
```

```bash
git status --short
```

```bash
git log --oneline -5
```

```bash
git stash list
```

```bash
git remote -v
```

## Step 3: Present the overview

Summarise the repo state in a clear, scannable format. Include:

**Branch:** Current branch name, whether it tracks a remote, and how far ahead/behind it is.

**Working tree:** Summarise the state — clean, or list changed/untracked files. If there are many changes, group by type (modified, added, deleted, untracked).

**Recent commits:** Show the last 3-5 commits with their messages. Note if they follow a consistent style.

**Stashes:** Mention if any stashes exist (easy to forget about).

**Remotes:** List configured remotes.

**Health check:** Flag anything unusual:
- Detached HEAD
- Unmerged paths (merge conflicts)
- Large number of untracked files
- Branch significantly behind remote
- Lock files present (from Step 1)

Keep the presentation concise — this is orientation, not a detailed audit. The user should be able to glance at it and know where they stand.
