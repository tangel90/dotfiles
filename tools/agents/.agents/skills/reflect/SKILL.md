---
name: reflect
description: Mine a finished piece of work for durable lessons (repeated mistakes, wasted rounds, misread prompts, repeated corrections) and turn each into a concrete proposed edit, enforcement first. Use when the human says "reflect", or after a merged pull request or closed ticket when something went worse than planned.
---

<!-- Inspired by reflect from pstack (poteto); written for this setup. -->

# Reflect

Turn what went wrong into changes that keep it from happening again. One-offs are not lessons; if everything went as planned, say so and stop.

## Gather

- This conversation, and the transcripts of the agents involved: `~/.claude/projects/<slug>/<session>.jsonl`, where `<slug>` is the agent's working directory with every character that isn't a letter or digit turned into `-` (herdr agents: session id from `herdr agent get NAME`; dclaude agents: under `~/.local/share/dclaude/claude/projects/`).
- Review rounds, ticket Comments, and the human's corrections.
- Stay inside this project's directories. Never read transcripts of unrelated projects.

## Find

What cost time or quality: findings a worker should have caught itself, fix loops that didn't converge, prompts a worker misread, the same correction from the human twice, approval dialogs that keep coming back, a step done by hand that a script could do.

## Route

Send each lesson to the highest place that prevents it, enforcement before text:

1. A test, lint, check or script in the repo.
2. The repo's `CLAUDE.md`, `REVIEW.md` or `CONSTRAINTS.md`.
3. Agent definitions and skills in `~/.claude/agents/` and `~/.claude/skills/`, or the sprint lead rules.

Repo changes go through the repo's normal flow. Never edit `~/.claude/` yourself: those files belong to the human's dotfiles, edited on their desktop. Write each proposed edit as the file, the exact text to add or change, and the evidence (transcript and turn, review round or ticket).

## Report

At most five lessons, most costly first: what happened, the evidence, the target, and the proposed edit.
