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
| Music loop and pause/end behavior | automated: pass (`music-behaviour`, `music-loops`); listened with the effects: fine (playtest 3) |
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

## 2026-10-07 — DEVASTATED pop-up and ENV-FIRE in the game

- **Why:** the critical review found *Failure is a punchline* weak in play (face invisible at 64 px, burned pose dark on the backdrop), and ENV-FIRE was in the asset list but not in the slice.
- **Changes:** on a fire death the HUD pops up the generated DEVASTATED portrait (CHAR-EXPR-02) in a tilted frame next to "The fire got you."; the code-drawn flames are replaced by ENV-FIRE (single flames on small hazards, the wide cluster on the street fire, the tall cluster on the blocking fire, shrinking as it's hosed). Hazard collision rectangles unchanged.
- **Automated:** `test_game.gd` 41/41 (including `flame-clearance-positive`), `test_keyboard.gd` PASS; screenshot route completes with 0 deaths.
- **Screenshots (Claude's check):** the flames read clearly on the backdrop and against the red suit (the dark outline separates them); the pop-up shows on the fire death (`evidence/screens-web/02-failure.jpg`).
- **Still to do:** my playtest of both (Playtest 3).

## 2026-10-07 — sound effects wired; automated sound check (added by us)

- **Changes:** six ElevenLabs sounds cleaned by `tools/make_audio.sh` (front/end silence trim, −14 LUFS, −1 dBFS peak limit, OGG) and played from the code that already represents each event (CHANGE-BRIEF revision "sounds wired"). Two buses: N mutes music, B mutes sound effects. Music behaviour coded; no music file yet.
- **Automated check we added:** `godot --headless --path . -s tests/test_audio.gd` (from `godot/`). Result: **8 checks, 0 failures** (run twice):

| Check | What it does | Observed |
|---|---|---|
| siren-once-on-start | new session | siren 1, nothing else |
| held-jump-one-sound | jump key held 1 s | 1 jump, 1 jump sound |
| rapid-jumps-match | five taps | 5 jumps, 5 jump sounds |
| burn-once-per-death | fire touch, then a duplicate death call | 1 death, 1 burn |
| no-burn-after-retry | after the retry | still 1 burn |
| route-one-sound-per-event | full scripted route | 13 jumps / 13 jump sounds, hose 1, rescue 2 (2 survivors), win 1, burn 0, siren 1 |
| w-mashing-one-hose | W pressed 30 ticks in a row while water pours | hose 1 |
| mute-changes-nothing | the same route with both buses muted | identical: COMPLETE, 1269 ticks, 0 deaths, 13 jumps, 2 rescued, same final position |

- **A failure we fixed honestly:** the first version of `mute-changes-nothing` **failed** (unmuted 1265 ticks vs muted 1268). Before touching it we ran the route four times **unmuted**: 1267, 1267, 1268, 1268. So the difference came from the test harness (it stepped by rendered frames, which hold one or two physics ticks), not from muting. The route now steps exactly one physics tick per input; four runs gave 1269 every time, and the check still requires an **exact** match. No tolerance was added.
- **Other suites:** `test_game.gd` 41/41; `test_keyboard.gd` all PASS.
- **Known warning:** at exit, `test_keyboard.gd` and `test_audio.gd` print "resources still in use / ObjectDB instances leaked" (the loaded sounds are still referenced when the test quits). It doesn't affect any result.
- **Not yet checked by a human:** whether each sound *sounds* right on its event (e.g. the rescue thump vs the toss on screen), mute keys in play, the siren on start, and the music (none yet). → Playtest 3.

## 2026-10-07 — Playtest 3 (human: me, with sound) and the changes it caused

| Observation | Cause | Change |
|---|---|---|
| The firefighter is hard to see against the background. | ENV-BG is dark with an orange glow band at his height; the red suit and dark soot blend into it (palette check: suit red vs the glow 1.1). | ENV-BG drawn darker, cooler and less saturated in code (`modulate` 0.58/0.60/0.70; the image file is unchanged), and a thin light outline (about 2 screen px, `outline.gdshader`) around every character image. State images got a 4 px transparent margin so the outline isn't clipped. |
| "The fire got you" disappears too fast. | Fire deaths retried after 0.9 s. | Fire deaths hold **2.0 s** (`FIRE_DEATH_HOLD`); **R** still retries at once. |
| After winning, the bow should get a big close-up like the fire death. | Only the fire death had a pop-up. | The bow close-up (cropped from pose 12b) pops up on COMPLETE, in the same tilted frame. |
| (Claude, from my screenshot) The menu card's line of text ran past the card's edges. | The line was wider than the card. | Shortened to "Save the person + dog, then out the fire escape." |

**Screenshots after the change** (`evidence/screens-web/`): the outline separates him from the sky, the glow, and the flames; both close-ups show.

**Test changes, each recorded as a design change:**
- `test_game.gd` `twenty-retries`: the limit changes from 60 ticks (1 s, A1) to 125 (the new 2.0 s hold + 5 ticks), because I chose a longer hold. The fast-retry promise now lives in R: `test_keyboard.gd` `r-skips-fire-wait` checks that R retries immediately during a fire death.
- `test_game.gd` `respawn` waits 125 ticks (was 58); `test_audio.gd` `no-burn-after-retry` waits 130 (was 60). Both failed for the right reason (still DYING) until the waits matched the new hold.

## 2026-10-07 — full automated suite (after playtest 3)

| Suite | Command (from `godot/`) | Result |
|---|---|---|
| A1 game mechanics | `godot --headless --path . -s tests/test_game.gd` | **41 / 41 pass** |
| Keyboard input (real key events) | `godot --headless --path . -s tests/test_keyboard.gd` | **14 / 14 pass**, including new: `n-mutes-music-only`, `b-mutes-sfx`, `n-b-unmute`, `no-jump-sound-while-paused`, `r-skips-fire-wait` |
| **Sound (added for Assignment 2)** | `godot --headless --path . -s tests/test_audio.gd` | **12 / 12 pass, 1 skipped** (two runs). New since the first version: `sound-after-state-change` (every sound plays in the state of its event), `siren-session-not-retry`, `no-burn-for-fall-or-timeout`, `missing-sounds-change-nothing` (all sound files removed → identical route, tick for tick). `music-behaviour` is **SKIPPED**, not passed, until `godot/audio/music_loop.ogg` exists. |
| Screenshots of every state | `godot --path . -s tests/capture_game.gd` | route completes, 0 deaths |

Still needed from a human: Playtest 3 with sound **on** (does each sound fit its moment?) and **muted** (N and B), and the music once it exists.

**Update, same day:** I rejected the character outline: I want the background changed, not the character. The outline shader and margin were removed (tests re-run: 41/41, keyboard all pass, sound 12/12 + 1 skipped). A new ENV-BG is being generated; the code darkening stays until it arrives.

## 2026-10-07 — inspect and revise: ENV-BG regenerated (v2)

- **Observation (playtest 3, me):** the firefighter was hard to see against the background.
- **Cause (measured by Claude in his play band):** v1's orange-red glow sits at his height; his red suit was nearly the same colour (worst-spot ΔE 31, brightness contrast 1.1 to 1.5). Darkening v1 in code helped only a little; I rejected outlining the character.
- **Revision:** regenerated the background as an edit of v1 with my in-game screenshot attached (SOURCES "ENV-BG v2"): cool, hazy blue-gray, no warm glow. Code darkening removed.
- **Result:** suit red worst-spot ΔE **31 → 85**, typical 76 → 87; helmet worst spot 54 → 72. Screenshots (`evidence/screens-web/`): he reads at a glance; the flames stand out more as well. Trade-off: the sky no longer says "fire" by itself; the smoke columns and the in-level flames carry it.
- **Automated after the change:** `test_game.gd` 41/41, `test_keyboard.gd` 14/14, `test_audio.gd` 12/12 + 1 skipped (music), screenshot route complete with 0 deaths.

## 2026-10-07 — music loop in the slice

- **Change:** `godot/audio/music_loop.ogg` (ElevenLabs Music, 25.6 s = 16 bars at 150 BPM, −20 LUFS) added with Loop on; volume 0 dB on the Music bus.
- **Automated:** `test_audio.gd` now **14 / 14 pass, nothing skipped**. `music-behaviour` (previously SKIPPED) passes with the real file: plays while playing, pauses in place, dips while DYING, continues without restarting after the retry, stops on COMPLETE. New `music-loops`: after one full length the playback wraps to the start and keeps playing. `test_game.gd` 41/41, `test_keyboard.gd` 14/14.
- **Seam (measured in the sound session):** 10 ms crossfade, sample step across the seam 387 vs 736 typical inside the music; no click expected.
- **Still for a human:** the seam over 3 repetitions in play (25.6 s and 51.2 s), the balance with the effects, siren + music at the start, final volume.

### Playtest 3, sound on (human: me)

- **Result, in my words:** "after listening to the sounds together they seem fine." Music at 0 dB with the effects: no change needed, so the final volume is 0 dB.
- Covered by that listen: the effects over the music. Not reported separately: the seam at 25.6 s / 51.2 s by ear (measured clean in the file and the loop is tested), the siren with the music at the start, and muted play (N/B work in `test_keyboard.gd`; whether muted play is still understandable is a human judgment).
- **Change from this playtest (my decision):** the fire-truck siren at the start was too much, so it was removed from the game (kept as a rejected take). Sound checks updated: `siren-once-on-start` → `silent-start` (no sound at all when a session starts), `siren-session-not-retry` → `retry-and-restart-silent` (retries and new sessions add no sounds of their own). Re-run: `test_game.gd` 41/41, `test_keyboard.gd` 14/14, `test_audio.gd` 14/14.
