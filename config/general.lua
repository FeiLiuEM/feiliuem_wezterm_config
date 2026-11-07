local Icons = require "utils.class.icon"
local fs = require("utils.fn").fs

local Config = {}

if fs.platform().is_win then
  Config.default_prog =
    { "pwsh", "-NoLogo", "-ExecutionPolicy", "RemoteSigned", "-NoProfileLoadTime" }

  Config.launch_menu = {
    {
      label = Icons.Progs["pwsh.exe"] .. " PowerShell V7",
      args = {
        "pwsh",
        "-NoLogo",
        "-ExecutionPolicy",
        "RemoteSigned",
        "-NoProfileLoadTime",
      },
      cwd = "~",
    },
    {
      label = Icons.Progs["pwsh.exe"] .. " PowerShell V5",
      args = { "powershell" },
      cwd = "~",
    },
    { label = "Command Prompt", args = { "cmd.exe" }, cwd = "~" },
    { label = Icons.Progs["git"] .. " Git bash", args = { "sh", "-l" }, cwd = "~" },
  }

  -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
  Config.wsl_domains = {
    {
      name = "WSL:Ubuntu",
      distribution = "Ubuntu",
      username = "sravioli",
      default_cwd = "~",
      default_prog = { "bash", "-i", "-l" },
    },
    {
      name = "WSL:Alpine",
      distribution = "Alpine",
      username = "sravioli",
      default_cwd = "/home/sravioli",
    },
  }
end

Config.default_cwd = fs.home()

-- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
Config.ssh_domains = {}

-- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
Config.unix_domains = {}


Config.initial_rows = 30
Config.initial_cols = 91

-- macOS manages window position automatically
-- Manually position the window once and macOS will remember it

-- Keep the app running (and listed in Cmd+Tab / the Dock) after the last window
-- closes; activating it again spawns a fresh window instead of relaunching.
-- NOTE: with no window open WezTerm's own keymap cannot receive Cmd+N (upstream
-- issue #5764), so Cmd+N is provided by a macOS App Shortcut on the menu item
-- "New Window" -> @n, stored in `defaults write com.github.wez.wezterm NSUserKeyEquivalents`.
Config.quit_when_all_windows_are_closed = false

return Config
