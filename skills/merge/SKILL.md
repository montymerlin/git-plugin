---
name: merge
description: >
  Use when asked to merge branches, integrate divergent Git histories, complete
  a merge after conflicts, pull collaborators' commits when a merge may be
  required, or review a proposed merge commit.
---

# Guided Git Merge Workflow

Integrate histories deliberately. A merge commit should explain the outcome to a collaborator; Git already records the branch mechanics.

## Non-negotiable boundaries

- Read the target repo's `AGENTS.md`, `CLAUDE.md`, then `README.md`; local rules override these defaults.
- Never auto-stash, rebase, discard work, delete a branch, rewrite history, push, or force-push.
- Keep a possible fast-forward as a fast-forward. Do not force a merge commit merely to attach prose.
- Never finish a merge commit with a transport-only subject such as `Merge branch 'main'` or `Merge remote-tracking branch 'origin/main'`.
- Inspect the commits and diff before describing them. If the outcome is unclear, stop and ask rather than inventing an explanation.
- Show the integration plan and, when applicable, the complete merge message before mutation. Wait for confirmation.

## 1. Detect the host and merge state

Use the same host detection as `git:commit`. In a local terminal, remove a lock only after confirming no Git process is active and the lock is stale; the existence of a lock alone is not proof. Removing a verified stale lock is safety maintenance, not approval to mutate repository history. In a Cowork-style sandbox, perform read-only analysis only and use the handoff below.

Check whether a merge is already in progress:

```bash
git rev-parse -q --verify MERGE_HEAD
git status --short --branch
git diff --name-only --diff-filter=U
```

If `MERGE_HEAD` exists, continue at **Completing an existing merge**. Do not start another merge or route the work through an ordinary commit.

If Git's merge-head file contains more than one commit, stop. This workflow deliberately handles one incoming parent at a time; an octopus merge needs a separate, explicitly reviewed plan and message structure.

## 2. Preflight a new integration

Resolve the exact target and source refs; never assume `main`, `master`, or a remote. Do not switch branches before the approval gate: inspect a non-current target through its explicit ref. Fetch only when the user's request includes retrieving remote work. Prefer fetch plus inspection over an opaque `git pull`.

Require a clean working tree and index. If unrelated work is present, stop and let the user choose how to handle it; do not stash it automatically.

Inspect the relationship and substance:

```bash
git branch --show-current
git rev-parse --verify <target>
git rev-parse --verify <source>
git merge-base --is-ancestor <source> <target>
git merge-base --is-ancestor <target> <source>
git log --format='%h %s%n%b' <target>..<source>
git log --format='%h %s%n%b' <source>..<target>
git diff --stat <target>...<source>
git diff --stat <source>...<target>
```

For divergent histories, inspect both sides: the explanation must represent the incoming work and the local work it joins. When the installed Git supports it, preview likely conflicts with `git merge-tree`; otherwise state that conflict risk has not been precomputed.

Record the exact pre-integration target and source commit IDs. After confirmation, switch to the target if necessary, recheck the clean state and ancestry, and stop if either ref has moved since review.

Classify the result:

| Relationship | Strategy |
|---|---|
| Source already ancestor of target | Report already integrated; do nothing |
| Target ancestor of source | Fast-forward with `--ff-only`; no merge message |
| Histories diverged | Deliberate merge commit using `--no-ff --no-commit` |
| User explicitly requires a merge commit on a fast-forwardable branch | Confirm the exception, then use `--no-ff --no-commit` |

Present the target, source, relationship, outcomes on both sides, strategy, specifically named checks, and explicit boundaries: **no push and no branch deletion**. For a merge commit, include the exact message. Wait for confirmation.

## 3. Write the message for people

Follow target-repo style. Otherwise use:

```text
merge: <accessible outcome>

<What capability, content, or fix lands, and why these histories are being
integrated. Name the meaningful result rather than merely the branch names.>

<Optional: meaningful conflict choices and their rationale.>
```

The subject is imperative, outcome-led, and under 72 characters. The first body paragraph is required for a merge commit. Branch/ref names may provide context in the body, but are not the explanation.

Good:

```text
merge: integrate participant matching with Sync history

Bring in the collaborator identity fixes used by Meetings and Sync while
preserving the person-day activity design developed locally.

Resolve the shared alias lookup in favour of declared profile aliases, with
initials retained only when no collaborator can be matched safely.
```

Bad: `Merge branch 'feature/identity'`, `merge: update main`, or a body that only says the branches diverged.

## 4. Execute locally

For a fast-forward, run the confirmed `git merge --ff-only <source>`.

For a merge commit:

1. Confirm `HEAD` is the reviewed target commit, then run `git merge --no-ff --no-commit <source>`.
2. If conflicts appear, stop at **Conflict handling**.
3. Inspect the staged result and run the relevant repository checks before committing.
4. If the observed result changes the explanation, revise the message and show it again.
5. Commit with the complete approved subject and body; do not invoke an editor that can silently restore Git's default message.

### Conflict handling

List every unresolved path and explain the competing changes. Resolve only choices supported by repo context or the user. Never choose ours/theirs wholesale merely to finish quickly.

After resolution:

```bash
git diff --name-only --diff-filter=U
git diff --cached --stat
git diff --cached
```

The unresolved-path command must return nothing. Add meaningful resolution decisions to the message after the outcome overview. Show the revised message and obtain confirmation before creating the merge commit.

For a path that was conflicted, compare the resolved index with both parents (`git diff --cached HEAD -- <path>` and `git diff --cached MERGE_HEAD -- <path>`). This does not replace understanding the source files, but it makes one-sided or combined resolutions visible.

### Completing an existing merge

Use `HEAD` as the first parent and `MERGE_HEAD` as the incoming parent. A commit ID is an acceptable source identifier when the original symbolic ref cannot be recovered; label it honestly rather than guessing a branch name. Inspect both parent ranges, the staged diff, unresolved paths, and any repo-provided merge message. Check that the staged index contains only the merge result; if unrelated staged changes cannot be separated confidently, stop and ask. Reconstruct the outcome from evidence, not from `.git/MERGE_MSG` alone. Then follow the conflict checks, message contract, confirmation, and commit steps above.

Abort only when the user explicitly asks to abandon the merge; an abort can overwrite the in-progress integration state.

## 5. Cowork handoff

Do not run fetch, merge, add, commit, abort, or push in a constrained Cowork mount. After read-only analysis and user confirmation, emit one self-contained handoff prompt for a fresh local agent. It must contain:

- repo and host path, target and source refs, their observed commit IDs, and whether a merge is already in progress;
- observed relationship, incoming outcomes, relevant diff summary, and known conflicts;
- the complete approved merge message, or an explicit fast-forward strategy;
- instructions to re-read repo conventions, fetch when remote work is involved, and recompute ancestry and counts rather than trusting potentially stale sandbox refs;
- a hard stop when either target or source has moved: re-inspect both commit ranges and diffs, revise the strategy/message as needed, and obtain renewed user approval before merging;
- instructions to stop for semantic conflicts, run the specifically named checks, verify ancestry/parents, and report the resulting commit;
- explicit prohibitions on pushing, deleting branches, stashing, rebasing, or rewriting history unless separately authorised.

Carry intent and safety boundaries, not a brittle list of shell commands.

## 6. Verify

After the integration, run fresh checks:

```bash
git status --short --branch
git merge-base --is-ancestor <source> HEAD
git log -1 --format=fuller
git rev-list --parents -n 1 HEAD
```

Confirm the source is reachable, the expected fast-forward or parent shape occurred, relevant tests passed, and no unrelated work changed. Do not push or delete the source branch unless the user asks separately.

For a merge commit, confirm the recorded target commit is the first parent and the recorded source commit is the second parent. For a fast-forward, confirm `HEAD` equals the recorded source commit.

## Common mistakes

| Mistake | Correct response |
|---|---|
| Accepting Git's generated message | Draft the outcome-led subject and required body before mutation |
| Forcing `--no-ff` on every merge | Preserve fast-forwards unless the user explicitly requires a merge commit |
| Describing commits from branch names | Read the incoming log and diff; ask if intent remains unclear |
| Treating resolved conflicts as an ordinary commit | Route through this workflow and document meaningful choices |
| Assuming merge permission includes push or cleanup | Keep publication and branch deletion separately authorised |
