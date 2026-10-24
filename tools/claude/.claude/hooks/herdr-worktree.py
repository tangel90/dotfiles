#!/usr/bin/env python3
"""WorktreeCreate / WorktreeRemove hook: give Claude's worktrees to herdr.

With a WorktreeCreate hook configured, Claude routes every worktree it makes
(--worktree, its worktree tool, agent worktrees) through the hook instead of
running git itself, and uses whatever path the hook prints. Here that means
`herdr worktree create`, so each one also shows up as a herdr workspace
grouped under its repo, at ~/.herdr/worktrees/<repo>/<branch>.

When no herdr server is running, or inside a dclaude container (DCLAUDE=1,
where herdr's host paths aren't mounted), it does what Claude would have done
without the hook: `git worktree add` under <repo>/.claude/worktrees/<name>.

Branches are worktree-<name>, as Claude names its own, so a worktree name can
never collide with (and check out) one of the user's branches.

Usage, from settings.json: herdr-worktree.py create | remove
"""

import json
import os
import subprocess
import sys
from pathlib import Path


def run(*args, cwd=None):
    return subprocess.run(args, cwd=cwd, check=True, capture_output=True, text=True).stdout.strip()


def herdr_available():
    if os.environ.get("DCLAUDE") == "1":
        return False
    try:
        return "status: running" in run("herdr", "status", "server")
    except (OSError, subprocess.CalledProcessError):
        return False


def base_ref(repo):
    # Claude's default ("fresh"): branch from the remote's default branch, so
    # a worktree doesn't inherit whatever the main checkout has in progress.
    try:
        run("git", "rev-parse", "--verify", "-q", "origin/HEAD", cwd=repo)
        return "origin/HEAD"
    except subprocess.CalledProcessError:
        return "HEAD"


def branch_exists(repo, branch):
    try:
        run("git", "rev-parse", "--verify", "-q", f"refs/heads/{branch}", cwd=repo)
        return True
    except subprocess.CalledProcessError:
        return False


def create(hook):
    name = hook["name"]
    repo = run("git", "rev-parse", "--show-toplevel", cwd=hook.get("cwd") or os.getcwd())
    branch = f"worktree-{name}"
    base = base_ref(repo)

    if herdr_available():
        out = run("herdr", "worktree", "create", "--cwd", repo, "--branch", branch, "--base", base, "--no-focus")
        return json.loads(out)["result"]["worktree"]["path"]

    path = Path(repo) / ".claude" / "worktrees" / name
    if branch_exists(repo, branch):
        run("git", "worktree", "add", str(path), branch, cwd=repo)
    else:
        run("git", "worktree", "add", "-b", branch, str(path), base, cwd=repo)
    return str(path)


def herdr_workspace_for(path):
    out = json.loads(run("herdr", "worktree", "list", "--cwd", path))
    for wt in out["result"]["worktrees"]:
        if wt.get("path") == path:
            return wt.get("open_workspace_id")
    return None


def remove(hook):
    path = hook["worktree_path"]
    branch = run("git", "branch", "--show-current", cwd=path)
    # The main checkout, for deleting the branch once the worktree is gone.
    repo = str(Path(run("git", "rev-parse", "--path-format=absolute", "--git-common-dir", cwd=path)).parent)

    # Claude has already refused (or been told to discard) uncommitted work
    # by the time this runs, so neither path needs to second-guess it.
    workspace = herdr_workspace_for(path) if herdr_available() else None
    if workspace:
        # Also closes the workspace; herdr never deletes the branch itself.
        run("herdr", "worktree", "remove", "--workspace", workspace, "--force")
    else:
        run("git", "worktree", "remove", "--force", path, cwd=repo)

    # Only branches this hook (or Claude) named; never a user's own branch.
    if branch.startswith("worktree-"):
        run("git", "branch", "-D", branch, cwd=repo)


def main():
    hook = json.load(sys.stdin)
    try:
        if sys.argv[1:] == ["create"]:
            print(create(hook))
        elif sys.argv[1:] == ["remove"]:
            remove(hook)
        else:
            sys.exit(f"usage: {sys.argv[0]} create|remove")
    except subprocess.CalledProcessError as e:
        sys.exit(f"{' '.join(e.cmd)}: {e.stderr.strip() or e}")


if __name__ == "__main__":
    main()
