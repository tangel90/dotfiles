# Git

Don't sign commits or PRs: no `Co-Authored-By` trailer, no "Generated with Claude Code" line.

Commit messages have a subject and a body:

- Subject: `<area>: <what changed>`, at most 72 characters. For ticket work, end it with the ticket ID: `dashboard: group notes by day (N-7)`.
- Body, after a blank line, wrapped at 72: why the change was needed, what changed beyond the subject, and how it was verified. Name decisions and rejected alternatives that the code doesn't show. Tickets are local and untracked, so the commit is the lasting record: copy what matters out of the ticket rather than only pointing to it.
- Leave out the body only for trivial changes (a typo, a version bump).
- Squash merges get the same treatment: `gh pr merge --squash --subject "<subject> (<ticket>)" --body "<body>"`, with the review result in the body, instead of GitHub's default list of commit subjects.

Run git so Claude Code's built-in checks don't stop you with a permission dialog:

- Never `cd <repo> && git ...`: changing directory before a version-control command always asks. Run git from your session's own folder, or with `git -C <repo> ...`.
- No heredoc messages (`git commit -F - <<EOF`): the escaped whitespace asks too. Write the message to a file in your scratchpad (or `$TMPDIR`) with the Write tool, then `git commit -F <file>`.
