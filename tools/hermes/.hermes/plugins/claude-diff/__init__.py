"""claude-diff: show Hermes' edit diffs the way Claude Code does.

Hermes (0.23) paints every changed line's whole background with a tint
of the skin's ui_ok / ui_error, and shows no line numbers. This replaces
agent.display._render_inline_unified_diff, the one function that turns
a unified diff section into lines, so that only the line number and the
+ / - sign carry the colour (ui_ok, ui_error) and the text keeps the
terminal's own colour; context lines get a dim number. Hermes' file
header, hunk summary and line limits around it stay as they are.

It patches a private function, so a Hermes update can rename it: then
register() finds nothing to replace and Hermes' own diffs come back.
Stowed from dotfiles tools/hermes; enabled under plugins.enabled in
~/.hermes/config.yaml.
"""

from __future__ import annotations

import re

_HUNK = re.compile(r"^@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@")
_RESET = "\033[0m"


def _fg(hex_color: str, fallback: tuple[int, int, int]) -> str:
    h = (hex_color or "").lstrip("#")
    try:
        r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4)) if len(h) == 6 else fallback
    except ValueError:
        r, g, b = fallback
    return f"\033[38;2;{r};{g};{b}m"


def _colors() -> dict[str, str]:
    from agent import display

    skin = None
    try:
        skin = display._get_skin()
    except Exception:
        pass

    def get(key: str) -> str:
        try:
            return skin.get_color(key, "") if skin else ""
        except Exception:
            return ""

    base = display._diff_ansi()
    return {
        "plus": _fg(get("ui_ok"), (60, 207, 90)),
        "minus": _fg(get("ui_error"), (235, 111, 146)),
        "dim": base.get("dim", "\033[2m"),
        "file": base.get("file", ""),
        "hunk": base.get("hunk", "\033[2m"),
    }


def _render(diff: str) -> list[str]:
    c = _colors()
    lines = diff.splitlines()
    # Width of the largest line number this section can show.
    top = 1
    for line in lines:
        m = _HUNK.match(line)
        if m:
            top = max(top, int(m.group(1)), int(m.group(2)))
    width = max(3, len(str(top + len(lines))))
    rendered: list[str] = []
    from_file = to_file = None
    old = new = 0
    hunks = 0
    for line in lines:
        if line.startswith("--- "):
            from_file = line[4:].strip()
            continue
        if line.startswith("+++ "):
            to_file = line[4:].strip()
            if from_file or to_file:
                rendered.append(f"{c['file']}{from_file or 'a/?'} → {to_file or 'b/?'}{_RESET}")
            continue
        m = _HUNK.match(line)
        if m:
            old, new = int(m.group(1)), int(m.group(2))
            if hunks:
                rendered.append(f"{c['hunk']}{'⋮':>{width}}{_RESET}")
            hunks += 1
            continue
        if line.startswith("+"):
            rendered.append(f"{c['plus']}{new:>{width}} +{_RESET} {line[1:]}")
            new += 1
        elif line.startswith("-"):
            rendered.append(f"{c['minus']}{old:>{width}} -{_RESET} {line[1:]}")
            old += 1
        elif line.startswith(" "):
            rendered.append(f"{c['dim']}{new:>{width}}  {_RESET} {line[1:]}")
            old += 1
            new += 1
        elif line.startswith("\\"):
            rendered.append(f"{c['dim']}{'':>{width}}   {line}{_RESET}")
        elif line:
            rendered.append(line)
    return rendered


def register(ctx):
    try:
        from agent import display
    except Exception:
        return
    if callable(getattr(display, "_render_inline_unified_diff", None)):
        display._render_inline_unified_diff = _render
