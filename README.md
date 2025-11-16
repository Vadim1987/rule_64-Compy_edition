# 1D Cellular Automaton Lab (Rule 64)

This is a **teaching example** for Compy:  
a simple 1D cellular automaton with:

- live animation
- step-by-step mode
- rule presets
- center / random seed
- on-screen HUD with the current rule table

The base rule is **Rule 64**, but you can explore other rules interactively.

---

## What is a 1D Cellular Automaton?

We have:

- a single **row** of cells
- each cell is either **0** (black) or **1** (white)
- time goes in **steps** (generations)
- each new row is computed from the **row above**:
- each cell looks at **3 cells**: left, center, right
- that pattern (e.g. `110`) is mapped to a new value (0 or 1)
- the mapping is defined by a **rule number** from 0 to 255

Example for **Rule 64**:

```text
Rule 64 in binary: 01000000

Patterns (from 111 to 000):

111 -> 0
110 -> 1   <-- only this pattern gives 1
101 -> 0
100 -> 0
011 -> 0
010 -> 0
001 -> 0
000 -> 0

The program computes these mappings automatically and shows them on screen.

⸻

## Controls

When the program is running:
	-	SPACE – pause / resume
	-	N – single step (works only when paused)
	-	R – reset with the current rule
	-	UP – increase rule number (RULE = RULE + 1 mod 256)
	-	DOWN – decrease rule number (RULE = RULE - 1 mod 256)
	-	S – toggle seed mode:
	-	CENTER – single white cell in the middle
	-	RANDOM – noisy first row (random 0/1)
	-	1–9 – load rule presets:

Key	Rule
1	30
2	60
3	90
4	110
5	184
6	22
7	50
8	126
9	250



⸻

On-screen HUD

The HUD in the top-left corner shows:
	-	Rule: N – current rule number (0–255)
	-	Row: K – current generation (1..HEIGHT)
	-	State: RUNNING / PAUSED
	-	Seed: CENTER / RANDOM
	-	Short help with the main keys

On the top-right side you see the rule table:

Patterns:
111 -> x
110 -> x
...
000 -> x

This directly shows how the current rule interprets each 3-cell pattern.

⸻

Main Ideas in the Code

State

We keep all state in table S:

S = {
  row = 1,         -- current generation index
  grid = {},       -- 2D array: [y][x] = 0 or 1
  paused = false,  -- running or paused
  random = false   -- seed mode: false=center, true=random
}

We also track:
	-	RULE – current rule number
	-	RULEMAP – mapping from pattern code 0..7 to 0/1

Rule decoding

make_rule() converts the number RULE into a lookup table:

RULEMAP[n] = 0 or 1, where n = 0..7

Each n corresponds to a pattern:

n = 7 -> 111
n = 6 -> 110
...
n = 0 -> 000

Evolution

For each new row:
	-	we read the previous row row
	-	for each x we get l, c, r (left, center, right)
	-	we compute a code 0..7
	-	we set the new cell from RULEMAP[code]

This is all done in step().

Drawing
	-	draw_grid() draws black/white pixels for all cells
	-	draw_status() draws the text HUD (rule, row, state, seed, help)
	-	draw_rule_info() shows the rule table 111 -> 0 etc.

⸻

How to Use This as a Teaching Example

You can:
	1.	Start with Rule 64 and a center seed.
    2.	Switch to random seed (S) and compare:
	    -	how the same rule behaves with different starting conditions?
	3.	Try famous rules:
	    -	Rule 30 (chaotic)
	    -   Rule 90 (triangle patterns)
	    -	Rule 110 (complex, almost “life-like”)
	4.	Pause (SPACE), then step with N:
		-   let students watch how each line depends on the line above.
	5.	Look at the right rule table:
	    -   for a chosen rule, highlight which patterns give 1,
	    -	then show how that affects the overall shape.

