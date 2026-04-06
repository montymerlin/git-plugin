# Git Explained

A guide to git — from the mental model that makes everything click to the advanced workflows that keep teams sane. Written for people who want to understand what they're doing, not just memorise commands.

## Part 1: The Mental Model

### What git actually is

Git is a system for recording the history of a set of files. At its core, it's a directed graph of snapshots. Every time you commit, git takes a photograph of every file in your project and stores a reference to that snapshot. If a file hasn't changed, git doesn't store it again — it links to the previous identical version.

Think of it like a journal. Each entry (commit) says "here's what everything looked like at this moment" and has a note explaining why things changed. You can flip back to any page and see the project exactly as it was.

### The three places your work lives

Git organises your files into three areas:

**Working directory** — the actual files on your disk. This is what you see in your file explorer or editor. When you edit a file, you're changing the working directory.

**Staging area** (also called the "index") — a holding pen for changes you intend to commit. When you `git add` a file, you're moving it from the working directory into the staging area. Think of it as a draft of your next commit.

**Repository** (the `.git` folder) — the permanent history. When you `git commit`, everything in the staging area becomes a new entry in the history. It's now recorded forever (or until you deliberately rewrite history, which we'll get to).

This three-stage design is one of git's most powerful features. It lets you edit ten files but commit only three of them — grouping related changes into meaningful commits rather than dumping everything in at once.

### Commits: the atoms of history

A commit is a snapshot plus metadata:

- **The snapshot** — the state of every tracked file at that moment
- **A message** — your explanation of what changed and why
- **A parent pointer** — which commit came before this one (this is what creates the history chain)
- **An author and timestamp**

Every commit gets a unique identifier — a 40-character hash like `a1b2c3d4e5f6...`. You'll usually see just the first 7 characters (`a1b2c3d`), which is enough to be unique in most projects.

### Branches: movable bookmarks

A branch is just a pointer to a commit. That's it. When people talk about "the main branch," they mean a pointer called `main` that points to some commit. When you make a new commit on a branch, the pointer moves forward to the new commit.

Creating a branch is instant and essentially free — git just creates a new pointer. This is why git encourages branching for everything: experiments, features, fixes. If the experiment fails, delete the pointer. The commits will eventually be cleaned up automatically.

**HEAD** is a special pointer that tells git "which branch am I currently on?" When you `git checkout main`, HEAD points to `main`. When you make a commit, HEAD's branch moves forward.

## Part 2: The Essential Workflow

### Starting out

```bash
git init                    # Create a new repo in the current directory
git clone <url>             # Copy an existing repo from a remote server
```

`git clone` does three things: downloads the full history, sets up a remote called `origin` pointing to where you cloned from, and checks out the default branch.

### The daily cycle

The basic rhythm of working with git:

```bash
git status                  # See what's changed
git add <file>              # Stage specific changes
git commit -m "message"     # Record the staged changes
```

**`git status`** is your compass. Run it constantly. It tells you which files are modified, which are staged, and which are untracked (new files git doesn't know about yet).

**`git add`** is selective. You choose exactly which changes to include:

```bash
git add index.html          # Stage one file
git add src/                # Stage everything in a directory
git add -p                  # Stage parts of files interactively
```

The `-p` (patch) flag is worth learning early. It shows you each chunk of changes and asks whether to stage it. This lets you commit part of a file's changes while leaving the rest for a separate commit.

**`git commit`** records the snapshot. Write a message that explains *why* you made the change, not *what* you changed (the diff already shows the what):

```bash
# Good
git commit -m "fix: prevent duplicate entries when user submits form twice"

# Less useful
git commit -m "changed form handler"
```

### Seeing what happened

```bash
git log                     # Full commit history
git log --oneline           # Compact one-line-per-commit view
git log --oneline -10       # Last 10 commits
git diff                    # Changes in working directory (not yet staged)
git diff --staged           # Changes in staging area (ready to commit)
git diff main..feature      # Difference between two branches
```

### Undoing things

Git provides several ways to undo, each with different safety levels:

```bash
git restore <file>          # Discard working directory changes (DESTRUCTIVE)
git restore --staged <file> # Unstage a file (keeps the changes in working directory)
git revert <commit>         # Create a new commit that undoes a previous commit (SAFE)
git reset --soft HEAD~1     # Undo last commit, keep changes staged
git reset --mixed HEAD~1    # Undo last commit, keep changes in working directory
git reset --hard HEAD~1     # Undo last commit entirely (DESTRUCTIVE)
```

**The safe rule:** `git revert` is always safe — it creates a *new* commit that reverses an old one, so history is preserved. `git reset --hard` and `git restore` can permanently destroy work. Use them deliberately.

### Stashing: saving work for later

Sometimes you need to switch branches but aren't ready to commit:

```bash
git stash                   # Save current changes and clean the working directory
git stash list              # See all stashes
git stash pop               # Restore the most recent stash (and remove it)
git stash apply             # Restore the most recent stash (keep it in the list)
git stash drop              # Delete a stash without applying it
```

Stashes are a stack — last in, first out. They're great for quick context switches but easy to forget about. Run `git stash list` occasionally to check.

## Part 3: Collaboration

### Remotes: connecting to other copies

A remote is a bookmark pointing to another copy of the repository, usually on a server like GitHub, GitLab, or Bitbucket:

```bash
git remote -v               # List remotes
git remote add origin <url> # Add a remote
```

When you clone a repo, git automatically creates a remote called `origin` pointing to where you cloned from.

### Fetching, pulling, pushing

```bash
git fetch                   # Download new commits from remote (doesn't change your files)
git pull                    # Fetch + merge remote changes into your current branch
git push                    # Upload your commits to the remote
git push -u origin <branch> # Push a new branch and set up tracking
```

**`git fetch`** is always safe — it just downloads. Your working directory doesn't change.

**`git pull`** fetches and then integrates. By default it merges, but many teams prefer `git pull --rebase` which replays your local commits on top of the remote changes, keeping a cleaner history.

**`git push`** uploads your commits. It will only work if you're up to date — if someone else pushed first, you'll need to pull (and possibly resolve conflicts) before pushing.

### Branches in practice

```bash
git branch                  # List local branches
git branch <name>           # Create a new branch (doesn't switch to it)
git checkout <name>         # Switch to an existing branch
git checkout -b <name>      # Create and switch in one step
git switch <name>           # Modern alternative to checkout for switching
git switch -c <name>        # Modern alternative: create and switch
git branch -d <name>        # Delete a branch (only if fully merged)
git branch -D <name>        # Force delete a branch (even if not merged)
```

A common workflow:

1. Create a feature branch from main: `git checkout -b feature/new-login`
2. Do your work, committing as you go
3. Push the branch: `git push -u origin feature/new-login`
4. Create a pull request for review
5. After approval, merge into main
6. Delete the feature branch

### Merging

Merging combines two branches:

```bash
git checkout main           # Switch to the branch you want to merge INTO
git merge feature           # Merge the feature branch into main
```

If the branches haven't diverged (main hasn't had new commits since you branched), git does a **fast-forward merge** — it just moves the main pointer forward. No merge commit needed.

If the branches have diverged, git creates a **merge commit** — a special commit with two parents that combines both sets of changes.

### Conflicts

When two branches change the same part of the same file, git can't automatically merge. It marks the conflicts in the file:

```
<<<<<<< HEAD
your version of the code
=======
their version of the code
>>>>>>> feature-branch
```

To resolve: edit the file to keep what you want (removing the markers), then `git add` the resolved file and `git commit`.

### Rebasing

Rebasing is an alternative to merging that replays your commits on top of another branch:

```bash
git checkout feature
git rebase main             # Replay feature's commits on top of main
```

The result is the same code, but the history is linear — no merge commit. This makes the history cleaner and easier to read, but it **rewrites commit hashes** (because the parent pointers change).

**The golden rule of rebasing:** never rebase commits that have been pushed and shared with others. Rewriting shared history causes confusion and merge headaches. Rebase your local, unpushed work freely.

## Part 4: Advanced Concepts

### Interactive rebase: editing history

Interactive rebase lets you rewrite recent commit history — squash commits together, reword messages, reorder, or drop commits entirely:

```bash
git rebase -i HEAD~5        # Interactively edit the last 5 commits
```

Git opens an editor showing your commits with actions:

- `pick` — keep the commit as is
- `squash` — merge this commit into the previous one
- `reword` — keep the commit but change the message
- `drop` — remove the commit
- `edit` — pause here so you can amend the commit

This is powerful for cleaning up a messy series of work-in-progress commits into a clean, logical history before opening a pull request.

### Cherry-picking

Apply a specific commit from one branch to another without merging the whole branch:

```bash
git cherry-pick <commit-hash>
```

Useful when a bug fix on a feature branch needs to go to main immediately, without bringing the entire feature along.

### Tags: marking releases

Tags are permanent labels on specific commits:

```bash
git tag v1.0.0              # Lightweight tag
git tag -a v1.0.0 -m "Release 1.0.0"  # Annotated tag (preferred — includes metadata)
git push origin v1.0.0      # Push a tag to remote
git push origin --tags      # Push all tags
```

Tags don't move like branches do. Once created, they always point to the same commit. Use them for releases, milestones, or any point you might want to return to.

### Bisect: finding when a bug was introduced

Git can do a binary search through your history to find which commit introduced a bug:

```bash
git bisect start
git bisect bad              # Current commit has the bug
git bisect good <commit>    # This older commit doesn't have the bug
# Git checks out a middle commit. Test it, then:
git bisect good             # or git bisect bad
# Repeat until git identifies the exact commit
git bisect reset            # Return to where you started
```

### Reflog: git's safety net

The reflog records every change to HEAD — every commit, checkout, rebase, reset. Even if you "lose" commits with a hard reset, the reflog remembers:

```bash
git reflog                  # Show recent HEAD movements
git checkout <hash>         # Recover a "lost" commit
```

Reflog entries expire after 90 days by default. It's local only — not pushed to remotes.

### Worktrees: multiple working directories

Instead of stashing or committing half-done work to switch branches, you can have multiple working directories for the same repo:

```bash
git worktree add ../hotfix main   # Create a new working directory on main
cd ../hotfix                      # Work on the hotfix without disturbing your feature branch
git worktree remove ../hotfix     # Clean up when done
```

Each worktree has its own working directory and staging area but shares the same `.git` history.

## Part 5: Configuration and Customisation

### Global config

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase true          # Always rebase on pull
```

### Useful aliases

```bash
git config --global alias.st "status --short"
git config --global alias.co checkout
git config --global alias.br "branch -vv"
git config --global alias.lg "log --oneline --graph --all"
```

### .gitignore

A `.gitignore` file tells git which files to ignore:

```
# Dependencies
node_modules/
.venv/

# Build output
dist/
build/

# Environment
.env
.env.local

# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
```

Place `.gitignore` in the repo root. It's tracked by git, so everyone shares the same ignore rules. For personal ignores that shouldn't be in the repo (like your specific editor config), use `~/.gitignore_global`.

## Part 6: Working with Git in Sandboxed Environments

When using git in sandboxed or remote environments (like Claude Desktop Cowork, remote containers, or cloud development environments), the filesystem may behave differently than a local machine.

### FUSE/virtiofs mounts

Some sandboxed environments access the host filesystem through a FUSE (Filesystem in Userspace) or virtiofs mount. This introduces a specific issue: **lock files created by one session cannot be deleted by another session.**

Git creates `.lock` files during operations to prevent concurrent writes. Normally these are cleaned up automatically. On a FUSE mount, if a session ends or a git command fails, the lock file persists — and a new session may not have permission to remove it.

**Symptoms:**
- `fatal: Unable to create '.git/index.lock': File exists`
- `Operation not permitted` when trying to delete `.git/*.lock`

**Solution:**
Clear lock files from the host machine (not from inside the sandbox):

```bash
rm -f /path/to/repo/.git/*.lock
```

If you're frequently hitting this, consider adding a pre-session alias:

```bash
alias git-unlock='rm -f .git/*.lock 2>/dev/null && echo "locks cleared"'
```

### Interactive commands

Some git operations require interactive input (`git rebase -i`, `git add -i`, `git commit` without `-m`). In sandboxed environments without a terminal editor, these won't work. Always use non-interactive alternatives:

- Use `git commit -m "message"` instead of `git commit` (which opens an editor)
- Avoid `git rebase -i` — if you need to squash commits, use `git reset --soft` and recommit
- Avoid `git add -i` — use `git add <specific-files>` instead
