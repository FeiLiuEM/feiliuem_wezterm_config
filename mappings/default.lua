---@module "mappings.default"
---@author sravioli
---@license GNU-GPLv3

---@diagnostic disable-next-line: undefined-field
local act = require("wezterm").action
local key = require("utils.fn").key

local Config = {}

Config.disable_default_key_bindings = true
Config.leader = { key = "Space", mods = "CMD", timeout_milliseconds = 1000 }

local mappings = {
  { "<C-Tab>", act.ActivateTabRelative(1), "next tab" },
  { "<C-S-Tab>", act.ActivateTabRelative(-1), "prev tab" },
  { "<M-CR>", act.ToggleFullScreen, "fullscreen" },
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
  { '<Cmd-">', act.SplitHorizontal { domain = "CurrentPaneDomain" }, "vsplit" },
  { "<Cmd-%>", act.SplitVertical { domain = "CurrentPaneDomain" }, "hsplit" },
  { "<Cmd-h>", act.ActivatePaneDirection "Left", "move left" },
  { "<Cmd-j>", act.ActivatePaneDirection "Down", "mode down" },
  { "<Cmd-k>", act.ActivatePaneDirection "Up", "move up" },
  { "<Cmd-l>", act.ActivatePaneDirection "Right", "move right" },

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

return Config
