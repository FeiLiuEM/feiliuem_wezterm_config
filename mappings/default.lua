---@module "mappings.default"
---@author sravioli
---@license GNU-GPLv3

local wezterm = require "wezterm"
local act = wezterm.action
local key = require("utils.fn").key
local layout = require "utils.layout"

local Config = {}

local platform = require("utils.fn").fs.platform()

Config.disable_default_key_bindings = true
-- macOS leaves CMD to the app. Elsewhere CMD *is* SUPER and the desktop shell owns most
-- SUPER combos (KWin: Meta+L/W/T/D/G/1..9/arrows; Windows: Win+L/D/E/arrows), so the
-- leader moves to CTRL|SHIFT+Space (plain CTRL+Space is the IME toggle on both).
Config.leader = not platform.is_mac
    and { key = "Space", mods = "CTRL|SHIFT", timeout_milliseconds = 1000 }
  or { key = "Space", mods = "CMD", timeout_milliseconds = 1000 }

---Set to true to *also* bind plain CTRL+<letter> for the Linux/Windows layer.  Off by
---default because those keys belong to the shell: Ctrl+C stops the running command,
---Ctrl+D closes it, Ctrl+R searches history, Ctrl+W/K/U edit the line, Ctrl+Z suspends,
---Ctrl+V is vim's visual-block.  Turning this on trades all of that for macOS-like muscle
---memory; the CTRL|SHIFT bindings keep working either way.
local FORCE_PLAIN_CTRL = false

---ALT layer opt-out: letters listed here keep their shell meaning (bash/zsh/readline
---Alt+B/F word motion, Alt+D kill word, Alt+F forward word, ...). e.g. `{ f = true }`
---hands Alt+F back to the shell and keeps the WezTerm search on CTRL|SHIFT+F.
local ALT_SKIP = {}

local mappings = {
  { "<C-Tab>", act.ActivateTabRelative(1), "next tab" },
  { "<C-S-Tab>", act.ActivateTabRelative(-1), "prev tab" },
  { "<M-CR>", act.ToggleFullScreen, "fullscreen" },
  { "<Cmd-C-f>", act.ToggleFullScreen, "fullscreen (macOS)" },
  -- keyboard twin of Cmd+double-click: TUIs that grab the mouse (hermes, herdr)
  -- swallow mouse events, so keep a keyboard path to the same window zoom
  { "<Cmd-C-m>", act.EmitEvent "toggle-window-zoom", "maximise window" },
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

---Linux/Windows: mirror the CMD layer onto CTRL.
---A terminal cannot take plain CTRL+letter there - Ctrl+C/D/Z are signals and
---Ctrl+A/E/F/H/J/K/L/N/P/R/T/U/V/W are readline/vi editing keys - so letters become
---CTRL|SHIFT (CTRL|ALT where the CMD+SHIFT form would collide) while the conventional
---terminal forms (CTRL+digit, CTRL+Enter, CTRL+arrow) stay plain.
if not platform.is_mac then
  ---Focus the pane in `direction`; with a single pane the key belongs to the shell, so
  ---forward it rather than swallowing the shell's own CTRL/ALT+arrow binding.
  local function pane_focus(direction, key_name, mods)
    return wezterm.action_callback(function(window, pane)
      -- Unknown/tab API hiccup: assume multiple panes rather than swallowing the key.
      local ok, count = pcall(function()
        local n = 0
        for _ in pairs(window:active_tab():panes()) do
          n = n + 1
        end
        return n
      end)

      if not ok or count > 1 then
        window:perform_action(act.ActivatePaneDirection(direction), pane)
      else
        window:perform_action(act.SendKey { key = key_name, mods = mods or "CTRL" }, pane)
      end
    end)
  end

  local ctrl = {
    ---clipboard, search, app
    { "<C-S-c>", act.CopyTo "Clipboard", "copy" },
    { "<C-S-v>", act.PasteFrom "Clipboard", "paste" },
    { "<C-S-f>", act.Search "CurrentSelectionOrEmptyString", "search" },
    { "<C-S-p>", act.ActivateCommandPalette, "command palette" },
    { "<C-S-r>", act.ReloadConfiguration, "reload config" },
    { "<C-S-q>", act.QuitApplication, "quit application" },
    {
      "<C-S-u>",
      act.CharSelect { copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" },
      "char select",
    },
    { "<C-S-k>", act.ClearScrollback "ScrollbackOnly", "clear scrollback" },
    { "<C-S-l>", act.ShowDebugOverlay, "debug overlay" },
    { "<C-S-m>", act.EmitEvent "toggle-window-zoom", "maximise window" },

    ---tabs, windows, panes
    { "<C-S-t>", act.SpawnTab "CurrentPaneDomain", "new tab" },
    { "<C-S-n>", act.SpawnWindow, "new window" },
    { "<C-S-w>", act.CloseCurrentTab { confirm = true }, "close tab" },
    { "<C-M-w>", act.CloseCurrentPane { confirm = true }, "close pane" },
    { "<C-S-z>", act.TogglePaneZoomState, "toggle zoom" },
    { "<C-S-d>", act.SplitHorizontal { domain = "CurrentPaneDomain" }, "split left/right" },
    { "<C-S-e>", act.SplitVertical { domain = "CurrentPaneDomain" }, "split top/bottom" },
    { "<C-CR>", wezterm.action_callback(layout.smart_split), "smart split" },
    { "<C-S-CR>", wezterm.action_callback(layout.auto_layout), "auto layout" },

    ---pane navigation
    { "<C-LeftArrow>", pane_focus("Left", "LeftArrow"), "focus left" },
    { "<C-RightArrow>", pane_focus("Right", "RightArrow"), "focus right" },
    { "<C-UpArrow>", pane_focus("Up", "UpArrow"), "focus up" },
    { "<C-DownArrow>", pane_focus("Down", "DownArrow"), "focus down" },
    { "<C-S-LeftArrow>", act.ActivatePaneDirection "Left", "focus left" },
    { "<C-S-RightArrow>", act.ActivatePaneDirection "Right", "focus right" },
    { "<C-S-UpArrow>", act.ActivatePaneDirection "Up", "focus up" },
    { "<C-S-DownArrow>", act.ActivatePaneDirection "Down", "focus down" },
  }

  for i = 1, 9 do
    ctrl[#ctrl + 1] = { "<C-" .. i .. ">", act.ActivateTab(i - 1), "activate tab " .. i }
  end

  ---optional: mirror every CTRL|SHIFT+<letter> onto plain CTRL+<letter>
  if FORCE_PLAIN_CTRL then
    local plain = {}
    for _, map_tbl in ipairs(ctrl) do
      local letter = map_tbl[1]:match "^<C%-S%-(.-)>$"
      if letter then
        plain[#plain + 1] = { "<C-" .. letter .. ">", map_tbl[2] }
      end
    end
    for _, map_tbl in ipairs(plain) do
      ctrl[#ctrl + 1] = map_tbl
    end
  end

  for _, map_tbl in ipairs(ctrl) do
    key.map(map_tbl[1], map_tbl[2], Config.keys)
  end

  ---ALT layer: one modifier, hence closest to macOS CMD. It is not free either - bash,
  ---zsh and readline bind Alt+B/F (word motion), Alt+D (kill word), Alt+C/U/L (word case),
  ---Alt+T (transpose words), Alt+W (copy region). Put a letter in ALT_SKIP above to hand
  ---that one back to the shell; ALT+arrow (pane focus) also falls through when there is a
  ---single pane.
  local alt = {
    { "c", act.CopyTo "Clipboard" },
    { "v", act.PasteFrom "Clipboard" },
    { "f", act.Search "CurrentSelectionOrEmptyString" },
    { "p", act.ActivateCommandPalette },
    { "r", act.ReloadConfiguration },
    { "q", act.QuitApplication },
    { "t", act.SpawnTab "CurrentPaneDomain" },
    { "n", act.SpawnWindow },
    { "w", act.CloseCurrentTab { confirm = true } },
    { "z", act.TogglePaneZoomState },
    { "m", act.EmitEvent "toggle-window-zoom" },
    { "d", act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { "e", act.SplitVertical { domain = "CurrentPaneDomain" } },
    { "k", act.ClearScrollback "ScrollbackOnly" },
    { "l", act.ShowDebugOverlay },
    {
      "u",
      act.CharSelect { copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" },
    },
  }

  for _, map_tbl in ipairs(alt) do
    local letter, action = map_tbl[1], map_tbl[2]
    if not ALT_SKIP[letter] then
      key.map("<M-" .. letter .. ">", action, Config.keys)
    end
  end

  ---ALT+Shift+Enter: smart split (ALT+Enter itself stays fullscreen, as upstream)
  key.map("<M-S-CR>", wezterm.action_callback(layout.smart_split), Config.keys)

  ---ALT+arrow: pane focus, forwarding the plain ALT+arrow to the shell when alone
  key.map("<M-LeftArrow>", pane_focus("Left", "LeftArrow", "ALT"), Config.keys)
  key.map("<M-RightArrow>", pane_focus("Right", "RightArrow", "ALT"), Config.keys)
  key.map("<M-UpArrow>", pane_focus("Up", "UpArrow", "ALT"), Config.keys)
  key.map("<M-DownArrow>", pane_focus("Down", "DownArrow", "ALT"), Config.keys)

  ---ALT+1..9 switch tabs
  for i = 1, 9 do
    key.map("<M-" .. i .. ">", act.ActivateTab(i - 1), Config.keys)
  end
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
