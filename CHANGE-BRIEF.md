# CHANGE-BRIEF — Assignment 6: jump puff and hose steam (particle effects)

> v1 · 2026-11-06 · written and committed before the first Claude Code prompt of this assignment and before any effect exists. Later revisions are added under **Revisions** with a date; the v1 text is not rewritten. The Assignment 5 brief is kept at tag `a5`.
>
> Game: **walker-ninja-firefighter-joe** (Extinguisho, a deadpan ninja firefighter; 2D, Godot 4.7.2, GL Compatibility, 640 × 360 viewport shown at 1280 × 720). Both effects are 2D and appear in the game itself.
>
> How this brief was written: I chose both effects, their jobs, the node types, the layers and the pause behaviour. Claude Code read my game's code, measured the background art, checked every property name below against Godot 4.7.2 with a headless probe, and typed sections A and B from my decisions; I reviewed them. Sections P (predicted failures), C (price and budget) and Q (short answers) are mine, in my own words.

## What limits the choices (facts from my project)

- **Renderer: GL Compatibility** (`godot/project.godot`). Godot's renderer comparison lists particle trails and 2D particle SDF collision as unsupported there, so neither effect uses them. I am not switching renderer, because that would change how my A5 shaders look.
- **Visual Profiler:** the Godot docs say it is not supported with the Compatibility renderer on macOS. The GPU price is therefore taken by running the game once with a command-line renderer override to Mobile (Metal), and the report says it measured a different renderer from the one the game ships with.
- **The game's pause is not a tree pause.** `session.gd` `set_paused()` changes `state` and disables the player; it never sets `get_tree().paused`. Esc therefore stops the game clock (`water_ticks`, `extinguish_ticks`) but not `_process` or particle simulation.
- **Jump timing** (`godot/features/player/tuning.gd`): `jump_velocity` −320, `gravity` 800, so a jump on flat ground is 0.8 s in the air, and a jump onto a ledge 40 px higher lands after about 0.65 s. With the 6-tick jump buffer the next jump can start on the landing tick.
- **Background value, measured** (relative luminance from the sRGB values, 0 = black, 1 = white; `env_bg.png` resized to the 640 × 360 viewport): tan building wall with its fire tint 0.55; ledge 0.45; sky behind the blocking fire 0.46 on average (0.25–0.69); lightest sky block 0.66; darkest skyline block 0.10 (lower left, street level). Contrast ratios below use the WCAG formula `(L1 + 0.05) / (L2 + 0.05)`.

---

## Effect A — jump puff

### A1. The job

- **What it tells the player:** "your jump registered, and this is where you left the ground." It is a ninja's vanishing puff at his feet. The jump sound already confirms the press; the puff adds the place, which matters on the short rooftop ledges where a missed take-off means a fall.
- **Event:** the `jumped` signal on `godot/features/player/player.gd`, emitted once per real jump inside `_physics_process` (after `velocity.y = tuning.jump_velocity`, before `move_and_slide()`). Position: the player's `global_position` at that emit, which is his feet (the collision box's bottom centre is the origin).
- **It repeats:** about 13 jumps on a clean run (`test_audio` route log), more on a messy one.

### A2. Intent

- **Timing phases:** frame one is the strongest (a white flash disc and a tight cluster of puff balls at his feet). Outward phase, 0–0.2 s: the puff spreads sideways and a little upward, the dark specks kick up. Dissipation, 0.2–0.9 s: the puff stops spreading, grows, greys and fades; specks fall and are gone by 0.45 s. Faint by 0.6 s, gone by 0.9 s.
- **Contrast against the real background:** the jump happens in front of the tan walls (0.55), the ledges (0.45), the sky, and the dark street-level skyline (0.10). No single value reads on all of them: white puff (0.91) is 6.5 : 1 on the dark skyline but only 1.6 : 1 on the wall; dark ink specks (`#25354a`, 0.03) are 7.1 : 1 on the wall and 8.4 : 1 on the light sky but 1.8 : 1 on the dark skyline. So the effect is two values on purpose: the white layers carry it on dark art, the dark specks carry it on light art.
- **Scale against the character:** his collision box is 20 × 40 game px (40 × 80 window px). The puff is about 1.5–2× his width (30–40 game px across) and stays below his knees; specks rise no more than half his height.
- **Change over life:** puff balls grow (0.6× → 1.3×), go from near-white to blue-grey, and fade from 0.95 to 0 alpha; the flash shrinks and fades in 0.12 s; specks keep their colour and fade out.
- **Variation:** random speed, direction within the spread, size, rotation and spin, a ±0.02 hue shift, and 20–25 % lifetime randomness, so two puffs never look stamped.
- **Layers (three emitters under one root):**
  - `Flash` — one white disc, the strong first frame.
  - `Puff` — ten soft balls, the body of the effect.
  - `Specks` — six dark dust bits, the value contrast on light walls and sky.

### A3. Settings

**Node type: `CPUParticles2D` for all three emitters, under a `Node2D` root.** Why: the puff needs only basic emission, velocity, damping, gravity and curves, which CPU nodes have, and pricing one CPU effect next to one GPU effect (B) shows what each instrument measures. Scene file: `godot/effects/jump_puff.tscn` (root `JumpPuff`, children `Flash`, `Puff`, `Specks`).

| Setting | `Flash` | `Puff` | `Specks` |
|---|---|---|---|
| `amount` | 1 | 10 | 6 |
| `one_shot` | true | true | true |
| `explosiveness` | 1.0 | 1.0 | 1.0 |
| `lifetime` | 0.12 | 0.9 | 0.45 |
| `lifetime_randomness` | 0.0 | 0.2 | 0.25 |
| `emission_shape` | point (0) | sphere (1), `emission_sphere_radius` 3.0 | sphere (1), `emission_sphere_radius` 4.0 |
| `direction` | — | (0, −1) | (0, −1) |
| `spread` | — | 80.0 | 60.0 |
| `initial_velocity_min` / `_max` | 0 / 0 | 50 / 90 | 80 / 150 |
| `gravity` | (0, 0) | (0, −20) | (0, 600) |
| `damping_min` / `_max` | 0 / 0 | 250 / 300 | 0 / 0 |
| `angle_min` / `_max` | 0 / 0 | 0 / 360 | 0 / 0 |
| `angular_velocity_min` / `_max` | 0 / 0 | −90 / 90 | 0 / 0 |
| `scale_amount_min` / `_max` | 0.6 / 0.6 | 0.35 / 0.55 | 0.08 / 0.14 |
| `scale_amount_curve` | 1.0 → 0.3 | 0.6 at 0, 1.0 at 0.3, 1.3 at 1.0 | none |
| `color_ramp` | white α 0.9 → white α 0 | (0.97, 0.96, 0.94, 0.95) at 0 → (0.85, 0.85, 0.88, 0.7) at 0.35 → (0.60, 0.62, 0.68, 0) at 1 | `#25354a` α 1 → α 0 |
| `hue_variation_min` / `_max` | 0 / 0 | −0.02 / 0.02 | 0 / 0 |
| `local_coords` | false | false | false |

- **Damping check:** at 50–90 px/s and 250–300 px/s² the balls travel 4–16 px and stop within 0.17–0.36 s, which is the outward phase.
- **Draw:** every emitter uses one `GradientTexture2D` defined in the scene file: 32 × 32, `fill` radial, `fill_from` (0.5, 0.5), `fill_to` (1.0, 0.5) so the disc reaches transparent at the edge (not the corners), gradient white α 1 → white α 0. No draw material: default mix blend. Mix, not additive, because additive only brightens and most of the background is already light. No image asset, so nothing to license; the texture's definition is committed in the scene.
- **`local_coords` false, and why:** the puff belongs to the place he jumped from. Its root is added to the level node, not to the player, so it would stay put either way; false keeps particles in world space even if a future change parents it to something that moves.
- **No `visibility_rect`** (CPU nodes don't have one). **No `preprocess`** (0): a puff must never exist before a jump.
- **Preview only:** the preview scene sets `use_fixed_seed = true` and a `seed` on its own instance; the effect scene never does.

### A4. Observable rules

| # | Rule |
|---|---|
| A-R1 | Every `jumped` emission creates one new `JumpPuff` whose root `global_position` equals the player's `global_position` at that emit. |
| A-R2 | Never otherwise: not on scene load, not on start or R, not on landing, not when walking off a ledge, not while the game is in MENU, PAUSED, DYING or COMPLETE (no jump can happen there). |
| A-R3 | **Retrigger rule: overlap.** A second jump while an earlier puff is alive adds a second, full puff; the first is not cut off or restarted. In play at most **2** are alive at once (puff life ≤ 0.9 s; fastest jump-to-jump about 0.65 s). Tested with two jumps inside 0.9 s. |
| A-R4 | A puff stays where it was made: moving the player afterwards does not move it. |
| A-R5 | Each `JumpPuff` frees itself when all three emitters have finished, within 0.9 s plus one frame of its jump. |
| A-R6 | **Freed parent:** the puff's parent is the level node (`session.gd`'s `WalkerJumpman`), which lives for the whole session. The player is never freed (`restart_attempt()` teleports him), so nothing the puff could follow is freed on a jump. A puff alive during R finishes where it is. |
| A-R7 | Tree paused (`get_tree().paused = true`): puffs in flight freeze in place and stay drawn. Game pause (Esc): no new jumps; puffs in flight finish. |

### A5. Frame strip (fixture)

- **Preview scene:** `godot/previews/jump_puff_preview.tscn`, at in-game camera scale over the real level art of building B1's rooftop: the ledge at x 1060–1150, y 280, with the tan wall behind and sky above (the hardest background for the white layers). The puff is triggered at (1105, 280).
- **Trigger at frame 10**; with the retrigger export on, again at **frame 25** (0.5 s later, inside one lifetime).
- **Capture:** 30 fps. Frames to read and what each should show:

| Frame | Time after trigger | Should show |
|---|---|---|
| 10 | 0 | flash disc ~20 px, bright white; puff balls in a tight cluster at the feet; specks at the feet |
| 12 | 0.067 s | flash about half faded; puff widening (~20 px across); specks rising |
| 15 | 0.167 s | flash gone; puff near its widest (~30–40 px), still bright; specks near their peak |
| 20 | 0.333 s | puff no longer spreading, balls larger and greyer, about 60 % opacity; specks falling or gone |
| 30 | 0.667 s | faint blue-grey wisps only |
| 50 | 1.333 s | nothing |

---

## Effect B — hose steam

### B1. The job

- **Job: a feedback loop that follows a game value.** While the water is on, steam rises where it meets the fire, and the amount follows how much fire is left: thick when the water first hits, thinning as the flames shrink, none once the fire is out.
- **What it tells the player:** "the water is working; keep holding position." The flames already shrink, but the steam makes the four seconds of standing still read as progress, at the fire, where the player is looking.
- **Condition:** `player.hosing` on `godot/features/player/player.gd`, written every physics tick by `godot/game/session.gd` `_physics_process` as `water_ticks > 0` (300 ticks after a W press in range of the blocking fire).
- **Game value:** `session.fire_height()` (`godot/game/session.gd`), the blocking fire's current height in px: 34 (`level.blocking_fire[3]`) when hosing starts, falling linearly to 0 over `EXTINGUISH_TICKS` = 240 ticks (4.0 s), then 0 while the water lingers for the last 60 ticks (1.0 s).
- **Feature Effect A doesn't use:** `amount_ratio` driven by a game value; turbulence; a box-shaped emission area across the fire's width. (Also GPU particles and a `visibility_rect`.)

### B2. Intent

- **Timing phases:** start — first wisps within a frame or two of the first W frame, building to a full column over about half a second (no burst, no pop). Steady — the thickest column in the first second, then thinning in step with the flames (about half by 2 s, a trickle by 3.5 s). End — no new steam after the fire goes out at 4 s; the last steam rises and fades over its 1.4–1.6 s life. Emitting stops when the water stops at 5 s.
- **Contrast against the real background:** the steam starts in front of the tan wall (0.55) and rises into the sky behind the blocking fire (0.46 average, 0.69 lightest). White steam (0.89) is only 1.8 : 1 on that sky (1.3 : 1 on its lightest part) and 6.4 : 1 on the dark smoke clouds. So a darker `Haze` layer (grey 0.16) sits under it: 2.5 : 1 on the average sky, 3.6 : 1 on the lightest, 2.9 : 1 on the wall. Alpha below 1 lowers all of these; my eyes in the running game decide.
- **Scale against the character:** the column is as wide as the fire (56 px) at its base, spreading to about 90 px, and rises about 50 px above the flames, a little more than his height (40 px).
- **Change over life:** steam fades in fast (α 0 → 0.8 by 15 % of its life, so particles don't pop on), holds, then fades out; it grows 0.6× → 1.6× as it rises and cools. Haze fades in to α 0.5 and out, growing 0.6× → 1.8×.
- **Variation:** turbulence curls each puff differently; random size and rotation; emission randomness 0.3.
- **Layers (two emitters under one root):**
  - `Haze` — fewer, larger, darker grey puffs, drawn first (underneath): the value contrast against the pale sky.
  - `Steam` — white puffs, drawn on top: the steam itself.

### B3. Settings

**Node type: `GPUParticles2D` for both emitters, under a `Node2D` root.** Why: `amount_ratio` and turbulence exist only on GPU nodes in 4.7.2 (checked: `CPUParticles2D` has no `amount_ratio`). Scene file: `godot/effects/hose_steam.tscn` (root `HoseSteam`, children `Haze`, `Steam`).

| Node setting | `Haze` | `Steam` |
|---|---|---|
| `amount` (fixed, never changed at runtime) | 14 | 40 |
| `amount_ratio` (scene default; the driver writes it) | 1.0 | 1.0 |
| `emitting` (scene default) | false | false |
| `one_shot` | false | false |
| `explosiveness` | 0.0 | 0.0 |
| `randomness` | 0.3 | 0.3 |
| `lifetime` | 1.6 | 1.4 |
| `preprocess` | 0.0 | 0.0 |
| `fixed_fps` / `interpolate` | 30 / true (defaults) | 30 / true (defaults) |
| `local_coords` | false | false |
| `visibility_rect` | Rect2(−70, −100, 140, 120), set by hand | same |

| `ParticleProcessMaterial` setting | `Haze` | `Steam` |
|---|---|---|
| `emission_shape` | box (3), `emission_box_extents` (20, 3, 0) | box (3), `emission_box_extents` (24, 3, 0) |
| `direction` / `spread` | (0, −1, 0) / 15 | (0, −1, 0) / 25 |
| `initial_velocity_min` / `_max` | 12 / 25 | 20 / 40 |
| `gravity` | (0, −10, 0) | (0, −15, 0) |
| `damping_min` / `_max` | 1 / 3 | 2 / 6 |
| `turbulence_enabled` | true | true |
| `turbulence_influence_min` / `_max` | 0.03 / 0.08 | 0.05 / 0.15 |
| `angle_min` / `_max` | 0 / 360 | 0 / 360 |
| `scale_min` / `_max` | 0.6 / 0.8 | 0.4 / 0.6 |
| `scale_curve` | 0.6 → 1.8 | 0.6 → 1.6 |
| `color_ramp` | grey (0.42, 0.43, 0.47): α 0 at 0, 0.5 at 0.2, 0 at 1 | white (0.95, 0.95, 0.97): α 0 at 0, 0.8 at 0.15, 0.5 at 0.6, 0 at 1 |
| `particle_flag_disable_z` | true | true |

- **Draw:** each emitter uses a `GradientTexture2D` defined in the scene file, the same recipe as Effect A (32 × 32, radial, `fill_from` (0.5, 0.5), `fill_to` (1.0, 0.5), white α 1 → α 0). No draw material: default mix blend, for the same reason as A. No image asset.
- **Position:** the root sits at the top centre of the blocking fire, (1278, 240 − `fire_height()`), and moves down as the flames shrink. `local_coords` false, so steam already released stays in the air while the emitter moves.
- **`visibility_rect`:** set by hand, not generated. Steam rises at most about 50 px in 1.4 s and the emitter can move 34 px down after releasing it, so the rectangle reaches 100 px up and 70 px to each side. Checked by eye with the fire at the screen edge.
- **`preprocess` 0, on purpose:** this effect must not exist before the first W of an attempt, so nothing should already be running when the scene loads.
- **Preview only:** the preview scene sets `use_fixed_seed = true` and a `seed` on its own instances; the effect scene never does.

### B4. Observable rules

| # | Rule |
|---|---|
| B-R1 | **Start:** both emitters' `emitting` becomes true on the first frame `player.hosing` is true, never before (not on scene load, start, R or before the first W). |
| B-R2 | **Stop:** `emitting` becomes false on the first frame `player.hosing` is false. Steam already in the air finishes its life; it is not cleared. |
| B-R3 | **The loop:** while hosing, `amount_ratio` on both emitters = `fire_height() / 34`, clamped to 0–1, updated every frame: 1.0 at the first hosing frame, 0.5 after 2.0 s, 0.0 from 4.0 s. `amount` never changes (14 and 40). |
| B-R4 | The root's position is (1278, 240 − `fire_height()`) while hosing. |
| B-R5 | **Tree paused** (`get_tree().paused = true`): the session stops counting, so `hosing` and `fire_height()` hold; the particles freeze in place and stay drawn. **Game pause (Esc):** the session stops counting, so `amount_ratio` holds its value, but the steam keeps drifting and emitting at that strength, because Esc doesn't pause the tree (the same as my A5 glow, A5 Revision 4). |
| B-R6 | **Hidden** (`visible = false` on the root): the driver ignores visibility and keeps writing `emitting` and `amount_ratio` from the game; nothing is drawn. |
| B-R7 | **R during hosing:** `restart_attempt()` sets `water_ticks = 0`, so `emitting` goes false on the next frame. **Fire death during hosing:** the session only updates `player.hosing` while PLAYING, so it stays true through the 2.0 s DYING hold and the steam keeps going at the frozen strength until the restart. |

### B5. Frame strip (fixture)

- **Preview scene:** `godot/previews/hose_steam_preview.tscn`, at in-game camera scale over the real level art around the blocking fire: building B1's roof with the fire at x 1250–1306, the tan wall behind its base and the sky above, camera where the game puts it while hosing (player at about x 1215, camera x 1315).
- **Condition starts at frame 10** (a W press in range), the fire is out at frame 130 (4.0 s at 30 fps), the condition ends at frame 160 (5.0 s).
- **Capture:** 30 fps, `--quit-after 210`. Frames to read and what each should show:

| Frame | Fire strength | Should show |
|---|---|---|
| 10 | 1.0 | condition starts; no steam yet, or the first one or two wisps at the flame tops |
| 16 | 0.95 | first wisps rising, a thin start, no burst |
| 40 | 0.75 | the full column: white steam over a darker haze, about 50 px tall |
| 70 | 0.5 | a visibly thinner column; flames half their height |
| 100 | 0.25 | a trickle |
| 130 | 0.0 | fire out; no new steam; the last steam high up and fading |
| 165 | 0.0 | condition ended; at most a few faint wisps |
| 200 | 0.0 | nothing |

---

## Boundaries

Collision, movement, input, the state machine and its timings (`EXTINGUISH_TICKS`, the +60 water linger, `FIRE_DEATH_HOLD`), `godot/game/session.gd`'s game logic, `godot/features/player/tuning.gd`, `godot/levels/first_steps.json`, the existing tests and their expectations, my Assignment 5 shaders in `godot/shaders/` and their driver, the HUD, the fires, the survivors, the background and every other object stay unchanged. Presentation code may read game state (`player.jumped`, `player.hosing`, `session.fire_height()`, `session.level`); it never writes it. `project.godot` rendering settings stay as they are.

## Evidence split

| Rule | Checked by | How |
|---|---|---|
| A3 / B3 settings | headless | configuration tests read every setting above back from the loaded scene files |
| A-R1, A-R2 | headless | state test drives jumps through real input; counts `JumpPuff` instances and compares their position with the player's at the jump tick; none after load, start, R, landing or a walk-off |
| A-R3 | headless + strip | two real jumps inside 0.9 s → two live puffs, the first not restarted; retrigger strip shows two puffs |
| A-R4, A-R5 | headless | puff position unchanged after the player moves; instance count back to 0 within 0.9 s plus one frame |
| A-R6, A-R7 | headless (state) + eyes | R mid-puff, tree pause; the frozen look is an eye check |
| A looks like a puff, reads on wall and skyline | strip + eyes | A5 strip; my verdict in the running game at 1280 × 720 over the B1 wall and the street-level skyline |
| B-R1 to B-R4, B-R7 | headless | state test drives W and R through real input; reads `emitting`, `amount_ratio`, `amount` and position at two or more fire strengths |
| B-R5, B-R6 | headless (state) + eyes | tree pause, Esc, `visible = false`; what is drawn is an eye check |
| B looks like steam, thins with the fire, reads on the sky | strip + eyes | B5 strip; my verdict in the running game |
| No pop at the screen edge | eyes | walk so the blocking fire sits at the left and right edges while hosing |
| No steam on scene load | headless + eyes | `emitting` false and `preprocess` 0 after load; first frames after load by eye |

---

## P. Predicted failures (mine)

_I picked these three from the assignment's "Failures worth predicting" list and matched each one to the check I think catches it. Claude typed the descriptions from my picks._

1. **Godot 3 property name (Effect A).** The agent writes `initial_velocity` instead of `initial_velocity_min` / `initial_velocity_max`. Godot ignores the unknown name, the speed stays at its default 0, and the puff fires as a blob that never spreads. **Caught by:** the configuration test, which reads `initial_velocity_min` back from the scene file and expects 50.
2. **Puff glued to the player (Effect A).** The puff is added as a child of Extinguisho instead of the level, so it flies up with him instead of staying where he jumped. **Caught by:** the state test, which makes him jump and move and checks that the puff's position did not change.
3. **Steam before the hose (Effect B).** `preprocess` is set or `emitting` starts true, so steam is already rising when the level loads, before any W. **Caught by:** my eyes on the first frames after the scene loads.

## C. Price predictions and budget (mine)

_My guesses, made before anything is built; Claude gave me the reference numbers (the course chapter measured `CPUParticles2D` at about 0.035 ms per 1,000 particles headless on an M4 Pro, and `GPUParticles2D` at the same cost as an empty scene) and the peak counts from the settings above (Effect A: 17 particles per puff, 2 puffs at most, so 34; Effect B: 54 at `amount_ratio` 1.0). A frame at 60 fps is 16.7 ms. Measured on my Apple M1._

| | Effect A (CPU) | Effect B (GPU) |
|---|---|---|
| Peak particle count | 34 | 54 |
| Predicted headless CPU price | about 0: too small to tell apart from the empty-scene control | about 0, the same as an empty scene |
| Predicted GPU time | 0.05–0.5 ms | under 0.05 ms |
| Budget | 0.1 ms | 0.5 ms |
| Compared on | both prices (a CPU node) | GPU time only (a GPU node's headless price is near zero by construction) |

## Q. Short answers (mine)

_My answers, in my words. Claude gave me the fact each question needs before I answered._

1. Which node type does each effect use, and which features in this brief does it lack?
   The puff uses a CPU particle node, while the steam uses a GPU particle node. CPU particles don't have settings like amount_ratio, turbulence, or visibility_rect. GPU particles can't use trails or collision with the Compatibility renderer. The puff doesn't really need those extra settings since it's just a small jump effect. The steam also doesn't need trails or collision because it's just a visual effect.
2. With `local_coords` as set, what does Effect A do if its parent moves after the event?
   The puff's parent is the level, not Extinguisho. Since local_coords is turned off, the particles stay where they were created in the world. So if the parent moves sideways, the puff won't move with it.
3. Under the retrigger rule, how many Effect A bursts can be alive at once, and what peak particle count does that give?
   Each puff lasts around 0.9 seconds, and Extinguisho can jump again after about 0.65 seconds. So at most 2 puffs can overlap at once. Since each puff has 17 particles, that's 34 particles total.
4. What will a headless run report as the cost of a GPU effect, and why? With vsync on, what would FPS read with the effect off and on?
   A headless run only measures CPU time, so the steam would show almost the same time as an empty scene, close to 0 but not exactly 0, because the GPU particles aren't actually running. FPS shows how smoothly the game runs. With vsync on, both steam on and off would show around 60 FPS if the effect doesn't slow the game down much.
5. What does Effect B show on the first frame after its scene loads, with `preprocess` and without it? While the tree is paused? While the node is hidden?
   When the level first loads, there's no steam because nobody is using the hose. If steam was enabled with preprocess, it would already look like it had been running for a while instead of slowly starting. When the game is paused, the steam particles freeze where they are. When the steam node is hidden, we can't see it, but the code can still update its settings.
6. Which settings in this brief belong to emission, which to process, and which to draw?
   - Emission: amount, lifetime, one_shot, explosiveness, emission_shape, amount_ratio
   - Process: initial_velocity, spread, gravity, damping, turbulence, colour ramp, scale curve
   - Draw: texture, blend mode

   Basically, emission controls when and how many particles appear, process controls how they move and change, and draw controls how they look.

---

## Revisions

### Revision 1 — 2026-11-07, Effect A draw order (decided when I approved the Step 3 plan)

- **What was missing:** v1 did not say whether the puff draws in front of or behind Extinguisho. The agent's plan added it last under `WalkerJumpman`, which draws it in front of him.
- **My decision:** the puff draws **behind Extinguisho** and in front of the level art. He stays fully visible at take-off and the puff blooms behind his feet. It stays a child of the level node (A-R6 unchanged), placed just before the player in `WalkerJumpman`'s child order. Not by `z_index`: a negative `z_index` would put it behind the level's own `_draw()` (the buildings), where it would be hidden.
- **New rule A-R8:** every puff's index under `WalkerJumpman` is lower than the player's. Checked by the state test; the look is an eye check.
- The v1 text above is kept as written.

### Revision 2 — 2026-11-07, Effect A fires on the landing, not the jump (from my playtest)

- **What I saw:** in the running game the puff on every jump worked, but a puff at take-off did not make sense to me; at the landing it does (a6/TUNING.md, 2026-11-07).
- **The job now:** "you touched down, and here." The puff is the dust of a ninja's landing. It still marks a place and still repeats many times a run.
- **The event now:** a new signal `landed` on `godot/features/player/player.gd`, emitted in `_update_pose()` on the tick it sets `land_ticks = LAND_TICKS`: he is on the floor after more than 10 physics ticks in the air. That is the game's own rule for the landing pose, so the puff and the pose always agree. Position: the player's `global_position` at that emit (his feet, on the floor, after `move_and_slide()`). `reset_at()` sets `was_on_floor = true` and `air_ticks = 0`, so a respawn never counts as a landing.
- **Boundary, widened by my decision:** `player.gd` gains `signal landed` and one `landed.emit()` line next to `land_ticks = LAND_TICKS`. Movement, collision, poses and their timing do not change; the line only announces a state change the game already makes. The driver stops listening to `jumped`.
- **Rules that change:**
  - **A-R1 now reads:** every `landed` emission creates one new `JumpPuff` whose root `global_position` equals the player's `global_position` at that emit.
  - **A-R2 now reads:** never otherwise: not on the jump, not on scene load, start or R, not on a landing after 10 ticks or fewer in the air, not in MENU, PAUSED, DYING or COMPLETE. A landing after walking off a ledge **does** count when he was in the air more than 10 ticks (v1 said no puff on a walk-off; that was about the jump event).
  - **A-R3:** overlap, unchanged. Two landings inside 0.9 s happen in play: land, jump again on the landing tick, land 0.8 s later on flat ground or about 0.65 s later on a ledge 40 px higher. At most 2 alive.
  - A-R4 to A-R8 are unchanged.
- **Unchanged:** every setting in A3, the frame strip in A5 (the preview adds the puff itself, so its frame 10 is the landing), the names `jump_puff.tscn` / `JumpPuff` / `jump_puff_driver.gd` (renaming would touch every file and capture for no change in behaviour), predictions P and C, and the answers in Q.
- The v1 text above is kept as written.

### Revision 3 — 2026-11-07, Effect A tuning r1 kept: the puff greys as it fades

- **Setting:** `Puff` `color_ramp` middle stop (0.35) is now (0.62, 0.63, 0.68, α 0.7), was (0.85, 0.85, 0.88, α 0.7); end stop (1.0) is now (0.45, 0.47, 0.52, α 0), was (0.60, 0.62, 0.68, α 0). The start stop and every alpha are unchanged.
- **Why:** the r0 strip showed the puff fading into the tan wall from about 0.2 s (a6/TUNING.md r1). Kept after my check in the running game, where I saw little difference; the scene file and the configuration test carry the new values.
- The v1 text above is kept as written.

### Revision 4 — 2026-11-07, Effect A tuning r2 kept: a bigger puff

- **Setting:** `Puff` `scale_amount_min` / `scale_amount_max` are now 0.5 / 0.8, were 0.35 / 0.55.
- **Why:** the r1 strip showed the puff at about 25 game px at its widest, below the 30–40 px in A2; r2 reaches about 30 px and is denser (a6/TUNING.md r2). Kept after my check in the running game: "i like this one better it shows those extra dots as more granular dust". The scene file and the configuration test carry the new values.
- The v1 text above is kept as written.

### Revision 5 — 2026-11-07, Effect B draw order (decided by Claude under my delegation, to confirm in my feedback session)

- **What was missing:** v1 does not say where the steam draws relative to Extinguisho. As a child of `WalkerJumpman` it draws over the fire and the water stream either way, because those come from the level's own `_draw()`.
- **Decision:** the steam draws **behind Extinguisho**, placed just before the player in `WalkerJumpman`'s child order, the same way as Revision 1, so he and the hose nozzle stay fully visible. I had told Claude to "finish all" and give my feedback at the end; Claude chose this for consistency with my Revision 1 decision. I confirm or change it when I look at the steam in play.
- **New rule B-R8:** the steam root's index under `WalkerJumpman` is lower than the player's. Checked by the state test; the look is an eye check.
- The v1 text above is kept as written.

### Revision 6 — 2026-11-08, Effect B tuning r1 kept: a darker, more solid haze

- **Setting:** `Haze` `color_ramp` colour is now (0.30, 0.31, 0.35) at every stop, was (0.42, 0.43, 0.47); peak alpha at 0.2 of life is now 0.8, was 0.5. Start and end alpha stay 0.
- **Why:** my first look found the steam "not that noticeable, especially in the sky", and Claude's reading of r0 found the `Haze` layer invisible (a6/TUNING.md, Effect B r0 and r1). Kept after my check in the running game: "its better now". The scene file and the configuration test carry the new values. B2's contrast line now reads about 4 : 1 for the haze on the sky's average, on paper.
- The v1 text above is kept as written.

### Revision 7 — 2026-11-08, Revision 5 confirmed in play

- I checked the steam in the running game and confirmed Claude's Revision 5 choice (the steam draws behind Extinguisho) and the B-R5 game-pause behaviour (the steam keeps drifting under Esc): "all ok". Revision 5 is now my decision.
- The v1 text above is kept as written.

### Revision 8 — 2026-11-08, how sections A and B were made (a correction to the v1 header)

- The v1 header says Claude typed sections A and B from my decisions and "I reviewed them". What happened: I directed and decided every choice in them in chat (the effects, jobs, node types, layers, pause behaviour, and later every revision); Claude implemented them as text, with the measurements and the property-name checks. I did not read the v1 text line by line before it was committed. I checked the result by eye-testing and playing the game many times. Sections P, C and Q are my own answers, as the header says.
- The v1 text above is kept as written.

### Revision 9 — 2026-11-08, B-R5 under Esc: the steam keeps simulating, but the pause card hides it

- **What the film's capture showed:** during Esc the game draws its pause card over the play area, which covers the fire and the steam. The steam keeps simulating behind it, as B-R5 says and as `test_hose_steam_state.gd` `game-pause-holds` proves, but a player does not see it drift.
- **B-R5 (game pause) now reads:** under Esc the session stops counting, `amount_ratio` holds, and the steam keeps simulating at that strength behind the pause card; on resume it continues from there. No code change.
- The v1 text above is kept as written.

