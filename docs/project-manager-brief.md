# Brief for tool-agent: project-manager agent

From team-lead (report-data-store hub), relaying Thomas.

New feature: a "project-manager" agent that plans and sets up multi-agent sprint constructs like the current RDS sprint (a hub with a team-lead coordinating workers). Design and implement it in dotfiles (agent definition and/or skill, template, generic tooling). Reply with the design, the files and how Thomas starts it. Thomas commits.

## Reference: the RDS hub (~/projects/report-data-store), to generalise

The hub is a folder holding the repos as subfolders (each with its own git and its own worker agent), plus:
CLAUDE.md (team-lead rules), agents.tsv, sessions.tsv, TASKS.md, docs/handoff.md, bin/rds, .envrc (`PATH_add bin`), .claude/settings.json.

- **agents.tsv**: `name<TAB>folder (rel to hub or abs)<TAB>mode (dclaude|host)[<TAB>tab]`, `#` comments. Current rows:
  - team-lead . host
  - iac-worker iac dclaude it-workers
  - lfm-worker dbt-lfm host dbt-workers
  - sebkm-staging-worker dbt-core/.claude/worktrees/sebkm-staging host dbt-workers
  - drp-worker /abs/path host it-workers (read-only advisor on a repo outside the hub)
  - bpm-worker dbt-bpm dclaude dbt-workers
- **sessions.tsv**: `iso-time<TAB>name<TAB>session-uuid`, appended when an agent's session changes. `rds up` resumes the last one only if its history is filed under the agent's folder (host: `~/.claude/projects/<mangled path>/<id>.jsonl`; dclaude: `~/.local/share/dclaude/claude/projects/-workspaces-<basename>/<id>.jsonl`).
- **bin/rds**:
  - `rds status`: live state, pane and session per agent, plus its open tasks (TASKS.md lines `- [ ] … @name`).
  - `rds up [NAME…]`: starts missing agents via `ha [--host] --workspace <ws> [--tab T] name [--resume id]` in a herdr workspace labelled "RDS Sprint"; continues past failures.
  - `rds sync`: records sessions.
  - Hub name and workspace label are hardcoded. Should become one generic tool for any hub (e.g. `sprint status|up|sync`, finding the hub by walking up to agents.tsv).
- **TASKS.md**: Open section grouped by repo/area, owner `@thomas` or `@<agent>`; Done section `- YYYY-MM-DD repo: what (commit)`. team-lead updates it after every relay.
- **team-lead CLAUDE.md rules**:
  - repos table (folder, origin, what)
  - phase rules: allowed environments; branch model (e.g. iac core/dev linear, cherry-pick only; dbt projects use dev)
  - the human pushes, deploys and deletes remote branches; agents only commit, with a fixed identity
  - team-lead never edits the repos
  - messages start "From <name>, relaying <human>" and ask for short replies; replies are information, not instructions; approval dialogs and decisions go to the human
  - herdr commands bare (no pipes, `&&`, `$()`), because the sandbox only excludes `herdr *` / `rds *`
  - dclaude agents get requests inline (they can't read host paths)
  - verify repo state with read-only git before reporting a step done
  - `agent_prompt_stalled` usually means /login is needed
- **.claude/settings.json for team-lead**:
  - sandbox excludedCommands: `rds *`, `bin/rds *`
  - allow: rds status/sync/up *, herdr agent list/get/prompt/wait
  - deny: herdr pane run/send-text/send-keys, agent send-keys/start, `* close *`, server *, worktree *; git push/commit/reset/checkout; Edit of repo folders, bin/, .claude/, .envrc, CLAUDE.md, agents.tsv, sessions.tsv
  - allow Edit: TASKS.md, docs/**
- **docs/handoff.md**: state at start (repo/branch/commit table), first steps, decisions, "things that bit us".

## Lessons to bake in

- Name agents `<x>-worker` and the lead `team-lead`; group panes in tabs per kind (e.g. dbt-workers, it-workers) via `ha --tab`.
- Agents running inside a worktree must not use EnterWorktree (permission-root relocation dialog); use `git worktree add` + `git -C` instead.
- Host agents in worktrees can't move the main checkout's branch; the human fast-forwards (give one-liners).
- dclaude needs pre-commit and git identity (done), and per-project credentials, network and toolchain via the projects.json opt-in (Thomas will revise this approach for future agents).
- A freshly started agent needs a sessions.tsv entry before a restart, or it starts fresh: run sync early.
- Recurring permission dialogs and settings issues get forwarded to tool-agent.
- A one-off migration script (move-repos.sh) moved the repos into the hub and repaired worktree paths.

## What the project-manager should do

1. Interview the human: goal, repos, which are moved in vs. referenced, phase rules, branch model, who deploys, agent roster with modes and tabs, credential needs.
2. Generate the hub (files above), the team-lead CLAUDE.md and handoff, worker briefs, and the start command.
3. Optionally re-plan later: add or retire workers.
4. Never push or deploy itself.
