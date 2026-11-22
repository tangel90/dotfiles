---
name: agent-browser
description: Headless browser for agents. Use for screenshots, page checks, reading a rendered page, clicking through a UI or a prototype, and checking a local dev server. Runs without a window and opens no pane. Use this, not terminal-browser, unless the human asks to see a page themselves.
---

# agent-browser

`agent-browser` is a headless Chromium driven from the shell. It opens no
window and no pane, so it never disturbs the human's terminal. It is the
browser for your own checks: screenshots, rendered text, layout at phone
width, clicking through a flow.

The full, version-matched usage guide ships with the command. Read it before
the first use in a session instead of guessing flags:

```sh
agent-browser skills get core
```

`agent-browser skills list` shows specialised guides, and `agent-browser
--help` the command reference.

Rules:

- Close everything you opened before you report or end a round:
  `agent-browser close --all`. A browser left running slows every pane on the
  machine.
- Never run `terminal-browser open`: it splits the human's pane and keeps
  rendering. Only when the human explicitly asks to see a page in their
  terminal, and then `terminal-browser shutdown` when they're done.
- Screenshots go to a scratch folder or the path the task names, never into
  the repo unless the task asks for them there.
- Inside the `abox` sandbox the profile goes to a writable folder by itself
  (`AGENT_BROWSER_PROFILE`); outside it, agent-browser uses its default.
