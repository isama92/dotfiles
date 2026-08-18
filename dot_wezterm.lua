-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

config.initial_cols = 128
config.initial_rows = 28
config.font = wezterm.font('FiraCode Nerd Font')
config.font_size = 11
config.color_scheme = 'Catppuccin Latte'

-- Renderer: this build (20240203) defaults to WebGpu, which corrupts the glyph
-- atlas against current NVIDIA drivers: backgrounds paint but text goes missing
-- or smears, worst after a full repaint such as `chezmoi cd` spawning a subshell.
-- OpenGL is the stable path. Try 'Software' if artefacts survive this, and drop
-- the line entirely once WezTerm is updated past the Feb 2024 release.
config.front_end = 'OpenGL'


-- bash configuration
config.default_prog = { "C:\\Program Files\\Git\\bin\\bash.exe", "--login", "-i" }

-- and finally, return the configuration to wezterm
return config

