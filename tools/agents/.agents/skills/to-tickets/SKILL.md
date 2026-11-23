---
name: to-tickets
description: Break a plan, spec or the conversation into tracer-bullet tickets with blocking edges, one file per ticket in the project's tickets/ folder.
disable-model-invocation: true
---

# To tickets

Break a plan, spec or conversation into **tickets**: tracer-bullet vertical slices, each naming the tickets that **block** it. Load the `tickets` skill first: it holds the file format and the query script.

## 1. Gather

Work from the conversation. If Thomas passes a reference (a spec in `docs/`, a ticket id, a Jira key mirrored in a ticket), read all of it, Comments included.

## 2. Explore

Read the affected code or repos read-only, or ask their workers, until you know today's state: which modules, objects, interfaces and pipelines the change touches, and which earlier tickets (open and closed) already cover parts of it. Use the names the repos use. Look for a **prefactor** that makes the change easy, and put it first.

## 3. Slice

<vertical-slice-rules>

- A slice cuts a narrow but complete path through every layer it needs (schema, logic, interface, consumer, UI or report, tests; in RDS: iac grants, the CORE vault and `IF_*` interface, the consumer marts, ADF, report), not one layer for many features.
- A finished slice is verifiable on its own (on DEV, or by its tests).
- A slice fits one fresh worker's context window and, in a single repo, one pull request. In a hub, a slice spanning repos becomes one ticket per repo, chained by blocking edges, with the last one checking the whole path.
- Prefactoring comes first.

</vertical-slice-rules>

Give each ticket its **blocking edges**: the tickets that must be `done` before it starts. No blockers: it can start now.

**Human steps are tickets too.** Push, deploy, merging a pull request, Studio "Publish all", secrets, a question to the API team or the front desk: each is a `ready-for-human` ticket (Owner `thomas`) that blocks the slices needing it. That keeps agent tickets from stalling half-done.

**Wide refactors are the exception.** One mechanical change whose blast radius fans out over many consumers (rename a column in a shared interface, retype a key) can't land green as a slice. Sequence it **expand–contract**: expand (add the new form beside the old: v1 stays, the new column is additive); migrate consumers in batches, one ticket per batch (per project, per pipeline group), each blocked by the expand; contract (drop the old form) in a ticket blocked by every batch. If batches can't stay green alone, they share a branch and all block a final integrate-and-verify ticket.

## 4. Quiz Thomas

Show the breakdown as a numbered list. Per ticket:

- **Title**, **Area**, agent or human
- **Blocked by**: which tickets in the list (or existing ids)
- **Delivers**: the end-to-end behaviour it makes work

Ask: granularity right (too coarse, too fine)? Each edge real, so a ticket waits only on what gates it? Anything to merge or split? Iterate until Thomas approves.

## 5. Write the tickets

In dependency order, blockers first, so each edge names a real id:

1. `tickets.py next-id`, then write `tickets/<ID>-<slug>.md` per the `tickets` skill: one ticket per file, never a combined file.
2. `Status: ready-for-agent` (or `ready-for-human` for the human steps), `Owner: -` unless Thomas assigned one, `Blocked by:` the ids, `## Problem` (what this slice delivers and why, plus a pointer to the source spec or parent ticket), `## Brief` per the triage skill's AGENT-BRIEF.md, `## Comments` with a created line.
3. A parent ticket the plan came from stays as it is apart from one Comment listing the new ids.
4. `tickets.py check`, then `tickets.py frontier`: report the ids that can start now.

Names over paths in Problem and Brief: object, model and pipeline names stay true while paths move. A snippet earns a place only when it pins a decision more precisely than prose (a contract's column list, a state machine): trim it to that decision.
