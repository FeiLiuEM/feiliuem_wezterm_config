local Utils = require "utils"
local color = Utils.fn.color

---@diagnostic disable-next-line: undefined-field
local G = require("wezterm").GLOBAL

local Config = {}

Config.color_schemes = color.get_schemes()
Config.color_scheme = color.get_scheme()

local theme = Config.color_schemes[Config.color_scheme]

-- Disable background rendering to reduce CPU usage
Config.background = nil

Config.bold_brightens_ansi_colors = "BrightAndBold"

---char select and command palette
Config.char_select_bg_color = theme.brights[6]
Config.char_select_fg_color = theme.background
Config.char_select_font_size = 12

Config.command_palette_bg_color = theme.brights[6]
Config.command_palette_fg_color = theme.background
Config.command_palette_font_size = 14
Config.command_palette_rows = 20

---cursor - disable blinking to reduce CPU
Config.cursor_blink_rate = 0
Config.default_cursor_style = "BlinkingUnderline"
Config.cursor_thickness = 1
Config.force_reverse_video_cursor = true

Config.enable_scroll_bar = false

Config.hide_mouse_cursor_when_typing = true

---text blink - disable all blinking effects
Config.text_blink_rate = 0
Config.text_blink_rate_rapid = 0

---visual bell - disable visual effects
Config.audible_bell = "Disabled"
Config.visual_bell = nil

---window appearance
Config.window_decorations = "RESIZE"
-- macOS 27 draws much rounder window corners than before; with the old 1px/0px padding
-- the corner arcs clipped the first/last characters of each line. WezTerm's plain numbers
-- are *pixels*, so use explicit "pt" units to stay DPI-independent (~28 device px on retina)
-- and keep the whole text grid clear of the corner arcs and of the traffic lights.
Config.window_padding = { left = "14pt", right = "14pt", top = "12pt", bottom = "10pt" }
Config.integrated_title_button_alignment = "Right"
Config.integrated_title_button_style = "Windows"
Config.integrated_title_buttons = { "Hide", "Maximize", "Close" }

---exit behavior
Config.clean_exit_codes = { 130 }
Config.exit_behavior = "CloseOnCleanExit"
Config.exit_behavior_messaging = "Verbose"
Config.skip_close_confirmation_for_processes_named = {
  "bash",
  "sh",
  "zsh",
  "fish",
  "tmux",
  "nu",
  "cmd.exe",
  "pwsh.exe",
  "powershell.exe",
}
Config.window_close_confirmation = "AlwaysPrompt"

color.set_tab_button(Config, theme)

return Config
