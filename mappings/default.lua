---@module "mappings.default"
---@author sravioli
---@license GNU-GPLv3

local wezterm = require "wezterm"
local act = wezterm.action
local key = require("utils.fn").key
local layout = require "utils.layout"

local Config = {}

Config.disable_default_key_bindings = true
Config.leader = { key = "Space", mods = "CMD", timeout_milliseconds = 1000 }

local mappings = {
  { "<C-Tab>", act.ActivateTabRelative(1), "next tab" },
  { "<C-S-Tab>", act.ActivateTabRelative(-1), "prev tab" },
  { "<M-CR>", act.ToggleFullScreen, "fullscreen" },
  { "<Cmd-C-f>", act.ToggleFullScreen, "fullscreen (macOS)" },
  { "<Cmd-c>", act.CopyTo "Clipboard", "copy" },
  { "<Cmd-v>", act.PasteFrom "Clipboard", "paste" },
  { "<Cmd-f>", act.Search "CurrentSelectionOrEmptyString", "search" },
  { "<Cmd-k>", act.ClearScrollback "ScrollbackOnly", "clear scrollback" },
  { "<Cmd-l>", act.ShowDebugOverlay, "debug overlay" },
  { "<Cmd-n>", act.SpawnWindow, "new window" },
  { "<Cmd-p>", act.ActivateCommandPalette, "command palette" },
  { "<Cmd-r>", act.ReloadConfiguration, "reload config" },
  { "<Cmd-t>", act.SpawnTab "CurrentPaneDomain", "new pane" },
  {
    "<Cmd-u>",
    act.CharSelect {
      copy_on_select = true,
      copy_to = "ClipboardAndPrimarySelection",
    },
    "char select",
  },
  { "<Cmd-w>", act.CloseCurrentTab { confirm = true }, "close tab" },
  { "<Cmd-M-w>", act.CloseCurrentPane { confirm = true }, "close pane" },
  { "<Cmd-q>", act.QuitApplication, "quit application" },
  { "<Cmd-z>", act.TogglePaneZoomState, "toggle zoom" },
  { "<PageUp>", act.ScrollByPage(-1), "" },
  { "<PageDown>", act.ScrollByPage(1), "" },
  { "<C-S-Insert>", act.PasteFrom "PrimarySelection", "" },
  { "<C-Insert>", act.CopyTo "PrimarySelection", "" },
  { "<C-S-Space>", act.QuickSelect, "quick select" },
  {
    "<S-M-t>",
    act.ShowLauncherArgs {
      title = "  Search:",
      flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS",
    },
    "new window",
  },

  ---quick split and nav
  -- NOTE: shifted symbols (", %) need SHIFT in mods or they never match,
  -- and Cmd+Shift+5 is taken by the macOS screenshot toolbar => use Cmd+D / Cmd+Shift+D
  { "<Cmd-d>", act.SplitHorizontal { domain = "CurrentPaneDomain" }, "split left/right" },
  { "<Cmd-S-D>", act.SplitVertical { domain = "CurrentPaneDomain" }, "split top/bottom" },
  -- adaptive layouts: direction + ratio computed from the pane's shape at runtime
  { "<Cmd-CR>", wezterm.action_callback(layout.smart_split), "smart split" },
  { "<Cmd-S-CR>", wezterm.action_callback(layout.auto_layout), "auto layout" },
  { "<Cmd-h>", act.ActivatePaneDirection "Left", "move left" },
  { "<Cmd-j>", act.ActivatePaneDirection "Down", "mode down" },
  { "<Cmd-k>", act.ActivatePaneDirection "Up", "move up" },
  { "<Cmd-l>", act.ActivatePaneDirection "Right", "move right" },
  -- arrow-key navigation (no system/AeroSpace conflict: those use Ctrl / Option)
  { "<Cmd-LeftArrow>", act.ActivatePaneDirection "Left", "focus left" },
  { "<Cmd-DownArrow>", act.ActivatePaneDirection "Down", "focus down" },
  { "<Cmd-UpArrow>", act.ActivatePaneDirection "Up", "focus up" },
  { "<Cmd-RightArrow>", act.ActivatePaneDirection "Right", "focus right" },

  ---key tables
  { "<leader>h", act.ActivateKeyTable { name = "help_mode", one_shot = true }, "help" },
  {
    "<leader>w",
    act.ActivateKeyTable { name = "window_mode", one_shot = false },
    "window mode",
  },
  {
    "<leader>f",
    act.ActivateKeyTable { name = "font_mode", one_shot = false },
    "font mode",
  },
  { "<leader>c", act.ActivateCopyMode, "copy mode" },
  { "<leader>s", act.Search "CurrentSelectionOrEmptyString", "search mode" },
  { "<leader>p", act.ActivateKeyTable { name = "pick_mode" }, "pick mode" },
}

for i = 1, 9 do
  mappings[#mappings + 1] =
    { "<Cmd-" .. i .. ">", act.ActivateTab(i - 1), "activate tab " .. i }
end

for i = 1, 24 do
  mappings[#mappings + 1] =
    { "<S-F" .. i .. ">", act.ActivateTab(i - 1), "activate tab " .. i }
end

Config.keys = {}
for _, map_tbl in ipairs(mappings) do
  key.map(map_tbl[1], map_tbl[2], Config.keys)
end

---mouse: Cmd + double-click toggles the window between maximised (zoom, the
---macOS "fill the screen but keep the menu bar" state) and its previous size.
local zoomed = {}

wezterm.on("toggle-window-zoom", function(window, _)
  local id = window:window_id()
  if zoomed[id] then
    window:restore()
    zoomed[id] = nil
  else
    window:maximize()
    zoomed[id] = true
  end
end)

Config.mouse_bindings = {
  {
    event = { Down = { streak = 2, button = "Left" } },
    mods = "SUPER",
    action = act.EmitEvent "toggle-window-zoom",
  },
}

return Config
