local Config = require("utils.class.config"):new()

require "events.update-status"
require "events.format-tab-title"
require "events.new-tab-button-click"
require "events.augment-command-palette"

local config = Config:add("config"):add "mappings"

-- Optional machine-local overlay: `machine.lua` next to this file is untracked by
-- the repo and lets a single host tweak the shared config (fonts, conflicting
-- desktop shortcuts, ...) without forking it. It must return a function that takes
-- and returns the config table.
local has_overlay, overlay = pcall(require, "machine")
if has_overlay and type(overlay) == "function" then
  config = overlay(config)
end

return config
