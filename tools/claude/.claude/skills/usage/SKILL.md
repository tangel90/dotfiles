---
name: usage
description: Show where a project's Claude usage went (per session folder, worker and model, from the transcripts) and what drove it, with concrete fixes. Use when the human asks about usage, tokens, cost or limits, when "tokens burned fast", or during a reflect.
---

# Usage

Find out what used the tokens in this project and what would have cost less. Read-only.

## Measure

Run, from the project root (worktrees and sandboxes below it are included):

```
~/.claude/skills/usage/scripts/usage.py
```

`--days 1` limits it to recent transcripts, a path selects another project, `--all` covers every project on this machine. Per folder it shows sessions, model calls, output, cache writes (`cwr`) and reads (`crd`), the average context per call, and the share of the cost, weighted by the models' relative prices. For dollar amounts, `npx -y ccusage@latest session` (or `daily`, `blocks`).

## Explain

Map the numbers to causes:

- **High context per call** (above about 60k) in a long-running agent: a conversation that is re-read every turn. Fix: keep state in tickets and intent files, and `/clear` after each closed ticket.
- **Many sessions with few calls and high cache writes**: short sessions started over and over (headless `claude -p`, sandboxes, agents testing an agent). Each start pays for the full system prompt again. Fix: fixtures or recorded responses instead of live runs, or one session reused.
- **Reviewer folders costing more than implementer folders**: live runs to prove findings, or Opus on routine review. Fix: limit live model runs in the repo's `REVIEW.md`, consider Sonnet for routine reviews.
- **Large output in a worker**: long reports in chat that the lead then reads. Fix: reports as ticket Comments, one-line replies.
- **A large Opus share** for well-scoped work: move that role to Sonnet.

Check one or two causes in the transcripts themselves before naming them (the biggest turns, the tool results that filled the context) rather than inferring from the table alone.

## Report

The table's top rows, the model split, the two or three biggest causes with their evidence, and a fix for each, most savings first. Fixes that need a change in `~/.claude/` go to the human as proposed edits, like the reflect skill's.
