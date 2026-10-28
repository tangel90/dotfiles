# Worker briefs

One file per worker, `<name>.md`: the first message team-lead sends it. dclaude workers can't read host paths, so team-lead pastes the brief inline.

Each brief covers:

- **Who and where**: "You are <name>, a worker in the {{HUB}} hub. team-lead coordinates and relays {{HUMAN}}." The repo folder, and whether it is a worktree.
- **Scope**: what this worker owns, and what it must not touch.
- **Rules**: the branch model for this repo; allowed environments; commit only, {{HUMAN}} pushes and deploys; in a worktree, no EnterWorktree (use `git worktree add` + `git -C`).
- **Replies**: short, to team-lead; decisions and approval dialogs go to {{HUMAN}}.
- **First task**: the concrete first step, matching its TASKS.md entry.
