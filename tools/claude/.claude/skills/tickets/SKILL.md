---
name: tickets
description: Ticket files in a project's tickets/ folder (tickets/<P>-NNN-*.md, Jira mirrors JIRA-*.md) - format, statuses, ownership, and the query script for open work. Use when reading, writing, claiming, commenting on or closing a ticket, or finding work - the frontier, what an agent owns, what waits on the human.
---

# Tickets

Each piece of work is one ticket file in the project's `tickets/` folder: a hub folder, or the main checkout of a single repo (there, `tickets/` is a local tracker, listed in `.git/info/exclude`). The folder is the tracker: there is no index file, and open work is found by **query**, never by a list kept by hand.

## Query

`tickets.py` in this skill's folder (stdlib, run with `python3 -I`; finds `tickets/` by walking up from the current folder, so it also works from a worktree under the main checkout, or `--dir <project>`):

| Want | Command |
|---|---|
| all open work | `tickets.py open` |
| one owner's open work | `tickets.py open --owner core-worker` (the human: `--owner thomas`) |
| the **frontier**: ready-for-agent, unclaimed, every blocker done | `tickets.py frontier` |
| triage queue | `tickets.py triage` |
| one ticket | `tickets.py show RDS-7` |
| id for a new ticket | `tickets.py next-id` (first ticket of a project: `--prefix RDS`) |
| format problems | `tickets.py check` (run after every write) |

## File

Path: `tickets/<P>-<NNN>-<slug>.md`, e.g. `tickets/RDS-007-serialid-in-sat-deal-pos.md`. The prefix is short and fixed per project (a hub's `.sprint` `prefix=`, or noted in a repo's `CLAUDE.md`). Ids are three digits in the file, written short elsewhere (`RDS-7`). Never renumber or reuse an id.

A ticket mirrored from Jira takes `JIRA-` plus the Jira key as its id: `tickets/JIRA-RDS-1234-<slug>.md`, id `JIRA-RDS-1234`. Jira is one way, into the project: the mirror appends what changed in Jira as Comments, and every write on the Jira side stays with the human.

`tickets/rejected/` holds one note per rejected idea, linking the `wontfix` tickets that asked for it (triage skill, REJECTED.md). The tickets themselves stay in `tickets/`.

```markdown
# RDS-007: SerialId reaches IF_BPM

Status: in-progress
Category: enhancement
Owner: core-worker
Area: dbt-core
Blocked by: RDS-003, TST exists
Branch: agent/serialid
PR: -
Intent: docs/intent/serialid.md

## Problem

What is wrong or missing, in the domain's words, and why it matters. Context: commits, earlier decisions, what has been tried.

## Brief

The contract the worker works from (see the triage skill's AGENT-BRIEF.md): category, summary, current and desired behaviour, key interfaces, the files or objects that matter, acceptance criteria as `- [ ]` lines, out of scope.

## Comments

- 2026-11-03 rds-lead: created from TASKS.md.
```

Header lines before the first `##`, in this order. `Status` and `Owner` are always there; the others when they apply.

- **Status**, exactly one of:
  - `needs-triage`: new, not evaluated or not yet agreed with the human.
  - `needs-info`: waiting on an answer; Owner is who must answer (the human, or an outside party such as `front desk`).
  - `ready-for-agent`: has a Brief; a worker can take it.
  - `ready-for-human`: has a Brief that says why the human must do it (push, deploy, decision, credentials, a UI only they can reach).
  - `in-progress`: a worker is on it (Owner says who).
  - `review`: the change is done and under review (reviewer agent, pull request).
  - `done`, `wontfix`: closed.
- **Owner**: who acts next: an agent name, the human, or an outside party; `-` while unclaimed.
- **Category**: `bug` or `enhancement`.
- **Area**: the repo folder or part of the project (`dbt-core`, `ops`, `docs`); useful in hubs with several repos.
- **Blocked by**: ticket ids (local or `JIRA-…`), or a short condition outside the tracker (`TST exists`); `-` or absent when free. A blocker counts as cleared only when its ticket is `done`; edit conditions out once they hold.
- **Branch**, **PR**, **Intent**: the work branch, the pull request URL once opened, and the spec it follows (e.g. `docs/intent/<topic>.md`).

## Lifecycle

- **Create**: `next-id`, write the file, `check`. New requests start at `needs-triage` (the triage skill moves them on); tickets from an approved breakdown (to-tickets skill) start at `ready-for-agent` or `ready-for-human`.
- **Claim**: set `Owner:` to the worker and `Status: in-progress`, and save, before any work starts.
- **Comment**: append to `## Comments` as `- YYYY-MM-DD <who>: <text>`, newest last. Earlier comments stay as written; a correction is a new comment.
- **Progress**: tick acceptance criteria in the Brief as they are met and verified; `Status: review` when it's handed to review, with Branch and PR filled in.
- **Close**: `Status: done` plus a comment naming the commits (`dbt-core 285b8ca`) or the merged PR, and what was deployed where. A closed ticket stays in the folder: the folder is the history.
- **Split or merge**: new tickets for the parts, a comment on the old one pointing to them, old one `wontfix`.

## Writers

One writer per ticket at a time: the lead, or the worker named in `Owner:`. A worker that owns a ticket edits its Status, Brief ticks and Comments; everything else goes back to the lead. Every message or request about a ticket starts with its id in brackets (`[RDS-7] ...`), so usage and transcripts can be traced back to it.

A worker reports through its ticket: the result goes into a dated Comment (findings, commits, paths of files it wrote), and the reply to the lead is one line, `[RDS-7] <worker>: done | blocked | question, see Comments`. The ticket outlives the worker's session; the reply only wakes the lead. A worker in a worktree writes to the ticket in the main checkout, by the absolute path the lead gave it.
