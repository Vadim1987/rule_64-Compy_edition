-- 1D cellular automaton lab (Rule 64, micro-IDE)

PIX = 6  -- cell size in pixels
WIDTH = 100 -- cells horizontally
HEIGHT = 60 -- cells vertically
GRID_OFFSET_Y = 40 -- top margin for HUD

RULE = 64 -- default rule

S = {
  row = 1,
  grid = { },
  paused = false,
  random = false -- center seed by default
}

RULEMAP = { }
RULE_PRESET = {
  ["1"] = 30, ["2"] = 60, ["3"] = 90,
  ["4"] = 110, ["5"] = 184, ["6"] = 22,
  ["7"] = 50, ["8"] = 126, ["9"] = 250
}

gfx = love.graphics

COLOR_BG = Color[Color.black]
COLOR_FG = Color[Color.white + Color.bright]
COLOR_ON = Color[Color.white + Color.bright]
COLOR_OFF = Color[Color.black]

function Pixel(x, y)
  gfx.rectangle(
    "fill",
    (x - 1) * PIX,
    (y - 1) * PIX + GRID_OFFSET_Y,
    PIX,
    PIX
  )
end

function make_rule()
  RULEMAP = { }
  for n = 0, 7 do
    bit = math.floor(RULE / (2 ^ n)) % 2
    RULEMAP[n] = bit
  end
end

function clear_grid()
  S.grid = { }
  for y = 1, HEIGHT do
    S.grid[y] = {}
  end
end

function seed_row()
  for x = 1, WIDTH do
    S.grid[1][x] = 0
  end
  center = math.floor(WIDTH / 2)
  S.grid[1][center] = 1
  S.row = 1
end

function init()
  make_rule()
  clear_grid()
  seed_row()
  S.paused = false
end

function step()
  if S.paused then return end
  if S.row >= HEIGHT then return end
  row = S.row
  nxt = row + 1
  for x = 1, WIDTH do
    l = S.grid[row][x - 1] or 0
    c = S.grid[row][x] or 0
    r = S.grid[row][x + 1] or 0
    code = l * 4 + c * 2 + r
    S.grid[nxt][x] = RULEMAP[code]
  end
  S.row = nxt
end

function draw_grid()
  for y = 1, HEIGHT do
    for x = 1, WIDTH do
      v = S.grid[y][x]
      if v == 1 then
        gfx.setColor(COLOR_ON[1], COLOR_ON[2], COLOR_ON[3])
      else
        gfx.setColor(COLOR_OFF[1], COLOR_OFF[2], COLOR_OFF[3])
      end
      Pixel(x, y)
    end
  end
end

function draw_status()
  gfx.setColor(COLOR_FG[1], COLOR_FG[2], COLOR_FG[3])
  gfx.print("Rule: " .. RULE, 4, 4)
  gfx.print("Row: " .. S.row, 4, 16)
  if S.paused then gfx.print("State: PAUSED", 4, 28)
  else gfx.print("State: RUNNING", 4, 28)
  end
  if S.random then gfx.print("Seed: RANDOM", 4, 40)
  else gfx.print("Seed: CENTER", 4, 40)
  end
end

function draw_help()
  y = GRID_OFFSET_Y + HEIGHT * PIX + 4
  gfx.setColor(COLOR_FG[1], COLOR_FG[2], COLOR_FG[3])
  gfx.print("SPACE: pause  R: reset  N: step", 4, y)
  gfx.print("UP/DOWN: rule  S: seed  1-9: presets", 4, y + 12)
end

function love.update()
  if not S.paused then
    step()
  end
end

function love.draw()
  gfx.clear(COLOR_BG[1], COLOR_BG[2], COLOR_BG[3])
  draw_grid()
  draw_status()
  draw_help()
end

function love.keypressed(key)
  if key == "space" then S.paused = not S.paused end
  if key == "r" then init() end
  if key == "up" then RULE = (RULE + 1) % 256; init() end
  if key == "down" then RULE = (RULE + 255) % 256; init() end
  if key == "s" then S.random = not S.random; init() end
  if key == "n" and S.paused then step() end
  preset = RULE_PRESET[key]
  if preset then RULE = preset; init() end
end

init()