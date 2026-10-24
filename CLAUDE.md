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

Personal binaries stowed onto `$PATH`: `tmux-sessionizer` (fzf-over-`fd` project picker that creates/attaches tmux sessions), `tmux-windowizer`, `tmux-run-command`, `open-pass`, `open-tmp`, `script-runner`, `codex`, `dclaude`, `setup-agents`, `ha`, `hfork`. Shell scripts — no build step.

## Claude Code integration

`tools/claude/.claude/` holds the user-level Claude config, stowed into `~/.claude/`: `settings.json`, `CLAUDE.md`, `keybindings.json`, the rose-pine `statusline-command.sh` (reads Claude's JSON stdin, emits ANSI), `output-styles/` (Calm) and `hooks/herdr-worktree.py`. Edits made through Claude (`/config`, `/output-style`) land in the repo copy through the link.

`settings.json` keeps herdr's `SessionStart` entry verbatim (`bash '/home/corni/.claude/hooks/herdr-agent-state.sh' session`): herdr matches its entry by exact command, so changing the path makes `herdr integration install` add a duplicate. The hook script itself is generated per machine and gitignored.

The repo-local `.claude/settings.local.json` is gitignored — anything put there will not be tracked.

## Agent setup (Claude + herdr + dclaude)

How the pieces fit:

- **herdr** (`tools/herdr`) is the multiplexer; `.zshrc` starts it at login. `ha NAME [claude args]` spawns a named Claude agent in a new split; `hfork [NAME]` (run inside Claude as `!hfork`) forks the pane's conversation into a new split with `claude --resume <id> --fork-session`, which herdr tracks and can resume — unlike `/fork`, whose background session has no pane.
- **No background service in herdr panes**: `.zshrc` exports `CLAUDE_CODE_DISABLE_AGENT_VIEW=1` when `HERDR_ENV=1`. Otherwise Claude hosts every session in shared background workers carrying the env of whichever pane started the service, so herdr would track a viewer (no resume, no `hfork`, hooks hitting a stale pane). Background jobs (`claude agents`, `--bg`) are only available outside herdr.
- **`dclaude`** (`scripts/`) runs Claude in the project's devcontainer, falling back to `tools/devcontainer/.config/devcontainer/default/devcontainer.json`. The container gets its own `~/.local/share/dclaude/claude` state, with host config copied in each run and only `.credentials.json` mounted writable. It sets `HERDR_AGENT=claude` on the host-side wrapper so herdr detects it, and `DCLAUDE=1` inside.
- **Worktrees**: the `WorktreeCreate`/`WorktreeRemove` hooks route every Claude worktree through `herdr worktree create` (`~/.herdr/worktrees/<repo>/worktree-<name>`, shown as a herdr workspace). Without a running herdr server, or under `DCLAUDE=1`, they fall back to `git worktree add` under `<repo>/.claude/worktrees/`.

On a new machine: clone, then run `scripts/.local/bin/setup-agents`. It checks prerequisites, installs Claude, herdr and the devcontainer CLI when missing, stows `scripts` and `tools/{claude,herdr,devcontainer}` with `--no-folding` (backing up real files in the way), runs `herdr integration install claude` and writes the herdr skill. Rerun it after pulling.

## Install / bootstrap

`installer.sh` is **Arch/pacman-only** despite the README also documenting Debian/Ubuntu/WSL recipes. On non-Arch systems follow the README sections instead of running the script. The agent setup has its own distro-independent script, `setup-agents` (above).

## Git Workflow

- Keep git commit messages a concise one-liner
- don't sign commit messages
