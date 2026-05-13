# Colorscheme map

Current theme across the stack: **Rosé Pine** (mostly "main", a couple on "moon").
Excluded from `stow` via `.stow-local-ignore` (the `docs/` rule), so this file
lives in the repo only.

## Where each tool reads its colors

| Tool | File | Mechanism |
|---|---|---|
| Neovim — colorscheme plugin spec | `nvim/.config/nvim/lua/plugins/rose-pine-colorscheme.lua` | `require('rose-pine').setup{}` + `vim.cmd 'colorscheme rose-pine'` |
| Neovim — shared palette (hardcoded hex) | `nvim/.config/nvim/lua/config/palette.lua` | Lua module re-used by markview, obsidian, lualine overrides |
| Neovim — markview overrides | `nvim/.config/nvim/lua/plugins/markview.lua` | Reads from `palette.lua` |
| Neovim — obsidian UI highlights | `nvim/.config/nvim/lua/plugins/obsidian.lua` | Reads from `rose-pine.palette` + `palette.lua` |
| tmux — variant + plugin opts | `shell/zsh/.config/tmux/tmux.conf` | `set -g @plugin 'rose-pine/tmux'` + `set -g @rose_pine_variant 'main'` |
| tmux — forked render script (status line colors/format) | `shell/zsh/.config/tmux/plugins/tmux/rose-pine.tmux` | Tracked fork of the upstream plugin. **TPM updates will overwrite this** unless excluded. |
| Kitty | `term/kitty/.config/kitty/kitty.conf` → includes `current-theme.conf` | `current-theme.conf` is a copy of `rose-pine-moon.conf` (also `rose-pine.conf` sits alongside) |
| Alacritty | `term/alacritty/.config/alacritty/alacritty.toml` | **Inline hex** under `[colors.*]` (the sibling `rose-pine.toml` / `catppuccin-mocha.toml` are unused reference files) |
| WezTerm | `term/wezterm/.wezterm.lua` | `config.color_scheme = "rose-pine-moon"` (named scheme from WezTerm's built-ins) |
| Windows Terminal | `term/windows_terminal/settings.json` | `"theme": "rose-pine"` + `"colorScheme": "rose-pine"` per profile, **scheme defined inline** under `"schemes"` |
| VisiData | `tools/visidata/.visidatarc` | Hand-rolled `vd.themes["rosepine_ascii"]` dict (ANSI 256 + hex) |
| Yazi | `shell/zsh/.config/yazi/theme.toml` | Hand-rolled hex per UI element |
| Claude Code statusline | `tools/claude/.claude/statusline-command.sh` | Hardcoded ANSI 24-bit escape sequences (`#31748f` etc.) |
| Hyprland | `arch/.config/hypr/hyprland.conf` → sources `rose-pine.conf` / `rose-pine-moon.conf` | Include line in `hyprland.conf` |
| Waybar | `arch/.config/waybar/style.css` | Hand-rolled CSS hex |
| qutebrowser | `arch/.config/qutebrowser/config.py` | Hand-rolled `c.colors.*` |

## Can this be centralized?

**No, not cleanly.** Three categories of obstacle:

1. **Tools that take a named scheme** (Neovim, tmux, Kitty, WezTerm, Windows
   Terminal): each is a one-line change, but the *names* differ
   (`rose-pine`, `rose-pine-moon`, `rosé-pine`, etc.) and the *config syntax*
   differs (Lua, tmux conf, kitty include, Lua table, JSON).
2. **Tools with hex/ANSI baked into their own config** (Alacritty inline,
   VisiData, Yazi, Claude statusline, Waybar, qutebrowser, Neovim's
   `palette.lua`): switching means editing the hex values themselves.
3. **Stow is a symlink tool, not a templating tool** — there is no native
   variable substitution. A real central source of truth would need either
   `chezmoi`-style templates, a build step, or a generator script.

## Realistic switching paths

- **Stay on a Rosé Pine variant** (main ↔ moon ↔ dawn): cheap — flip the
  variant name in the ~5 named-scheme files, and copy the right
  `rose-pine-*.conf` over `current-theme.conf` for Kitty. The hand-rolled
  files (palette.lua, VisiData, Yazi, statusline, Waybar) only need to change
  if you want them to match the new variant exactly.
- **Switch to a different family** (e.g. Catppuccin, Tokyonight, Kanagawa):
  every named-scheme file needs a swap *and* every hand-rolled hex file
  needs to be rewritten with the new palette. This is where it gets painful.

## Suggested middle-ground if you want to make this easier later

Write a `scripts/.local/bin/switch-theme` shell script that:

1. Takes a theme name as argument (`switch-theme rose-pine-moon`, `dawn`, etc.).
2. Patches the named-scheme lines in nvim, tmux, wezterm, windows-terminal,
   and copies the right Kitty `*.conf` over `current-theme.conf`.
3. For the hand-rolled configs, reads a palette JSON/TOML and uses `sed` (or a
   small Python templating step) to rewrite the hex blocks between marker
   comments like `# THEME_BEGIN` / `# THEME_END`.

That converts "edit 8 files by hand" into "one command + maintain one palette
file per theme" — but requires upfront work to add the marker comments and
the script. Worth it only if you intend to switch themes frequently.

## Quick-flip checklist (Rosé Pine variant swap)

If you just want main → moon (or back), edit these in lockstep:

- `nvim/.config/nvim/lua/plugins/rose-pine-colorscheme.lua` — `vim.cmd 'colorscheme rose-pine-<variant>'`
- `nvim/.config/nvim/lua/config/palette.lua` — swap which palette table the file returns (or just point at the matching one)
- `shell/zsh/.config/tmux/tmux.conf` — `@rose_pine_variant`
- `shell/zsh/.config/tmux/plugins/tmux/rose-pine.tmux` — forked render script; only touch if status-line colors/format need to follow the variant. Beware TPM updates clobber this file.
- `term/kitty/.config/kitty/current-theme.conf` — overwrite with contents of `rose-pine.conf` or `rose-pine-moon.conf`
- `term/wezterm/.wezterm.lua` — `config.color_scheme`
- `term/windows_terminal/settings.json` — `theme` + `colorScheme` (scheme contents are inline; the per-variant hex values would also need swapping if you care)
- `term/alacritty/.config/alacritty/alacritty.toml` — replace the `[colors.*]` block
- `tools/visidata/.visidatarc` — only if you want palette to match exactly
- `shell/zsh/.config/yazi/theme.toml` — same
- `tools/claude/.claude/statusline-command.sh` — same
- `arch/.config/hypr/hyprland.conf` — swap the `source = rose-pine*.conf` line
