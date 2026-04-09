# Git Explained (Non-Technical Guide)

This guide is for people collaborating through GitHub and AI tools (Cursor, Claude, etc.), not for people learning terminal commands.

The goal is to understand the **core features, actions, and decisions** so you can work confidently.

---

## The core idea

Git is a time machine for project files.

It helps you:

- save meaningful checkpoints
- collaborate without overwriting each other
- review changes before they become official
- recover from mistakes

If you understand just four terms, you can handle most workflows:

1. **Commit**
2. **Branch**
3. **Pull Request (PR)**
4. **Merge**

---

## 1) Commit: save a checkpoint

A **commit** is a saved snapshot of changes plus a short note explaining why.

Think: "I reached a stable step. Save this point."

Good commit messages explain intent:

- "Add Section 5 draft on commitment pooling"
- "Fix broken links in research index"
- "Update setup guide for cowork MCP config"

Commits are your safety net and your memory.

---

## 2) Branch: a safe workspace

A **branch** is a separate workspace for a change.

You use branches when work might be risky, structural, or needs review.  
You can experiment without affecting the main shared version.

In small repos, you may skip branches for routine low-risk edits.

---

## 3) Pull Request (PR): review before merge

A **PR** is a request to merge one branch into another (usually into `main`).

A PR is not just code movement; it is collaboration:

- review and discussion
- checks and context
- alignment before shared state changes

Simple mental model:

- **Commit** = save your work
- **PR** = ask, "Should this become official?"

---

## 4) Merge: make it official

When a PR is approved (or when you choose to integrate), the branch is **merged**.

After merge, the change becomes part of the shared project history.

---

## The practical flow (no terminal required)

Most AI/GUI tools follow this same shape:

1. Make changes
2. Review diff
3. Commit with clear message
4. (Optional) push to branch
5. (Optional) open PR
6. Merge when ready

You can do all of this through GitHub + AI assistants without touching shell commands.

---

## When to commit directly to main vs use PR

For small collaborative research repos, use this rule:

## Commit directly to `main` for:

- daily research notes
- report drafting edits
- wording, formatting, and low-risk content updates

## Use branch + PR for:

- folder or structure changes
- setup/config/tooling changes
- automation/script changes
- anything that could confuse or block collaborators

In short: **speed for content, safety for infrastructure**.

---

## What "push" and "pull" mean (plain language)

- **Push**: upload your local commits to GitHub
- **Pull/Sync**: download others' latest commits to your local copy

A direct commit to `main` affects others when they sync/pull.

---

## Common beginner concerns

## "Can I break everything?"

Less than you think. Git keeps history. Most mistakes can be corrected with a follow-up commit.

## "Do I need PRs for everything?"

No. In small teams, PRs are optional for routine content work and recommended for risky changes.

## "What if two people edit similar files?"

Git will ask for conflict resolution. This is normal. Resolve thoughtfully and continue.

---

## Collaboration etiquette that saves time

- Keep commits small and focused
- Write clear commit messages
- Don’t bundle unrelated changes in one commit
- Before risky changes, agree on approach in a PR
- Sync frequently so drift stays small

---

## AI-first workflow tips

If you work via AI tools:

- ask AI to show a change summary before commit
- ask AI to separate unrelated changes into multiple commits
- ask AI whether a change is "direct-to-main" or "branch+PR" risk level
- ask AI to draft PR descriptions in plain language

This gives you speed without losing control.

---

## Quick glossary

- **Repository (repo):** the project and its history
- **Commit:** saved checkpoint
- **Branch:** separate workspace
- **PR:** proposal to merge branch into main
- **Merge:** integrate approved change
- **Push:** upload commits to GitHub
- **Pull/Sync:** download latest shared commits

---

## Bottom line

You do not need to be "technical" to use git well.

If you remember one line, make it this:

**Commit often, use PRs when risk is higher, and keep changes easy for collaborators to understand.**
