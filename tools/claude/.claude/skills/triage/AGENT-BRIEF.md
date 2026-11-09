# Writing briefs

The `## Brief` section of a ticket is the contract a worker builds from, often a fresh worker that has seen nothing but the ticket. Problem and Comments are context; the Brief decides. A `ready-for-human` ticket gets the same Brief, addressed to Thomas.

## Principles

**Durable.** The ticket may wait days while the repos move. Name what outlives a refactor: Snowflake objects (`BV.IF_BPM`, `DM.LFM.FACT_NOMINATION_GAS`), dbt model names, columns, ADF pipelines and global parameters, roles and grants, CLI commands. Leave file paths and line numbers to the worker's own search. Commits are context ("built on 285b8ca"), not instructions.

**Behavioural.** State what the system does when done; the worker explores the repo fresh and picks the implementation.
- Good: "`IF_BPM` exposes `SERIAL_ID` for every deal leg; v1 columns unchanged."
- Weak: "Add serial_id to the select in sat_deal_pos.sql."

**Checkable acceptance.** Every criterion is a `- [ ]` line someone can verify alone, best with the command or query that shows it.
- Good: "`dbt build -s bv_deal_attributes+ --target dev` passes; `select count(*) from DEV_BV.IF_BPM.DEALS where serial_id is null` returns 0."
- Weak: "SerialId works."

**Bounded.** Say what stays untouched, so the worker doesn't gold-plate or wander into a neighbour's repo.

**Project rules apply.** Name the environment the project's CLAUDE.md allows (in RDS: DEV only). Pushing and deploying stay with Thomas unless that CLAUDE.md names an exception: end the criteria at "committed on `<branch>`, deploy command handed to Thomas", or split the deploy into its own `ready-for-human` ticket blocked by this one.

## Template

```markdown
## Brief

**Category:** bug | enhancement
**Summary:** one line: what must happen.

**Current behaviour:** what happens now (for a bug, the broken behaviour with the evidence from verification).

**Desired behaviour:** what happens after the work, including edge cases and failure handling.

**Key interfaces:**
- `<object / model / pipeline / parameter>`: what changes and why.

**Acceptance criteria:**
- [ ] criterion, with how to check it
- [ ] ...

**Out of scope:**
- adjacent change that belongs to another ticket or repo

**Human only:** (ready-for-human) why an agent can't do this.
```

## Example (bug)

```markdown
## Brief

**Category:** bug
**Summary:** POS vault rows loaded before 2026-10-22 carry LOAD_DATETIME 7 h late.

**Current behaviour:** Loads before f0af6f2 wrote LOAD_DATETIME with a -07 offset (account TIMEZONE was America/Los_Angeles). New SerialId rows in `sat_deal_pos` now sort before them, so the latest-row logic picks old rows.

**Desired behaviour:** Every POS raw-vault row on DEV has its LOAD_DATETIME in UTC; the sat's latest row per hash key is the newest load.

**Key interfaces:**
- POS hubs, links and sats in the raw vault: LOAD_DATETIME only, hash keys and hashdiffs unchanged.

**Acceptance criteria:**
- [ ] A query listing POS rows with LOAD_DATETIME before 2026-10-22 and offset -07 returns 0 rows on DEV.
- [ ] The repair is a reviewed SQL script handed to Thomas, with row counts per table before and after.
- [ ] `dbt test -s sat_deal_pos` passes on DEV after Thomas runs it.

**Out of scope:**
- TST (no TST yet); the 33,925 SerialId rows (RDS-n).
```

A brief that says "fix the timestamp thing in the POS sat, see line 40" fails every principle: no category, no evidence, a path that will move, nothing to check, no boundary.
