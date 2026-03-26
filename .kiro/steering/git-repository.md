---
inclusion: always
---

# Git Repository — RE-SAP IFRS 16 Addon

## Remote Repository

- URL: https://github.com/Tucomullen/RE_SAP.git
- Remote name: origin
- Default branch: use `git rev-parse --abbrev-ref HEAD` to determine current branch before pushing

## Auto-Commit Hook

The `auto-commit-push` hook fires on every `postTaskExecution` event — when a spec task is marked complete by the Orchestrator (step A7 of each pipeline). It:
1. Stages all changes (`git add -A`)
2. Commits only if there are staged changes (skips empty commits)
3. Pushes to the current branch on `origin`

Commit message format: `chore(auto): agent session commit <ISO timestamp>`

This means a commit+push happens at the end of each Orchestrator iteration, not at session close.

## Manual Push

If you need to push manually at any point:
```bash
git add -A && git commit -m "your message" && git push origin HEAD
```
