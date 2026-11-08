# FACTCHECK

Every narrated claim, with its source in this repository (game source revision `486bd48`; docs at the film's commit). Checked by Claude Code against the files. Sreeja reviews the final film.

| Beat | Claim | Source |
|---|---|---|
| B00 | two effects: a puff when he lands, steam that follows the fire | CHANGE-BRIEF A1 + Revision 2, B1 |
| B01 | a test proves an effect starts at the right moment, not that anyone sees it | CLAUDE.md "Headless facts"; a6/TEST-REPORT.md state tests "cannot prove" |
| B02 | Effect A is a burst on every landing; Effect B is a feedback loop following the fire | CHANGE-BRIEF Revision 2 (`landed`), B1 (`player.hosing`, `fire_height()`) |
| B03 | the plan came before Claude wrote anything | CHANGE-BRIEF v1 `45c4398`, before `0651b6e` (first agent output) |
| B03 | bright for an instant, gone in under a second | CHANGE-BRIEF A2 timing phases ("gone by 0.9 s") |
| B03 | white dust nearly disappears on the tan walls, so the puff throws dark specks | CHANGE-BRIEF A2 contrast (white 1.6 : 1 on the wall; ink specks 7.1 : 1) |
| B03 | she wrote what might go wrong, and a cost budget | CHANGE-BRIEF sections P and C |
| B04 | ten puffs, all at once | `godot/effects/jump_puff.tscn` lines 64–66 (`amount = 10`, `one_shot = true`, `explosiveness = 1.0`) |
| B04 | this line pulls every dot with gravity | `jump_puff.tscn` line 77 (`gravity = Vector2(0, -20)`) |
| B04 | a soft round blob made in the scene file | `jump_puff.tscn` line 7 (`GradientTexture2D_disc`), line 70; `godot/effects/ATTRIBUTION.md` |
| B05 | built on the main processor: a flash, ten puffs, six specks | CHANGE-BRIEF A3 (CPUParticles2D; 1 / 10 / 6) |
| B05 | dropped where he landed, behind him, cleans itself up | `jump_puff_driver.gd` lines 12–27; Revision 1 |
| B05 | two quick landings: two puffs, the first left to finish | `test_jump_puff_state.gd` `retrigger-overlap`, `first-not-restarted` (logs/test_jump_puff_state_60fps.log) |
| B06 | Godot records real frames of a test scene, and Claude reads them | `captures/jump_puff/r0/`; a6/TUNING.md |
| B06 | she looked first and saw nothing; the preview waited for exactly frame ten; a one-character fix | a6/TUNING.md r0; a6/FRICTIONAL.md; commit `6b5c613` (`==` → `>=`) |
| B07 | the puff first appeared on the jump; she decided it belonged on the landing | a6/TUNING.md (her words); CHANGE-BRIEF Revision 2 |
| B07 | one new "landed" message, sent where the game already switches to the landing pose | `godot/features/player/player.gd` (`landed.emit()` beside `land_ticks = LAND_TICKS`) |
| B07 | two quick landings: two puffs | `capture/logs/play-marks.jsonl` (landings at 1.82 s and 2.65 s); `play-states.jsonl` (puffs_alive 2 for 61 ticks) |
| B08 | first a greyer fade; Claude predicted a clear grey cloud; the zoomed frames agreed; she could not tell the difference | a6/TUNING.md r1 |
| B08 | second, bigger puffs, kept: the dots read like dust | a6/TUNING.md r2 (her words); CHANGE-BRIEF Revision 4 |
| B09 | the code turns the fire's height into a share of the steam, all at first, none when out | `hose_steam_driver.gd` line 33; CHANGE-BRIEF B-R3 |
| B09 | it changes the share, not the total; changing the total would restart the effect | `hose_steam_driver.gd` line 35 (`amount_ratio`); the assignment's "popping feedback loop"; CHANGE-BRIEF B3 ("amount fixed") |
| B09 | the steam runs on the graphics card, swirls, rises from the whole width of the fire | CHANGE-BRIEF B3 (GPUParticles2D, turbulence, box emission extents) |
| B10 | her first look: hard to see on the sky; Claude's reading agreed | a6/TUNING.md Effect B r0 |
| B10 | one change: a darker, more solid layer | a6/TUNING.md r1; CHANGE-BRIEF Revision 6 |
| B10 | Claude predicted the start would look the same; it did not | a6/TUNING.md r1 comparison (frame 16) |
| B10 | her verdict: better now | a6/TUNING.md r1 ("its better now") |
| B11 | the steam thins as the flames shrink and stops when the water stops | `capture/logs/play-states.jsonl` (`amount_ratio` 0.988 → 0; `steam_emitting` false after the water stops); `test_hose_steam_state.gd` |
| B11 | Escape pauses the game but not the particles; drifting behind the pause card | `session.gd` `set_paused()` (not a tree pause); `test_hose_steam_state.gd` `game-pause-holds` (still processing); the take frames 455–499 (pause card over the fire) |
| B11 | which Sreeja chose; no sudden vanishing at either screen edge | CHANGE-BRIEF B-R5; a6/TEST-REPORT.md edge checks ("looks good ig", "good") |
| B12 | Godot can show the program behind the steam; she converted a copy | `godot/shaders/particles_generated.gdshader` (`bf9bbfc`); a6/TEST-REPORT.md "The process shader" |
| B12 | line 331 skips a new dot outside the current share | `particles_generated.gdshader` lines 331–333 (`AMOUNT_RATIO`) |
| B12 | line 232 picks each dot's speed between twenty and forty | line 232; CHANGE-BRIEF B3 Steam `initial_velocity_min / _max` 20 / 40 |
| B12 | "in her words" | a6/TEST-REPORT.md (her answer) |
| B13 | tests read every setting back and press real keys | `test_*_config.gd` (94, 89 checks), `test_*_state.gd` (30, 18 checks) |
| B13 | the Godot 3 name: no warning, the test fails, a blob in the game | `a6/evidence/mutations/mutation-1-*.log` (exit 1, no warning); a6/TEST-REPORT.md (her in-game words) |
| B14 | the puff's CPU price is too small to measure, inside its budget | `a6/evidence/cost/cost_effects_after_fix_run{1,2,3}_60fps.log`; budget 0.1 ms (CHANGE-BRIEF C) |
| B14 | the steam shows almost nothing headless; no graphics card is used without a screen | the same logs (steam = off); `a6/evidence/probes/particle_cost_example09_60fps.log`; CLAUDE.md Headless facts |
| B14 | only one graphics mode reports the card's time on this Mac | `a6/evidence/probes/gpu_time_probe.log` (Mobile + Vulkan only) |
| B14 | the steam costs about a fifth of a millisecond, under its half-millisecond budget | a6/TEST-REPORT.md Visual Profiler (0.04 → 0.25 / 0.27 ms); budget 0.5 ms |
| B15 | a test scene that skipped its trigger; a cost script that assumed equal lifetimes and changed its rule | a6/FRICTIONAL.md; commits `6b5c613`, `db26889`; a6/evidence/cost/ |
| B15 | recording windows hidden behind others, caught by identical frames | a6/TUNING.md r2 capture note |
| B16 | verified / judged / uncertain / next / who did what / no downloaded images | a6/TEST-REPORT.md; a6/TUNING.md; a6/FRICTIONAL.md "Unresolved questions"; a6/SOURCES.md; `godot/effects/ATTRIBUTION.md` |
| B17 | the steam should visibly thin in its second second, and it is hard to see | a6/TUNING.md r1 comparison (frame 70 "not obviously thinner than 40"); a6/FRICTIONAL.md |
