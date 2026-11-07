---@module "utils.layout"
---Adaptive pane layouts: pick the split direction from the pane's shape and
---split 50/50 (the direction still follows the pane's aspect ratio).

local M = {}

-- a terminal cell is roughly twice as tall as it is wide
local CELL_ASPECT = 0.5
-- share of the pane given to the NEW pane
local SPLIT_RATIO = 0.5
local MIN_COLS = 30
local MIN_ROWS = 8

---Visual width/height ratio of a pane (>= 1 means wider than tall).
---@param pane Pane
---@return number
local function aspect(pane)
  local d = pane:get_dimensions()
  local rows = math.max(d.viewport_rows or d.rows or 1, 1)
  return (d.cols * CELL_ASPECT) / rows
end

---Split the active pane, choosing direction and size automatically:
---wide panes split left/right, tall panes split top/bottom, 50/50 like the
---plain Cmd+D / Cmd+Shift+D bindings.
---@param _ Window
---@param pane Pane
function M.smart_split(_, pane)
  local d = pane:get_dimensions()
  local rows = d.viewport_rows or d.rows or 0

  if aspect(pane) >= 1 then
    if d.cols < MIN_COLS * 2 then
      return
    end
    pane:split { direction = "Right", size = SPLIT_RATIO }
  else
    if rows < MIN_ROWS * 2 then
      return
    end
    pane:split { direction = "Bottom", size = SPLIT_RATIO }
  end
end

---Build a whole layout in one keystroke: two panes when the pane is small,
---a 2x2 grid when there is room for four readable panes. Orientation follows
---the pane's aspect ratio (wide -> columns first, tall -> rows first).
---@param _ Window
---@param pane Pane
function M.auto_layout(_, pane)
  local d = pane:get_dimensions()
  local rows = d.viewport_rows or d.rows or 0
  local wide = aspect(pane) >= 1
  local dir_first = wide and "Right" or "Bottom"
  local dir_second = wide and "Bottom" or "Right"

  local second = pane:split { direction = dir_first, size = 0.5 }
  if not second then
    return
  end

  -- leave it at two panes unless there is room for four
  if d.cols < MIN_COLS * 4 or rows < MIN_ROWS * 3 then
    return
  end

  pane:split { direction = dir_second, size = 0.5 }
  second:split { direction = dir_second, size = 0.5 }
  pane:activate()
end

return M
