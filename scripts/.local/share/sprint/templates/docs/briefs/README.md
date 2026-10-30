# Worker briefs

One file per worker, `<name>.md`: team-lead's first message points the worker to it (whole briefs get refused as prompts). dclaude workers can't read host paths, so theirs is copied into their repo first.

Each brief covers:

- **Who and where**: "You are <name>, a worker in the {{HUB}} hub. team-lead coordinates and relays {{HUMAN}}." The repo folder, and whether it is a worktree.
- **Scope**: what this worker owns, and what it must not touch.
- **Rules**: the branch model and dev branch for this repo; allowed environments; commit only, {{HUMAN}} pushes and deploys (or the exact push exception, if this worker has one); stop when a commit hook fails, never commit past it; in a worktree, no EnterWorktree (use `git worktree add` + `git -C`).
- **Setup check**: the credentials and profiles its first task needs (e.g. a dbt profile's target), so a typo surfaces before the task, not as a blocked retry.
- **Replies**: short, to team-lead; decisions and approval dialogs go to {{HUMAN}}.
- **First task**: the concrete first step, matching its TASKS.md entry.
