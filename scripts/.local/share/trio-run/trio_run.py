"""trio-run: read-only Jira for agents (issue list / issue view), JSON out.

    trio-run [jira] issue list [--project KEY] [--status S] [--assignee U|me]
                               [--label L] [--epic KEY-N] [--limit N] [--text]
    trio-run [jira] issue list --jql QUERY [--limit N] [--text]
    trio-run [jira] issue view KEY-N [--text]

Projects are limited to ~/.config/trio-run/projects. --project defaults to
the only allowed project when there is exactly one. --jql is wrapped as
`project in (<allowed>) AND (<query>)` (a trailing ORDER BY is kept outside);
issues from other projects are dropped from the result. --limit is capped at
100.

JSON fields:
  list: {"jql", "total", "issues": [{key, summary, type, status, assignee,
         priority, updated (YYYY-MM-DD), labels}], "dropped"}
  view: {key, summary, type, status, resolution, assignee, reporter,
         priority, labels, description, created, updated (YYYY-MM-DD),
         parent {key, summary, status} | null, subtasks [{key, summary,
         status, type}], comments [{author, body, created (YYYY-MM-DD HH:MM)}]}

Run by the trio-run shim with trio's own Python (-I) and a clean environment.
"""

import argparse
import json
import re
import sys
from pathlib import Path

ALLOW_FILE = Path.home() / ".config" / "trio-run" / "projects"
MAX_LIMIT = 100
JIRA_URL = "https://con.trianel.com/jira"
KEY = re.compile(r"^([A-Z][A-Z0-9_]*)-[0-9]+$")
USER = re.compile(r"^(me|[A-Za-z0-9._@-]+)$")


def fail(msg):
    print(f"trio-run: {msg}", file=sys.stderr)
    sys.exit(2)


def allowed():
    keys = ALLOW_FILE.read_text().split() if ALLOW_FILE.is_file() else []
    keys = [k.upper() for k in keys if re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*", k)]
    if not keys:
        fail(f"no allowed projects: list project keys in {ALLOW_FILE}")
    return keys


def split_jql(jql):
    """(body, order_by): checks that parentheses outside strings never close
    more than they opened, so the query can't escape the project wrapper."""
    depth, quote, i, order_at = 0, None, 0, None
    while i < len(jql):
        c = jql[i]
        if quote:
            if c == "\\":
                i += 1
            elif c == quote:
                quote = None
        elif c in "\"'":
            quote = c
        elif c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
            if depth < 0:
                fail("--jql: unbalanced ')'")
        elif depth == 0 and re.match(r"(?i)\border\s+by\b", jql[i:]) and (i == 0 or not jql[i - 1].isalnum()):
            order_at = i
        i += 1
    if quote or depth:
        fail("--jql: unclosed string or '('")
    if order_at is None:
        return jql.strip(), ""
    return jql[:order_at].strip(), " " + jql[order_at:].strip()


def main():
    argv = sys.argv[1:]
    if argv[:1] == ["jira"]:
        argv = argv[1:]
    ap = argparse.ArgumentParser(prog="trio-run", description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="group", required=True)
    issue = sub.add_parser("issue").add_subparsers(dest="cmd", required=True)
    ls = issue.add_parser("list")
    for opt in ("--project", "--status", "--assignee", "--label", "--epic", "--jql"):
        ls.add_argument(opt)
    ls.add_argument("--limit", type=int, default=25)
    ls.add_argument("--text", action="store_true")
    vw = issue.add_parser("view")
    vw.add_argument("key")
    vw.add_argument("--text", action="store_true")
    a = ap.parse_args(argv)

    keys = allowed()
    import os

    from trio.core.http import create_client
    from trio.tools.jira.commands import issue as ji
    from trio.tools.jira.plugin import JiraConfig

    # trio's own client setup insists on ~/.config/trio/jira/config.toml and
    # takes base_url from it; build the client here instead, from the token
    # the shim passes and a fixed URL, so no config file is needed and none
    # can send the token elsewhere.
    def client():
        token = os.environ.get("TRIO_JIRA_TOKEN", "")
        if not token:
            fail("no TRIO_JIRA_TOKEN (run through the trio-run shim)")
        cfg = JiraConfig(base_url=JIRA_URL, token=token, default_project=keys[0])
        return create_client(f"{JIRA_URL}/rest/api/2", token), cfg

    ji._get_client = client

    try:
        if a.cmd == "view":
            key = a.key.upper()
            m = KEY.match(key)
            if not m or m.group(1) not in keys:
                fail(f"{a.key}: not an issue key of an allowed project ({' '.join(keys)})")
            data = ji.issue_view_data(key)
            m = KEY.match(data.get("key", ""))
            if not m or m.group(1) not in keys:
                fail(f"{a.key} resolves to {data.get('key')}, outside the allowed projects")
            print(ji._render_issue_view(data) if a.text else json.dumps(data, ensure_ascii=False, indent=2))
            return

        limit = max(1, min(a.limit, MAX_LIMIT))
        if a.jql is not None:
            if any(v is not None for v in (a.project, a.status, a.assignee, a.label, a.epic)):
                fail("--jql replaces --project/--status/--assignee/--label/--epic; put every condition into the query")
            body, order = split_jql(a.jql)
            scope = f"project in ({', '.join(keys)})"
            jql = f"{scope} AND ({body}){order}" if body else f"{scope}{order}"
            result = ji.issue_list_data(limit=limit, jql=jql)
        else:
            project = (a.project or (keys[0] if len(keys) == 1 else "")).upper()
            if project not in keys:
                fail(f"--project must be one of: {' '.join(keys)}")
            if a.epic is not None and not KEY.match(a.epic.upper()):
                fail("--epic must be an issue key like RDS-12")
            if a.assignee is not None and not USER.match(a.assignee):
                fail("--assignee must be a user name or 'me'")
            result = ji.issue_list_data(project=project, epic=a.epic and a.epic.upper(), status=a.status,
                                        assignee=a.assignee, label=a.label, limit=limit)
    except ValueError as e:
        fail(str(e))

    issues = result.get("issues", [])
    kept = [i for i in issues if (m := KEY.match(i.get("key", ""))) and m.group(1) in keys]
    result = {**result, "issues": kept, "dropped": len(issues) - len(kept)}
    print(ji._render_issue_list(result) if a.text else json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
