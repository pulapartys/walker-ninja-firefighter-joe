# FACTCHECK

Each spoken claim and where it is verified (all paths relative to `walker-ninja-firefighter-joe/`).

| Claim (beat) | Evidence |
|---|---|
| Grew out of her Assignment 1 platformer; one level, two buildings, 40 s clock (B01) | README.md "Started from"; `godot/levels/first_steps.json` (`time_limit` 40) |
| Five generated sound effects, a looping track (B01, B13, B17) | `godot/audio/` (5 sfx + `music_loop.ogg`); SOURCES.md sound and music logs |
| Storyboard text committed two minutes after the first sketch (B02) | FRICTIONAL.md retrospective note; commits `1f2b5c6` (10:22) vs `panel1.png` saved 10:20 |
| Twelve labeled poses, silhouette, collision overlay, five-colour palette, consistency rules (B03) | CHARACTER-SHEET.md "Revision 2026-10-07"; `design/character/` |
| Panel 3b sideways toss; first generation sideways; idea changed to straight up (B04) | `design/storyboard/03b-throw.png`; `rejected/CHAR-TOSS-pose09-sideways.png`; FRICTIONAL 2026-10-05 "the toss goes up" |
| Edit changed only the arm; flood-fill background removal, one shared scale, feet anchor, 128 px texture at half size (B05) | CHARACTER-SHEET "Pose 9"; `tools/make_sprites.py` (TEX_H 128, flood fill from the border); `player.gd` `art.scale = 0.5` |
| show_pose swaps the texture, anchors at the feet, mirrors by facing (B06) | `godot/features/player/player.gd` lines 71–77 (rev 241c3f2) |
| Rescue counts on touch; the arc is drawn afterwards (B07) | `session.gd` rescue block (`s.rescued = true` before `flights.append`); `test_game.gd` rescue checks |
| Action poses first, then air, then ground; kick to touchdown; landing 1/3 s (B08) | `player.gd` lines 85–112; `LAND_TICKS := 20` at 60 Hz |
| Crane crouch only on the sheet (B09) | TEST-REPORT Playtest 1; CHARACTER-SHEET "States as built" |
| Box 20 × 40, centred 20 above the feet (B10) | `player.gd` lines 24, 48–56 |
| Art past the box only forgives; none smaller (B11) | `evidence/compare/character-vs-sheet.jpg`; TEST-REPORT "Character against the sheet" |
| Flames keyed out from green; ΔE 31 → 85 (B12) | `tools/make_env.py`; TEST-REPORT "ENV-BG regenerated (v2)" (measurement in his play band) |
| −14 LUFS, limiter just under full scale, Ogg Vorbis (B13) | `tools/make_audio.sh` (−14 LUFS, limit −1 dBFS); `ffprobe` codec vorbis |
| Sound after the state change; guards stop doubles; nothing reads a sound (B14) | `session.gd` lines 194–211; `test_audio.gd` `sound-after-state-change`, `burn-once-per-death` |
| Burned pose + close-up hold 2 s, then respawn (B15) | `FIRE_DEATH_HOLD := 2.0`; capture `fire` states log |
| Second music version; 150 BPM; 1.6 s bars; 16 bars; 10 ms crossfade (B17) | SOURCES.md "Music"; FRICTIONAL "the music loop" |
| Two buses; music plays/pauses/dips/continues/stops; N and B (B18) | `session.gd` lines 561–575 and `_setup_audio`; `test_audio.gd` `music-behaviour`; `test_keyboard.gd` N/B checks |
| Muted HUD indicators and on-screen reasons (B19) | capture `muted`; `hud.gd`; screenshots `06-muted…`, `07b-you-fell`, `08b-out-of-time` |
| Fresh copy; 13 jumps = 13 sounds, 1 hose, 2 rescues, 1 win; muted/missing files identical (B20) | `evidence/test-output.txt`; TEST-REPORT "fresh-copy run" |
| Limits; models; revision 241c3f2 (B21) | README "Known limitations"; SOURCES model table; `git log` |

**Not established by the evidence:** that the sounds and music *feel* right to other players (only the student listened); a human muted playtest (scripted muted capture only); behaviour on Windows/Linux.
