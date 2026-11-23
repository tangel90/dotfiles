---
name: triage
description: Move tickets through the triage states - categorise, verify, ask Thomas, write the brief.
disable-model-invocation: true
---

# Triage

Move tickets in the project's `tickets/` folder (hub or single repo) through a small state machine. Load the `tickets` skill first: it holds the file format, the status values and the query script.

Thomas is the maintainer and decides; you recommend, verify and write. The lead (hub lead or repo-lead) runs triage and edits the ticket files; workers verify on request.

## States

Every triaged ticket has exactly one `Category:` (`bug`, `enhancement`) and one `Status:`.

`needs-triage` → `needs-info` | `ready-for-agent` | `ready-for-human` | `wontfix`. `needs-info` returns to `needs-triage` once the answer is in. Thomas can override any transition; flag one that looks unusual (e.g. `wontfix` → `ready-for-agent`, or `ready-for-agent` with open blockers) and ask before applying it.

## Invocation

Thomas types `/triage` and says what to do, for example:

- "What needs my attention?" → [Attention](#attention)
- "Let's look at RDS-7" → [One ticket](#one-ticket)
- "Move RDS-7 to ready-for-agent" → [Override](#override)
- "What can the workers pick up?" → `tickets.py frontier`, plus `tickets.py open --status ready-for-agent` for claimed ones

## Attention

Run `tickets.py triage` and show three buckets, oldest id first, a count and one line per ticket:

1. **Malformed**: no or unknown Status (also run `tickets.py check`).
2. **needs-triage**.
3. **needs-info with an answer**: a Comment or Jira change newer than the last triage note.

Then `tickets.py open --owner thomas`: what waits on Thomas. Let Thomas pick.

## One ticket

1. **Gather.** Read the whole ticket, its Comments and its blockers' tickets. Resume from earlier triage notes: questions already answered stay answered. Run two checks and say where you looked:
   - **Redundancy**: is the behaviour already built? Search by domain concept (model, object, pipeline, grant), not only by the ticket's wording: closed tickets (`grep -l` over `tickets/`), the repos read-only, and the owning worker when the answer lies in its repo. Built already → `wontfix`, already implemented (step 5).
   - **Prior rejection**: read `tickets/rejected/*.md` (see [REJECTED.md](REJECTED.md)) and surface any concept that matches.
2. **Recommend.** Category, state and why, plus what the code or repos show today. Wait for Thomas.
3. **Verify.** Check the claim holds before asking anything. Bug: reproduce it read-only (a query on DEV, a `dbt` compile, a log), or ask the owning worker to, with the ticket id in brackets. Report: confirmed (with the object or code path), not reproduced, or not enough detail (a strong `needs-info` signal). A confirmed bug makes a much stronger brief.
4. **Ask.** When the ticket is vague, ask Thomas a round of at most three questions at a time, recommending an answer for each, until scope, behaviour and acceptance are clear. Record each decision as a Comment as it lands.
5. **Apply** and run `tickets.py check`:
   - `ready-for-agent`: write `## Brief` per [AGENT-BRIEF.md](AGENT-BRIEF.md); set Area where the project uses it; Owner stays `-` unless Thomas names a worker.
   - `ready-for-human`: the same Brief, plus one line on why it can't be delegated; Owner `thomas`.
   - `needs-info`: Owner = who must answer; append triage notes (template below).
   - `wontfix`, by reason, with a Comment:
     - **Already implemented**: point to where it lives (repo, object, commit).
     - **Rejected bug**: a short reason.
     - **Rejected enhancement**: write or extend `tickets/rejected/<concept>.md` ([REJECTED.md](REJECTED.md)) and link it.
   - Staying `needs-triage`: a Comment only if there is partial progress.

## Override

Thomas says "move RDS-7 to X": apply it directly, without verifying or asking. Say what will change (Status, Owner, Comment), then do it. Moving to `ready-for-agent` with no Brief yet: ask whether to write one now.

## Needs-info notes

Append to Comments:

```markdown
- 2026-11-03 rds-lead: triage notes.
  Established: <point>; <point>.
  Needed from <who>: <specific question>; <specific question>.
```

Everything decided while asking goes under Established, so it survives. Each question names the decision it unblocks.

## Jira

Tickets mirrored from Jira arrive as `needs-triage` with a `JIRA-<key>` id (`JIRA-RDS-1234`). Triage them like any other; Jira itself stays untouched.
