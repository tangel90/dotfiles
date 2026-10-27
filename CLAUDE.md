---
id: CLAUDE
aliases: []
tags: []
---
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Personal dotfiles managed with **GNU Stow**. No build, no tests, no CI. Changes take effect on disk only after the relevant package is re-stowed (or the target file is already symlinked from a previous `stow`).

## Stow layout

Each top-level directory is a **stow package**: its subtree mirrors what should appear under `$HOME`. For example, `nvim/.config/nvim/init.lua` becomes `~/.config/nvim/init.lua` when `nvim` is stowed.

Packages: `nvim`, `shell` (contains `zsh` and `PowerShell` sub-packages), `term` (per-terminal sub-packages: `alacritty`, `kitty`, `wezterm`, `windows_terminal`), `tools` (`claude`, `devcontainer`, `herdr`, `visidata` sub-packages), `scripts` (`~/.local/bin`), `arch` (Hyprland / waybar / greetd / qutebrowser), `gnupg`.

```sh
# from repo root
stow nvim              # link ~/.config/nvim → nvim/.config/nvim
stow -D nvim           # unlink
stow -R nvim           # restow (rebuild symlinks)
stow shell/zsh         # sub-packages need the subdir path
```

`.stow-local-ignore` keeps `README.md`, `installer.sh`, `docs`, `.git*` out of stowing. `.gitignore` excludes `lazy-lock.json`, `vfs.toml`, `settings.local.json`, and vendored tmux plugins — do not commit those even if regenerated locally.

## Neovim config (the bulk of this repo)

**The active config is `nvim/.config/nvim/`** — a kickstart.nvim fork. The siblings `nvim-dev/`, `nvim-lazy/`, `nvim-minimax/`, `nvim-scratchpad/` are experimental / scratch. Do not edit those unless the user names one explicitly; switch with `NVIM_APPNAME=nvim-dev nvim` (aliased as `vimdev` in `.zshrc`, or the `vv` fzf picker).

### Load order — `init.lua`

```
config.options → config.autocmds → config.usercmds → config.keymaps →
config.functions → config.todo_tasks → config.highlights →
lazy-bootstrap → lazy-plugins
```

`config.snippets` is currently commented out. **Leader is `<Space>`** and is set in `config/options.lua` _before_ `lazy-plugins` loads — preserve that ordering if you add setup steps.

### Plugin system

- `lua/lazy-bootstrap.lua` clones lazy.nvim into `stdpath('data')/lazy/` on first run.
- `lua/lazy-plugins.lua` calls `require('lazy').setup({ { import = 'plugins' }, ... })`, so **every file in `lua/plugins/*.lua` is auto-imported** and must return a lazy.nvim spec (or list of specs). Adding a new plugin = drop a new file in that folder; no registration needed elsewhere.
- `lua/plugins/inactive/` holds disabled specs — it is _not_ imported, so files there are inert until moved up one directory.
- Plugin versions pinned by `lazy-lock.json` (gitignored). Use `:Lazy sync` / `:Lazy update` inside Neovim rather than hand-editing specs.

### Formatting

Lua is formatted with **stylua** per `nvim/.config/nvim/.stylua.toml` (2-space indent, 160 col, single quotes, no call parens). Run `stylua <file>` before committing Lua changes.

### WSL specifics

`config/options.lua` swaps in `win32yank.exe` for clipboard when `has('wsl')` is true — if clipboard breaks, confirm `win32yank.exe` is still on `$PATH`. `.zshrc` strips `/mnt/c` entries from `$PATH` on shell init, so Windows executables shelled out to from zsh must be referenced by absolute path.

## Shell (zsh)

`shell/zsh/.zshrc` launches or attaches herdr at login (tmux where herdr is missing), bootstraps **zinit**, loads **powerlevel10k** (config in `.p10k.zsh`), and turns on **vi-mode** bindings. Integrations wired via `eval`: `fzf`, `zoxide` (bound as `cd`), `direnv`. Notable aliases: `vim`→`nvim`, `cat`→`bat`, `grep`→`rg`, `e`→`yazi-cwd` (cd-to-yazi helper), `lg`→`gpg-unlock-lazygit`.

## Scripts (`scripts/.local/bin`)

Personal binaries stowed onto `$PATH`:

- **tmux**: `tmux-sessionizer` (fzf-over-`fd` project picker that creates/attaches tmux sessions), `tmux-windowizer`, `tmux-run-command`, `tmux-send-when-idle` (types a command into a session once its shell is idle), and the per-key jump-or-open helpers `tmux-lazygit`, `tmux-nvim` (nvim with direnv's env), `tmux-shell`, `tmux-yazi`, `tmux-yazi-picker`.
- **herdr / agents**: `dclaude`, `setup-agents`, `ha`, `hfork`, `hbreak`, `hlast`, `hlazygit`, `hlimits`, `hp`, `hcouple`, `hsplit`, `hnvim`, `hw` (see Agent setup below), `codex`.
- **runners**: `sqlrun` (SQL on Snowflake via `snow-parquet` or Postgres via `psql` → parquet/csv/jsonl, under `direnv exec`; `--open` shows it in visidata; nvim's `<leader>r*` SQL mappings call it), `mux-open` (run a command in a new herdr tab, or tmux window outside herdr — the only multiplexer-aware piece runners use).
- **misc**: `open-pass`, `open-tmp`, `open-kubeshell` (shell with a kubeconfig from pass), `script-runner`, `clipboard-copy` / `clipboard-paste` (system clipboard on any machine), `parquet-preview` (parquet as CSV text, for yazi), `snow-parquet` (Snowflake SQL to parquet; shebang points at the snowflake-cli uv tool), WSL-only `pwsh` (wraps the Windows `pwsh.exe`) and `wsl-reveal` (open a directory in Explorer).

Shell scripts — no build step, except `hp` (Python, stdlib only) and `snow-parquet`.

## Claude Code integration

`tools/claude/.claude/` holds the user-level Claude config, stowed into `~/.claude/`: `settings.json`, `CLAUDE.md`, `keybindings.json`, the rose-pine `statusline-command.sh` (reads Claude's JSON stdin, emits ANSI), `output-styles/` (Calm), `themes/` (Rose Pine: dark-ansi with a rose `text` token, which colours the response dot) `hooks/herdr-worktree.py` and `hooks/hcouple-hook.sh`. Edits made through Claude (`/config`, `/output-style`) land in the repo copy through the link.

`settings.json` has one herdr `SessionStart` entry per machine (`/home/corni`, `/home/thomas`), each guarded with `[ ! -f '<script>' ] || bash '<script>' session` so the other machine's entry is a no-op instead of an error. herdr matches its entry by exact command, so `herdr integration install` on a new machine adds one unguarded entry: add the guard to it. The hook script itself is generated per machine and gitignored.

Its `permissions.ask` makes host agents ask before `herdr pane read` / `herdr agent read`: through herdr they could otherwise read any pane's screen and scrollback, secrets shown there included (hcouple's hook reads outside the agent's Bash, unaffected).

The repo-local `.claude/settings.local.json` is gitignored — anything put there will not be tracked.

## Agent setup (Claude + herdr + dclaude)

How the pieces fit:

- **herdr** (`tools/herdr`) is the multiplexer; `.zshrc` starts it at login. `ha [--host] NAME [claude args]` spawns a named Claude agent in a new tab (labelled NAME) of the caller's workspace — through `dclaude --new` by default, plain host `claude` with `--host`; `hfork [NAME]` (run inside Claude as `!hfork`; NAME defaults to `<agent>-fork`) forks the pane's conversation into a new tab with `claude --resume <id> --fork-session`, which herdr tracks and can resume — unlike `/fork`, whose background session has no pane.
- **herdr config** lives in `tools/herdr/.config/herdr/config.toml` (prefix `ctrl+k`; custom keys: `prefix+t` new tab (no name prompt), `alt+left|right` previous|next tab, `alt+down|up` next|previous workspace, `prefix+ctrl+r` clear pane screen + scrollback, `j`/`k` workspaces and `J`/`K` panes in the `prefix+w` picker, `prefix+1..9` / `prefix+alt+n|p` focus agent by index / next|previous, `alt+1..9` tab by index, `prefix+m` runs `hbreak` via `[[keys.command]]`: moves the pane to a new tab, named after its agent if any; `prefix+o` runs `hnvim`: this workspace's nvim tab, opened at the project root if missing; `prefix+a` runs `hlast`: focuses the blocked or last-finished agent; `prefix+i` opens lazygit in a popup at the pane's cwd (`hlazygit`, a reused per-repo lazygit tab, is unbound); `prefix+s` opens `hp` in a popup, herdr's Settings moved to `prefix+shift+s`; `prefix+v` runs `hsplit`: split right, coupled to the tab's agent with `hcouple` (plain split on `prefix+shift+v`); `prefix+e` opens yazi in a popup at the pane's cwd, edit-scrollback moved to `prefix+shift+e`; `prefix+ctrl+w` / `prefix+alt+w` open `hw` in a popup (tmux-windowizer port: fzf a file below the pane's cwd / under ~, opened in nvim or visidata in a new tab); copy mode on `prefix+f`). The tab bar shows Claude usage via `hlimits` (5h with a bar, 7d as text), reading `~/.cache/claude-limits.json` that `statusline-command.sh` writes; the status line also reports each session's context use and model as pane metadata `$ctx` and `$model`; the agent sidebar (`ui.sidebar.agents.rows_by_agent.claude`) shows `$ctx`, coloured by level. Inside herdr the status line prints nothing; it only reports. Check key defaults/conflicts against `https://herdr.dev/llms.txt` (links the per-version `config-reference.json`); apply with `herdr config check && herdr server reload-config`.
- **`hp`** is the project picker (herdr's tmux-sessionizer): one fzf list of open workspaces, past Claude chats (host and dclaude, newest 10 per project, resumed via `ha --workspace` into the project's workspace), projects opened before (`~/.local/state/hp/history.json`) and every folder. A new workspace runs the project's `.herdr-start` (`label: command` per line, `ha` starts the agent named after the project), else `.tmux-start`'s command, else `agent: ha` when there's a `CLAUDE.md`.
- **`hcouple`**: typing `hcouple` (zsh function, `.zshrc`) in a shell pane couples it to the agent in the same tab (or `hcouple NAME`, `hcouple off`). Each finished command, with exit status and output read back from herdr, is appended to `<agent's config dir>/hcouple/<session>.log` (`~/.claude` or dclaude's state dir), and the agent's `UserPromptSubmit` hook `hcouple-hook.sh` hands it over with the next prompt; to give it one, a short note is typed into the agent once it is idle (a detached waiter covers a busy agent). For what agents can't run themselves, like sudo with a password.
- **No background service in herdr panes**: `.zshrc` exports `CLAUDE_CODE_DISABLE_AGENT_VIEW=1` when `HERDR_ENV=1`. Otherwise Claude hosts every session in shared background workers carrying the env of whichever pane started the service, so herdr would track a viewer (no resume, no `hfork`, hooks hitting a stale pane). Background jobs (`claude agents`, `--bg`) are only available outside herdr.
- **`dclaude`** (`scripts/`) runs Claude in the project's devcontainer, falling back to `tools/devcontainer/.config/devcontainer/default/devcontainer.json`. The container gets its own `~/.local/share/dclaude/claude` state, with host config copied in each run and only `.credentials.json` mounted writable. It sets `HERDR_AGENT=claude` on the host-side wrapper so herdr detects it, and `DCLAUDE=1` inside. Its SessionStart hook `hooks/dclaude-resume.sh` re-reports the session to herdr with `dclaude --resume <id>` as resume command, since herdr would otherwise resume with host `claude`. Without claude args it continues the project's latest container session (`--new` starts fresh). Bash runs in Claude's sandbox with `/herdr` (the socket dir) hidden, so commands can't drive host panes while hooks still report; it needs user namespaces, which the default devcontainer gets from `seccomp-userns.json` (Docker's default profile + namespace syscalls) via `runArgs` — project configs need the same, else dclaude warns and runs unsandboxed. Docker doesn't stop exec'd processes when the client goes away, so each run tags its container processes with `DCLAUDE_RUN` and a detached watcher stops them once the run's host side ends (closing the tab); leftovers whose watcher died too are reaped at the next start. Before starting Claude it sets the container's global git identity to the host's for the repo, turns on `worktree.useRelativePaths` (container paths in worktree links break git on the host) and runs `pre-commit install-hooks` outside the sandbox, whose proxy blocks github.com. It also passes `TERM`/`COLORTERM` through: docker exec's `TERM=xterm` makes Claude round theme colours to 16 (rose dot → white).
- **Worktrees**: the `WorktreeCreate`/`WorktreeRemove` hooks route every Claude worktree through `herdr worktree create` (`~/.herdr/worktrees/<repo>/worktree-<name>`, shown as a herdr workspace). Without a running herdr server, or under `DCLAUDE=1`, they fall back to `git worktree add` under `<repo>/.claude/worktrees/`.

On a new machine: clone, then run `scripts/.local/bin/setup-agents`. It checks prerequisites, installs Claude, herdr and the devcontainer CLI when missing, stows `scripts` and `tools/{claude,herdr,devcontainer}` with `--no-folding` (backing up real files in the way), runs `herdr integration install claude` and writes the herdr skill. Rerun it after pulling.

## Install / bootstrap

`installer.sh` is **Arch/pacman-only** despite the README also documenting Debian/Ubuntu/WSL recipes. On non-Arch systems follow the README sections instead of running the script. The agent setup has its own distro-independent script, `setup-agents` (above).

## Git Workflow

- Keep git commit messages a concise one-liner
- don't sign commit messages
