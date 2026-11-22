# Rejected

`tickets/rejected/` keeps rejected enhancements, one file per **concept** (not per ticket), so the reason survives and the same request isn't argued twice.

## When to read

Step 1 of triage: read every file there. Match by concept, not keyword ("BPM reads the raw vault directly" matches `bpm-reads-core-vault.md`). On a match, tell Thomas: "Like `tickets/rejected/<file>`, rejected because <reason>. Still so?" Then:

- **Still so**: add the ticket to the file's Prior requests, close the ticket `wontfix` with a Comment linking the file.
- **Changed mind**: delete or rewrite the file; the ticket goes through normal triage. Old tickets stay closed.
- **Different thing**: normal triage.

## When to write

Only for an **enhancement** Thomas rejects. A bug closed as wontfix gets a Comment only; a feature that already exists gets a Comment pointing to it (writing it here would make later checks report a false rejection).

1. Find a matching file; else create `tickets/rejected/<concept-kebab-case>.md`.
2. Write or extend it (format below).
3. Comment on the ticket with the link; `Status: wontfix`.

## Format

A short design note, readable cold:

```markdown
# BPM reads the CORE vault directly

The BPM project reads CORE only through `BV.IF_BPM`.

## Why

<The durable reason: architecture, ownership, contract, a decision and its date. "No time now" is a deferral: leave the ticket open, blocked, instead.>

## Prior requests

- RDS-14 (2026-11-05): "join sat_deal_pos in dbt-bpm"
```
