## Rule 64 – 1D Cellular Automaton Lab

This small project demonstrates how simple rules 
can create complex patterns. It is designed as 
a learning tool for children (and curious adults) 
to explore how tiny mathematical universes 
evolve over time.

The example shows how to:
- store the entire world in one state table
- update it step-by-step in a predictable way
- draw a new row at each step
- switch rules interactively in real time

Cellular automata are perfect for learning programming:
the rules are tiny, the behavior is beautiful, 
and the code is clean.

⸻

## 1. Files and Purpose

The project consists of a single file:
- main.lua — contains the state, rule decoding, 
update logic, drawing, and input.

Even though it’s one file, the program is split into 
clear sections:
- constants
- state
- drawing helpers
- simulation rules
- update loop
- keyboard actions



⸻

## 2. Constants

These values describe the size of the universe and the color palette:

PIX  = 6
WIDTH  = 100
HEIGHT = 60
GRID_OFFSET_Y = 70

COLOR_BG = Color[Color.black]
COLOR_FG = Color[Color.white + Color.bright]
COLOR_ON = Color[Color.white + Color.bright]
COLOR_OFF = Color[Color.black]

Cells are drawn as squares of size PIX.
The universe is 100 cells wide and 60 rows tall.

GRID_OFFSET_Y moves the simulation down,
so the HUD text does not overlap with the picture.

⸻

## 3. State Table

All game data is kept inside one table:

State = {
  row = 1,
  grid = { },
  paused = false,
  random = false
}

- row — which row is currently being filled
- grid — the entire universe
- paused — whether the simulation is stopped
- random — whether the first row is random or centered

Keeping everything inside one state makes the program predictable and easy to debug.

⸻

## 4. Rule System

A rule number (0–255) defines how each cell behaves based on its neighbors.

rule = 64
rule_map = {}

The lookup table is built like this:

function make_rule()
  rule_map = {}
  for n = 0, 7 do
    local bit = math.floor(rule / (2 ^ n)) % 2
    rule_map[n] = bit
  end
end

Each pattern (111, 110, 101, …) is encoded as a number 0–7,
so the rule becomes a tiny dictionary.

⸻

## 5. Drawing Helpers

Each cell is drawn by the Pixel function:

function Pixel(x, y)
  gfx.rectangle(
    "fill",
    (x - 1) * PIX,
    (y - 1) * PIX + GRID_OFFSET_Y,
    PIX, PIX
  )
end

The displacement by GRID_OFFSET_Y keeps the HUD area clear.

⸻

## 6. Seeding & Resetting

The first row is created either:
	•	as one bright pixel in the center, or
	•	as random noise, if the user toggles it.

function seed_row()
  for x = 1, WIDTH do
    if State.random then
      State.grid[1][x] = math.random(0, 1)
    else
      State.grid[1][x] = 0
    end
  end
  if not State.random then
    local center = math.floor(WIDTH / 2)
    State.grid[1][center] = 1
  end
  State.row = 1
end

Resetting simply rebuilds the rule and clears the world:

function init()
  make_rule()
  clear_grid()
  seed_row()
  State.paused = false
end


⸻

## 7. Simulation Step

Each new row is computed from the previous one:

function step()
  if State.row >= HEIGHT then return end
  local row = State.row
  local nxt = row + 1

  for x = 1, WIDTH do
    local l = State.grid[row][x - 1] or 0
    local c = State.grid[row][x]     or 0
    local r = State.grid[row][x + 1] or 0
    local code = l * 4 + c * 2 + r
    State.grid[nxt][x] = rule_map[code]
  end

  State.row = nxt
end

Left, center, and right neighbors form a 3-bit code.
The rule decides the next value.

This is the heart of the automaton.

⸻

## 8. Drawing the Universe

function draw_grid()
  for y = 1, HEIGHT do
    for x = 1, WIDTH do
      local v = State.grid[y][x]
      gfx.setColor((v == 1) and COLOR_ON or COLOR_OFF)
      Pixel(x, y)
    end
  end
end

HUD (status text) appears at the top:

gfx.print("Rule: " .. rule, 4, 4)
gfx.print("Row: " .. State.row, 4, 16)

Controls are shown at the bottom:

gfx.print("SPACE: pause  R: reset  N: step", 4, y)
gfx.print("UP/DOWN: rule  S: seed  1-9: presets", 4, y+12)


⸻

## 9. Update Loop

The simulation advances automatically unless paused:

function love.update()
  if not State.paused then
    step()
  end
end


⸻

## 10. Input and Control

Input is handled “2048-style” —
a clean table of actions instead of a long if-chain.

KeyPress.space = key_toggle_pause
KeyPress.r     = key_reset
KeyPress.up    = key_rule_up
KeyPress.down  = key_rule_down
KeyPress.s     = key_toggle_seed
KeyPress.n     = key_step_once

Preset rules 1–9 are handled separately:

function apply_preset_rule(key)
  local preset = RULE_PRESET[key]
  if preset then
    rule = preset
    init()
  end
end

Final dispatcher:

function love.keypressed(key)
  local handler = KeyPress[key]
  if handler then handler(); return end
  apply_preset_rule(key)
end

This makes adding new commands trivial.

⸻

## 11. What to Try Next
- Experiment with Rule 30 or Rule 110
- Change PIX to zoom in/out
- Switch between center seed and random seed
- Add wrap-around edges
- Turn this into a 2D cellular automaton
- Combine multiple rules on the same screen
- Add colors depending on pattern history

This lab is meant to encourage creativity:
simple rules → surprising behavior.



