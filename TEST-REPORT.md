# TEST REPORT — walker-ninja-firefighter-joe asset slice

- **Engine:** Godot 4.7.2.stable.official (ed1daf0bf), GL Compatibility renderer
- **OS:** macOS (Darwin 25.6.0)
- **How to run the automated tests** (from `godot/`): `godot --headless --path . -s tests/test_game.gd` and `godot --headless --path . -s tests/test_keyboard.gd`
- Each test below names the source revision it ran on. Results are recorded as they happened, newest last.

## Checks required by the assignment

| Check | Status |
|---|---|
| Startup and controls (fresh copy) | pending |
| Character against the sheet (in-engine screenshot per state) | pending (step 2 adds the remaining states) |
| Storyboard against the slice | pending |
| Sound events: exactly one sound per occurrence | pending (sound not added yet) |
| Music loop and pause/end behavior | pending |
| Muted play | pending |
| Automated check added by me | pending (planned: sound-trigger count per event) |
| Inspect-and-revise cycle | **Playtest 1 below** |

---

## 2026-10-06 — baseline before any change

- **Revision:** commit `aa3f938` (Assignment 1 game code, no generated art in the game yet).
- **Automated:** `test_game.gd` **41 checks / 0 failures**; `test_keyboard.gd` all PASS.
- **Known pre-existing issue:** `tests/capture_game.gd` (screenshot script) fails with "Input route did not complete" **on the unchanged code too**: its 900-tick limit is shorter than the route now that the route waits about 4 s for the hose. Not caused by the art change; to fix in step 2.

## 2026-10-06 — step 1: generated character in the game (movement states)

- **Revision:** uncommitted working tree on top of `aa3f938`. Changes: `player.gd` swaps one generated image per state (idle, run, jump crouch, rising, falling, landing), character 64 px tall in the 640×360 game (128 px in the 1280×720 window), collision box 20×40 (was 18×28); `session.gd` blocking-fire touch check uses the new box.
- **Automated:** `test_game.gd` **41 checks / 0 failures**, including `complete-real-route` (full scripted route, no deaths, both survivors rescued) and `route-beats-timer`; `test_keyboard.gd` all PASS. So the bigger box did not break the level's jumps.

### Playtest 1 (human: me, keyboard, no sound yet)

What I saw, in my words, and what it means:

| # | Observation | Cause (found by Claude) | Planned fix (step 2) |
|---|---|---|---|
| 1 | The intro text "Save the person + dog…" is hidden behind the character at the start. | The text was placed for the old 32 px character; he is now 64 px tall. | Move the intro text above his head. |
| 2 | "The fire got you" appears, but nothing happens to him. | The burned pose isn't wired yet; he stays in the run pose. | Burned pose on death, respawn stance after the retry. |
| 3 | Too many poses in one short jump (crane → kick → meditating fall). | Step 1 showed jump crouch for 4 frames, rising while going up, falling while going down. | Jump = flying kick the whole jump → landing pose on touchdown. Crane stays on the sheet only; the meditating fall is used only when he walks off a ledge. |
| 4 | The run pose looks fine; the kick is fine. | — | Keep. |
| 5 | Hosing looks like he's peeing on the fire. | The hose pose isn't wired yet (he's in idle), and the water still starts at the old character's hand height (16 px up), which is now his crotch. | Hose pose while the water pours; water starts at the hose art's nozzle tip. |
| 6 | The rescue bag is in a weird place (low, near his knees). | The A1 bag drawing was doubled in size but not moved for the taller art. | Move it up to his back, positioned per pose. |
| 7 | No grab, no toss into the air, no fall into the bag. | Not built yet (step 2). | Grab pose → toss pose; the code-drawn survivor flies up and drops into the bag (visual only; the rescue still counts on touch). |

**Size, box, colors:** not judged separately yet; I'll judge them again after step 2.

## 2026-10-06 — step 2: action poses, rescue toss, hose nozzle, bag (fixes from Playtest 1)

- **Revision:** commit "Add action poses, slower run, and ENV-BG backdrop; verify 41/41 tests" (this push).
- **Changes:** jump = flying kick until touchdown, then landing (crane crouch kept on the sheet only; meditating fall only when walking off a ledge); hose pose while water pours, water starts at the art's nozzle tip; burned pose on fire death, respawn stance after the retry; grab → toss poses with a code-drawn survivor flung up and dropped into the bag (visual only); bag positioned per pose and hidden until the first rescue; intro text moved above his head; "Rescue complete" card delayed 1.25 s so the bow is visible (found by Claude in a screenshot: the card covered him).
- **Automated:** `test_game.gd` 41/41, `test_keyboard.gd` all PASS.
- **Screenshot script** (`tests/capture_game.gd`): limit raised from 900 to 3000 ticks (as in `test_game.gd`) so the route can finish with the hose wait; now saves the first real occurrence of every state image. All 11 used states captured; route completes with 0 deaths.

### Playtest 2 (human: me) and the changes it caused

| Observation | Cause | Change |
|---|---|---|
| Movement and pose changes feel like "too much"; slower would make the poses clearer. | Run speed 160 px/s; landing pose held only 8 ticks (0.13 s). | Run speed 160 → **120**; landing hold 8 → **20** ticks. |
| I never saw the burned pose. | It did show (screenshot), but only for 0.55 s, and the sooty art is dark and subtle at game size (predicted failure **F3**). | Fire deaths hold the burned pose **0.9 s** before the retry (still under the 1 s retry limit tested by `twenty-retries`). |
| The jump still went to the meditating fall instead of landing. | A probe of the pose sequence showed kick → landing → run, as designed; the landing was too short to notice. | Covered by the longer landing hold. |
| The toss is nice and funny. | — | Keep. |

**Consequence of the slower run (automated):** at speed 120 the burning-street jump became impossible: `flame-clearance-positive` failed (street −13.9 px), and the route died in the fire. Claude tested options against the suite:

| Option | Result |
|---|---|
| speed 140, gravity 960 | street clearance −3.5 px (fail) |
| **speed 120, gravity 800** (chosen, option A) | full route passes; only the jump-height check changed |
| speed 120, gravity 720 | route passes; jump 74 px |

**My decision:** option A. A floatier jump (64 px designed rise, 0.8 s in the air) also keeps the kick on screen longer.

**Test changes, each a design change, not a weakened check:**
- `speed-cap`: expects 120 (was 160).
- `fixed-jump-and-no-double`: expects the designed rise 320²/(2·800) = 64 px (was 53.3).
- `respawn`: waits 58 ticks instead of 38, because fire deaths now hold 0.9 s. The real retry limit (`twenty-retries`, ≤ 60 ticks) is unchanged and passes.
- `route_driver.gd`: presses W at x > 1204 instead of 1188. At speed 120 the scripted player lands short of 1188, outside the game's hose range (fire x − 50 = 1200), so the water never started. Input fixture only.

## 2026-10-06 — ENV-BG in the game

- **Change:** the generated skyline replaces the A1 cream sky, grid, and hills (fixed backdrop on its own layer).
- **Problem it caused (checked by Claude):** the backdrop's bottom (`#2c3547`) is almost the same color as the A1 ledges (`#25354a`), and the dark in-level text would disappear. I asked for the other game elements to stay visible.
- **Fix:** ledges redrawn as light concrete (`#b8b2a6`) with a dark outline; in-level text light with a dark outline; green/red labels brightened.
- **Result (screenshots):** ledges, text, flames, water, buildings, and survivors read; the red suit and yellow helmet read better on the blue-gray sky than on cream. **Still weak:** the burned pose (dark soot on a dark backdrop).
- **Automated:** 41/41, keyboard PASS. The screenshot route failed once, on the first run right after the new image was imported; three runs since then completed with 0 deaths. Cause not confirmed.
- **Still to do:** my playtest with the backdrop (Playtest 3).

