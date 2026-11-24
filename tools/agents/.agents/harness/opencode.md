<!-- OpenCode: the passages agents-gen puts into the roles' {{> name}} places, each from its snippet marker to the next. -->

<!-- snippet: report -->

send one line, and nothing more, to the lead yourself, as a shell command: `hmail send <lead> "[<ticket id>] <your name>: done | blocked | question, see Comments"` (it waits until the lead is idle and the human isn't typing there, then types it in). The lead's name is in your first prompt ("Lead: ..."), and so is yours ("You are ..."); send to exactly that lead and nobody else. If the prompt says "No lead", only write the Comment. The lead can't see when you finish, so without the message it never hears back.

<!-- snippet: reply-channel -->

sent to you by the worker with `hmail` (it arrives as a message starting with `[hmail]`)

<!-- snippet: lead-wait -->

- Send with `herdr agent prompt NAME "..."` and end your turn, so the human can keep talking to you. The worker's one-line `hmail` message wakes you when it's finished. Don't poll it with `herdr agent get` in a loop; to see where a worker stands, run `herdr agent get NAME` once (status only) or read its ticket.

<!-- snippet: worker-notes -->

## This harness

- Where these instructions name a skill, load it with the skill tool; the skills are the same files.
- **No pushing, no merging.** The lead ships. This sandbox has no GitHub login, and `git push` and `gh pr merge` are denied anyway.
- Commit messages follow the git rules in `~/.claude/CLAUDE.md`: read that file once before your first commit.

<!-- snippet: lead-notes -->

## This harness

- Where these instructions name a skill, load it with the skill tool; the skills are the same files. Git rules for commit and merge messages are in `~/.claude/CLAUDE.md`: read it once before your first `lead ship`.
- **Keep your context small.** Every token of it costs money on this model, so always suggest a fresh conversation after each closed ticket. Mid-ticket, don't: you'd lose the ticket's state.
- Push and merge only through `lead ship`; a plain `git push` is denied here.
