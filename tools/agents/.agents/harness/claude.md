<!-- Claude Code: the passages agents-gen puts into the roles' {{> name}} places, each from its snippet marker to the next. -->

<!-- snippet: report -->

send one line, and nothing more, to the lead as a shell command: `hmail send <lead> "[<ticket id>] <your name>: done | blocked | question, see Comments"` (it waits until the lead is idle and the human isn't typing there, then types it in), and end your turn with the same line. The lead's name is in your first prompt ("Lead: ..."), and so is yours ("You are ..."): both are herdr names, which `hmail` takes. Don't use SendMessage for this: it addresses Claude's own session names, which differ from herdr's. If the prompt says "No lead", only write the Comment. The lead doesn't watch for you going idle, so without the message it never hears back.

<!-- snippet: reply-channel -->

sent to you by the worker with `hmail` (it arrives as a message starting with `[hmail]`, or attached to the human's next prompt)

<!-- snippet: lead-wait -->

- Send with `herdr agent prompt NAME "..."` **without `--wait`** and end your turn, so the human can keep talking to you. The worker's one-line `hmail` message wakes you; don't subscribe to idle notices (`notify_when_idle`): with the message, one worker turn would wake you twice, and every wake-up re-reads your whole context. To see where a worker stands, run `herdr agent get NAME` (status only) or read its ticket.

<!-- snippet: worker-notes -->

<!-- snippet: lead-notes -->
