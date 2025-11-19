-- 1D cellular automaton lab (Rule 64)

PIX = 6
WIDTH = 100
HEIGHT = 60
GRID_OFFSET_Y = 70

rule = 64

State = {
  row = 1,
  grid = {},
  paused = false,
  random = false
}

rule_map = {}

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

-- pure builder for rule map
function make_rule()
  local map = { }
  for n = 0, 7 do
    local bit = math.floor(rule / (2 ^ n)) % 2
    map[n] = bit
  end
  return map
end

-- pure builder for empty grid
function make_grid()
  local grid = { }
  for y = 1, HEIGHT do
    grid[y] = { }
  end
  return grid
end

-- seed first row: center dot or random noise
function seed_row()
  local grid = State.grid
  for x = 1, WIDTH do
    if State.random then
      grid[1][x] = math.random(0, 1)
    else
      grid[1][x] = 0
    end
  end
  if not State.random then
    local center = math.floor(WIDTH / 2)
    grid[1][center] = 1
  end
  State.row = 1
end

-- full reset
function init()
  rule_map = make_rule()
  State.grid = make_grid()
  seed_row()
  State.paused = false
end

-- compute next row from previous one
function step()
  if State.row >= HEIGHT then return end
  local row = State.row
  local nxt = row + 1
  local grid = State.grid
  local map = rule_map
  for x = 1, WIDTH do
    local l = grid[row][x - 1] or 0
    local c = grid[row][x] or 0
    local r = grid[row][x + 1] or 0
    local code = l * 4 + c * 2 + r
    grid[nxt][x] = map[code]
  end
  State.row = nxt
end

-- draw entire grid
function draw_grid()
  local grid = State.grid
  for y = 1, HEIGHT do
    for x = 1, WIDTH do
      local v = grid[y][x]
      if v == 1 then
        gfx.setColor(COLOR_ON)
      else
        gfx.setColor(COLOR_OFF)
      end
      Pixel(x, y)
    end
  end
end

-- draw HUD: rule, row, state, seed
function draw_status()
  gfx.setColor(COLOR_FG)
  gfx.print("Rule: " .. rule, 4, 4)
  gfx.print("Row: " .. State.row, 4, 16)
  if State.paused then
    gfx.print("State: PAUSED", 4, 28)
  else
    gfx.print("State: RUNNING", 4, 28)
  end
  if State.random then
    gfx.print("Seed: RANDOM", 4, 40)
  else
    gfx.print("Seed: CENTER", 4, 40)
  end
end

-- draw controls help
function draw_help()
  local y = GRID_OFFSET_Y + HEIGHT * PIX + 4
  gfx.setColor(COLOR_FG)
  gfx.print("SPACE: pause  R: reset  N: step", 4, y)
  gfx.print("UP/DOWN: rule  S: seed  1-9: presets", 4, y + 12)
end

-- update loop: auto-step when not paused
function love.update()
  if not State.paused then
    step()
  end
end

-- main draw
function love.draw()
  gfx.clear(COLOR_BG[1], COLOR_BG[2], COLOR_BG[3])
  draw_grid()
  draw_status()
  draw_help()
end

KeyPress = {}

function key_toggle_pause()
  State.paused = not State.paused
end

function key_rule_up()
  rule = (rule + 1) % 256
  init()
end

function key_rule_down()
  rule = (rule + 255) % 256
  init()
end

function key_toggle_seed()
  State.random = not State.random
  init()
end

function key_step_once()
  if State.paused then
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
KeyPress.r = init
KeyPress.up = key_rule_up
KeyPress.down = key_rule_down
KeyPress.s = key_toggle_seed
KeyPress.n = key_step_once

function love.keypressed(key)
  local handler = KeyPress[key]
  if handler then
    handler()
    return
  end
  apply_preset_rule(key)
end

init()