# Ticket skills: source and provenance

`tickets`, `triage` and `to-tickets` are user-level skills from dotfiles (`tools/claude/.claude/skills/`), one ticket workflow for sprint hubs and single repos (repo-lead). Dotfiles is the source; project-manager proposes changes to tool-agent.

| Skill | Invoked | What |
|---|---|---|
| `tickets/` | model (description) | Ticket file format, statuses, lifecycle; `tickets.py` query script (open, frontier, triage, next-id, check) |
| `triage/` | user (`/triage`) | Ticket state machine, verification, briefs (`AGENT-BRIEF.md`), rejected ideas in `tickets/rejected/` (`REJECTED.md`) |
| `to-tickets/` | user (`/to-tickets`) | Plan → tracer-bullet tickets with blocking edges |

## Source

Adapted from `mattpocock/skills@4ae2317ddb22b046e26455e4f9c9b3aaaf62212d` (MIT, `LICENSE.mattpocock-skills`): `skills/engineering/triage/{SKILL,AGENT-BRIEF,OUT-OF-SCOPE}.md`, `skills/engineering/to-tickets/SKILL.md`, `skills/engineering/setup-matt-pocock-skills/{issue-tracker-local,triage-labels}.md`; written per `skills/productivity/writing-for-agents`.

## Changes from upstream

- Tracker: local files in the hub's `tickets/<PREFIX>-NNN-<slug>.md` (not `.scratch/<feature>/issues/NN-*.md`, not GitHub). No index file; open work by query (`tickets.py`). Replaces TASKS.md.
- Jira mirrors: `tickets/JIRA-<jira key>-<slug>.md` (id `JIRA-RDS-1234`), local tickets `RDS-NNN`; no `Jira:` header line.
- Header lines `Status / Category / Owner / Area / Blocked by`; status `done` added (upstream closes issues); `Owner` = who acts next (agent, `thomas`, outside party) replaces labels and claiming; `Area` added (repo folder) to keep TASKS.md's grouping.
- Sections Problem / Brief / Comments; the brief lives in the ticket, not a tracker comment. AI disclaimer dropped (every writer is an agent; Comments carry the author).
- Triage: Thomas = maintainer, lead runs it; verification read-only or via the owning worker; grilling/domain-modeling skills (not installed) replaced by "rounds of ≤3 questions, decisions as Comments"; no PR triage; `.out-of-scope/` → `tickets/rejected/` (reference file `REJECTED.md`); Jira mirror tickets (`JIRA-…`) enter as needs-triage, nothing written back.
- Briefs: Snowflake objects/dbt models/ADF names as durable interfaces; hub rules (DEV only, Thomas pushes/deploys) in the acceptance criteria.
- to-tickets: slices through iac → CORE vault/IF_* → consumer marts → ADF; one ticket per repo per slice; human steps (push, deploy, publish, outside questions) as `ready-for-human` tickets; expand–contract mapped to additive `IF_*` versions.
