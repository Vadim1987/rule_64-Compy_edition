-- 1D cellular automaton lab (Rule 64)

PIX = 6 -- cell size in pixels
WIDTH = 100 -- cells horizontally
HEIGHT = 60 -- cells vertically
GRID_OFFSET_Y = 70  -- top margin for HUD

rule = 64 -- default rule

State = {
  row = 1,
  grid = { },
  paused = false,
  random = false -- center seed by default
}

rule_map = { }

RULE_PRESET = {
  ["1"] = 30, 
  ["2"] = 60, 
  ["3"] = 90,
  ["4"] = 110, 
  ["5"] = 184, 
  ["6"] = 22,
  ["7"] = 50, 
  ["8"] = 126, 
  ["9"] = 250
}

gfx = love.graphics

COLOR_BG = Color[Color.black]
COLOR_FG = Color[Color.white + Color.bright]
COLOR_ON = Color[Color.white + Color.bright]
COLOR_OFF = Color[Color.black]

-- draw one cell
function Pixel(x, y)
  gfx.rectangle(
    "fill",
    (x - 1) * PIX,
    (y - 1) * PIX + GRID_OFFSET_Y,
    PIX,
    PIX
  )
end

-- build rule lookup table from RULE number
function make_rule()
  rule_map = { }
  for n = 0, 7 do
    local bit = math.floor(rule / (2 ^ n)) % 2
    rule_map[n] = bit
  end
end

-- prepare empty grid
function clear_grid()
  S.grid = { }
  for y = 1, HEIGHT do
    S.grid[y] = { }
  end
end

-- seed first row: center dot or random noise
function seed_row()
  for x = 1, WIDTH do
    if S.random then
      S.grid[1][x] = math.random(0, 1)
    else
      S.grid[1][x] = 0 end
  end
  if not S.random then
    local center = math.floor(WIDTH / 2)
    S.grid[1][center] = 1
  end
  S.row = 1
end

-- full reset
function init()
  make_rule()
  clear_grid()
  seed_row()
  S.paused = false
end

-- compute next row from previous one
function step()
  if S.row >= HEIGHT then return end
  local row = S.row
  local nxt = row + 1
  for x = 1, WIDTH do
    local l = S.grid[row][x - 1] or 0
    local c = S.grid[row][x] or 0
    local r = S.grid[row][x + 1] or 0
    local code = l * 4 + c * 2 + r
    S.grid[nxt][x] = rule_map[code]
  end
  S.row = nxt
end

-- draw entire grid
function draw_grid()
  for y = 1, HEIGHT do
    for x = 1, WIDTH do
      local v = S.grid[y][x]
      if v == 1 then
        gfx.setColor(COLOR_ON[1], COLOR_ON[2], COLOR_ON[3])
      else
        gfx.setColor(COLOR_OFF[1], COLOR_OFF[2], COLOR_OFF[3])
      end
      Pixel(x, y)
    end
  end
end

-- draw HUD: rule, row, state, seed
function draw_status()
  gfx.setColor(COLOR_ON)
  gfx.print("Rule: " .. rule, 4, 4)
  gfx.print("Row: " .. S.row, 4, 16)
  if S.paused then
    gfx.print("State: PAUSED", 4, 28)
  else
    gfx.print("State: RUNNING", 4, 28)
  end
  if S.random then
    gfx.print("Seed: RANDOM", 4, 40)
  else
    gfx.print("Seed: CENTER", 4, 40)
  end
end

-- draw controls help
function draw_help()
  local y = GRID_OFFSET_Y + HEIGHT * PIX + 4
  gfx.setColor(COLOR_FG[1], COLOR_FG[2], COLOR_FG[3])
  gfx.print("SPACE: pause  R: reset  N: step", 4, y)
  gfx.print("UP/DOWN: rule  S: seed  1-9: presets", 4, y + 12)
end

-- update loop: auto-step when not paused
function love.update()
  if not S.paused then
    step()
  end
end

-- main draw
function love.draw()
  gfx.clear(
  COLOR_BG[1],
  COLOR_BG[2], 
  COLOR_BG[3]
)
  draw_grid()
  draw_status()
  draw_help()
end

-- key actions (functions as values, в духе 2048-ревью)
KeyPress = {}

function key_toggle_pause()
  S.paused = not S.paused
end

function key_reset()
  init()
end

function key_rule_up()
  RULE = (RULE + 1) % 256
  init()
end

function key_rule_down()
  RULE = (RULE + 255) % 256
  init()
end

function key_toggle_seed()
  S.random = not S.random
  init()
end

function key_step_once()
  if S.paused then
    step()
  end
end

function apply_preset_rule(key)
  local preset = RULE_PRESET[key]
  if not preset then 
    return 
  end
  rule = preset
  init()
end

KeyPress.space = key_toggle_pause
KeyPress.r = key_reset
KeyPress.up = key_rule_up
KeyPress.down = key_rule_down
KeyPress.s = key_toggle_seed
KeyPress.n = key_step_once

-- keyboard input
function love.keypressed(key)
  local handler = KeyPress[key]
  if handler then
    handler()
    return
  end
  apply_preset_rule(key)
end

init()