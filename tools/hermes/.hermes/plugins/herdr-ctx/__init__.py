"""herdr-ctx: report Hermes' context use and model to herdr as pane metadata
($ctx, $model), as statusline-command.sh does for Claude and occtx for
OpenCode, so Hermes agents show $ctx in herdr's sidebar. Stowed from dotfiles
tools/hermes; enabled under plugins.enabled in ~/.hermes/config.yaml.
herdr's own plugin beside it (herdr-agent-state) reports the session.

Context used = the last main API request's total tokens (prompt + completion,
what the next request starts from); the window comes from Hermes' own model
metadata, cached per model.
"""

from __future__ import annotations

import os
import subprocess

_last = ""
_windows: dict[str, int] = {}


def _window(model: str, base_url: str, provider: str) -> int:
    key = f"{provider}/{model}"
    if key not in _windows:
        try:
            from agent.model_metadata import get_model_context_length

            _windows[key] = int(get_model_context_length(model, base_url=base_url, provider=provider) or 0)
        except Exception:
            _windows[key] = 0
    return _windows[key]


def _post_api_request(**kw) -> None:
    global _last
    pane = os.environ.get("HERDR_PANE_ID", "").strip()
    if os.environ.get("HERDR_ENV") != "1" or not pane:
        return
    usage = kw.get("usage") or {}
    used = int(usage.get("total_tokens") or 0)
    model = str(kw.get("model") or "")
    size = _window(model, str(kw.get("base_url") or ""), str(kw.get("provider") or ""))
    if not used or not size:
        return
    value = f"{min(100, used * 100 // size):02d}%"
    short = model.rsplit("/", 1)[-1]
    if f"{value}|{short}" == _last:
        return
    try:
        subprocess.run(
            ["herdr", "pane", "report-metadata", pane, "--source", "hermes-ctx",
             "--token", f"ctx={value}", "--token", f"model={short}"],
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=2, check=True,
        )
        _last = f"{value}|{short}"
    except Exception:
        pass


def register(ctx):
    ctx.register_hook("post_api_request", _post_api_request)
