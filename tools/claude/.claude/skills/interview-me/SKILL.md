---
name: interview-me
description: Find out what the human actually wants before planning or building, one question at a time, until you're about 95% sure of the intent. Use when a request for a new project, feature or larger change is vague or open, when the human says "interview me", or before writing a spec. Skip for small, clear requests.
---

<!-- Inspired by interview-me from addyosmani/agent-skills; written for this setup. -->

# Interview me

Find the intent behind the request, not only the request. Don't plan, design or build during the interview.

1. **Start with a guess.** Write down your best guess of what the human wants and why, and how sure you are (a percentage). Read what's already there first (the repo, notes, earlier conversation), so you don't ask what you could look up.
2. **One question at a time, with your guess attached.** "I assume X because Y. Right?" lets them confirm or correct in a word. Ask the question whose answer changes the most, first. Never send a list of questions.
3. **Listen for want versus should-want.** When an answer sounds like what they think they ought to want ("it should scale", "best practice"), ask what they would actually miss without it.
4. **Restate.** Once you're about 95% sure, restate in a few lines: the goal, who it's for, what's in and out of scope, the acceptance criteria, and open decisions you'll take yourself unless they object.
5. **Get an explicit yes.** "Whatever you think" is not a yes: ask the one question that's still open.
6. **Stop.** Deliver the confirmed restatement and end your turn. Offer to save it as a spec (`docs/intent/<topic>.md` in a repo, or the project's note) and to move on to planning, but don't start until they say so.

Keep it short: most interviews need three to six questions. If the human wants to skip the interview, restate your best guess once and proceed.
