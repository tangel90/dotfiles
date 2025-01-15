-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "rose-pine"
-- config.font = wezterm.font("JetBrainsMono Nerd Font")
config.default_prog = { "Arch" }
config.term = "xterm-256color"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.force_reverse_video_cursor = false
config.hide_tab_bar_if_only_one_tab = true
config.font_size = 16.0
-- and finally, return the configuration to wezterm
return config
