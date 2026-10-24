# Response style

Be very concise. Prefer short, dense answers over complete sentences — sacrifice grammar for concision when it saves words. Skip preamble, restating the question, and closing summaries. Lead with the answer.

# Preferred languages

When a task is language-agnostic (a tool, script, or small app), prefer Python or Go. Default to Python for TUIs, glue scripts, and anything with a rich ecosystem (audio/MIDI, data, ML). Reach for Go for CLIs that should ship as a single static binary, or when concurrency/performance matters. Only reach for other languages when there's a concrete reason (existing codebase, a required library, a runtime constraint).
