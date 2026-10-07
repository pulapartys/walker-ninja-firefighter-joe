# CHANGE BRIEF — asset slice for walker-ninja-firefighter-joe

> v1 · 2026-10-01 · written before any generation. Storyboard panel numbers are provisional until STORYBOARD.md is committed.

## What changes

The slice is the existing two-building level from Assignment 1. Its gameplay, level layout, collision, timer, and tuning stay as they are. The change is the assets:

- The code-drawn firefighter becomes generated sprite frames of Extinguisho.
- Generated environment art is added.
- Generated sound effects and a music loop are added, with mute controls.

## Provisional storyboard panels

| Panel | Moment |
|---|---|
| P1 | First view / title |
| P2 | Core action: hosing the blocking fire |
| P3 | Success: rescuing a survivor |
| P4 | Failure: burned by fire |
| P5 | Retry |
| P6 | End: escape off the roof and bow |

## Asset list

| ID | Asset | Type | Panels |
|---|---|---|---|
| CHAR-REF | Turnaround reference (all poses derive from it) | art | — |
| CHAR-IDLE | Idle, grumpy, arms crossed | sprite | P1, P5 |
| CHAR-WALK-A / CHAR-WALK-B | Walk contact / passing | sprite | P1, P2 |
| CHAR-STANCE | Kung-fu stance | sprite | P2 |
| CHAR-RISE | Flying-kick rising | sprite | P2 |
| CHAR-FALL | Falling | sprite | P4 |
| CHAR-LAND | Three-point landing | sprite | P3 |
| CHAR-SPRAY | Hose spray | sprite | P2 |
| CHAR-RESCUE | Rescue grab | sprite | P3 |
| CHAR-BURNED | Comic devastated face | sprite | P4 |
| CHAR-BOW | Deadpan bow | sprite | P6 |
| ENV-BG | Burning-city backdrop behind the level | art | all |
| ENV-FIRE | Flame sprite for the hazards and the blocking fire | art | P2, P4 |
| SFX-JUMP | Martial-arts whoosh | sound | P2 |
| SFX-HOSE | Hose blast or splash | sound | P2 |
| SFX-RESCUE | Rescue sting | sound | P3 |
| SFX-BURN | Exaggerated cartoon yelp or sizzle | sound | P4 |
| SFX-WIN | Gong or win sting | sound | P6 |
| MUS-LOOP | Urgent, drum-led loop | music | P1–P5 |

**Out of scope for generation:** the survivors (person and dog), the ledges, the HUD, and the text stay code-drawn. Claude-drawn art is allowed in the game but does not count as generated.

## Event-to-sound map

Each sound fires from the code that already represents the event.

| Sound | Exact trigger in code | How a double trigger is prevented |
|---|---|---|
| SFX-JUMP | `player.gd`, `_physics_process`, where `velocity.y = tuning.jump_velocity` and `jumps += 1` | That branch runs once per jump: `opportunity_consumed` blocks a repeat until he is back on the floor, and `require_jump_release` blocks a held key. |
| SFX-HOSE | `session.gd`, where `extinguish_ticks = EXTINGUISH_TICKS` is set | It only runs when `extinguish_ticks == 0`, so pressing W repeatedly while water pours does nothing. |
| SFX-RESCUE | `session.gd`, where `s.rescued = true` | It is guarded by `not s.rescued`, and the area's monitoring is switched off. |
| SFX-BURN | `session.gd`, `resolve_contacts` with `fatal`, when the death cause is fire | `resolve_contacts` returns unless the state is `PLAYING`, and the state becomes `DYING` on the first call. `contact_settle_ticks` prevents a phantom second death after a reset. |
| SFX-WIN | `session.gd`, `resolve_contacts` when the state becomes `COMPLETE` | Same `PLAYING` guard; it fires once per completion. |

**Rule:** the sound is played *after* the state change. A missing or muted sound changes nothing.

**Open decision:** dying by falling or by timeout either reuses SFX-BURN or gets its own SFX-FAIL. To decide after hearing them.

## Music behavior

| Moment | Music |
|---|---|
| Title menu | off, or quiet |
| Playing | MUS-LOOP, looping seamlessly |
| Pause | pauses; resumes from the same point |
| Failure (`DYING`) | dips under SFX-BURN; back to normal on retry (does not restart) |
| Success: rescue | keeps playing (SFX-RESCUE plays over it) |
| End (`COMPLETE`) | stops; SFX-WIN plays |

**Mute:** separate toggles for music and for effects. Keys to be chosen during the build; M is already taken by "menu".

## Predicted failures and how I will check them

| # | Prediction | Check |
|---|---|---|
| F1 | Generated poses drift in proportion: helmet size, head ratio, height. | Line every frame up against the turnaround height bar and the CHARACTER-SHEET consistency rules; reject or edit any that drift. |
| F2 | The red suit and yellow helmet disappear against the flames. | Downscaled sprite on an in-game screenshot next to the fire, at 1× and in grayscale. |
| F3 | The grumpy and devastated faces are unreadable at 32 px. | Judge at 1× in-engine, not in the source image; exaggerate or change the style if needed. |
| F4 | A sound fires twice on one event: a held jump key, W mashing, or a death at the moment of reset. | An automated check that counts sound triggers per event during a scripted input sequence. |
| F5 | The music loop clicks or gaps at the seam. | Listen to at least 3 repetitions; cut at a bar boundary in Audacity; export as OGG with loop enabled on import. |
| F6 | The sprite does not line up with the collision box (floating feet, offset body). | Draw the collision overlay on each pose; compare in-engine with debug collision shapes visible. |
| F7 | Pixel art blurs when scaled. | Set the texture filter to Nearest; compare screenshots. |
| F8 | The slice is unreadable with sound muted. | Play a full run muted; the death-reason text and poses must explain every event. |

## Revision 2026-10-05 — what changed during pose generation

The plan above is kept as written; these are the changes since.

- **Assignment update:** animation is no longer required. Each character state is **one static image** that the game swaps in. "Sprite frames" above now means one image per state.
- **Character size:** he will be **bigger** than the A1 firefighter. The art's detail disappears at the A1 size of about 64 px on screen; the exact size will be chosen during the build. A bigger character needs a bigger collision box and level adjustments (CHARACTER-SHEET, CHAR-REF-03).
- **Pose-to-state changes:**
  - CHAR-IDLE is now the standing side profile (`side-profile-game.png`), not "arms crossed".
  - CHAR-WALK-A/B are replaced by one run pose, **CHAR-RUN** (the game has one speed).
  - The kung-fu ready stance is kept as **CHAR-RESPAWN**, shown on retry (panel 5).
- **Things the game draws, not the pose images:**
  - **Water:** the hose pose (CHAR-SPRAY) has no water. The game already draws the water stream (`godot/game/session.gd`), starting at the nozzle (pointing right, about chest height).
  - **Survivors:** the grab and toss poses (CHAR-RESCUE, CHAR-TOSS) have nobody in them. The game draws the person and the dog, so one image works for both.
- **Rescue toss goes up (my design change):** instead of a sideways toss over the shoulder, he flings the survivor **straight up, sky-high**, without looking, and they drop into his bag (CHAR-TOSS shows his arm thrown up, mid-yawn).
  - **Optional build step:** the game draws the survivor flying up and falling into the bag. It's a short code-drawn arc after the rescue event. If there isn't time, the survivor appears in the bag immediately, as in A1.
  - It must stay visual only. The rescue counts at the moment of contact, as now, so the arc never changes game state.

## Revision 2026-10-07 — plan vs. what is built

The plans above are kept as written. This records the slice as of 2026-10-07.

### Gameplay is no longer "unchanged"

v1 said gameplay, layout, collision, timer, and tuning stay as A1. That changed for the bigger generated character and after playtest 2 (details: CONCEPT.md "Revision 2026-10-07", TEST-REPORT.md):
- run speed 160 → 120, jump gravity 960 → 800 (64 px jump), collision box 18×28 → 20×40, fire-death retry 0.55 s → 0.9 s;
- ledges and in-level text recolored for ENV-BG; the "Rescue complete" card waits 1.25 s so the bow is seen.
The layout, timer, survivors, and hose rules are unchanged, and the full scripted route still completes (41/41 tests).

### Asset list: status

| ID | Status |
|---|---|
| CHAR-REF (turnaround, side profiles) | done |
| CHAR-IDLE, CHAR-RUN, CHAR-RISE, CHAR-FALL, CHAR-LAND, CHAR-SPRAY, CHAR-RESCUE, CHAR-TOSS, CHAR-BURNED, CHAR-RESPAWN, CHAR-BOW | done, in the slice (one image per state) |
| CHAR-STANCE (crane) | generated; **sheet only** (dropped from the jump in playtest 1; on 2026-10-07 I decided not to reuse it as a "waiting" pose) |
| CHAR-WALK-A / -B | replaced by CHAR-RUN (one speed) |
| ENV-BG | done, in the slice |
| ENV-FIRE | **done** (2026-10-07): three generated flame images (single, wide, tall) replace the code-drawn flames; visual only, the hazard collision rectangles are unchanged (flame-clearance tests pass) |
| SFX-JUMP, SFX-HOSE, SFX-RESCUE, SFX-BURN, SFX-WIN | **in progress**: prompt variants drafted by Claude; the prompts actually sent will be logged verbatim in SOURCES.md |
| MUS-LOOP | **done** (2026-10-07): ElevenLabs Music, recorded via Audacity, 16-bar loop cut at 14.10–39.70 s; in the slice with Loop on |

### Event-to-sound map: one change

SFX-RESCUE fires at the same place as planned (`session.gd`, where `s.rescued = true`), which is also where the grab → toss starts. The toss arc is drawn afterwards and never triggers a second sound.

### Mute keys (planned)

M is taken by "menu", so: **N** toggles music, **B** toggles sound effects (separate, as the assignment prefers). Both only change volume; nothing in the game reads them.

## Revision 2026-10-07 (later) — sounds wired into the slice

The v1 event-to-sound map is implemented as planned, with these changes (code: `godot/game/session.gd`, `godot/features/player/player.gd`):

| Sound | Trigger in code, as built | Double-trigger guard (unchanged from v1) |
|---|---|---|
| SFX-JUMP | `player.gd` emits `jumped` right after `jumps += 1`; the session plays the sound | the jump branch runs once per jump |
| SFX-HOSE | `session.gd`, right after `extinguish_ticks = EXTINGUISH_TICKS` | only when `extinguish_ticks == 0` |
| SFX-RESCUE | `session.gd`, right after `s.rescued = true` (the toss starts there too) | `not s.rescued` + monitoring off |
| SFX-BURN | `resolve_contacts`, after the state becomes `DYING`, only for "The fire got you." | the `PLAYING` guard |
| SFX-WIN | `resolve_contacts`, after the state becomes `COMPLETE` | the `PLAYING` guard |
| SFX-SIREN (new) | `start_session()` (a new session from the menu or the end card), **not** on retries | `start_session` returns while `PLAYING` |

- **Changed sound (my decision):** SFX-WIN is a cartoon crowd cheering with claps, not the planned gong, because I wanted the win to be funny and childish. Still open: how it fits "he does not cheer" (CONCEPT). One reading: the rescued people cheer while he stays deadpan and bows.
- **New sound (my idea):** SFX-SIREN, the fire truck arriving, once per session start. Kept out of the music so the loop seam stays clean (Claude's advice). Keep or drop: to decide after playtest 3.
- **Open decision closed for now:** dying by falling or timeout plays **no** sound (no SFX-FAIL was generated); the on-screen reason ("You fell." / "Out of time!") explains it.
- **Mute:** N toggles the Music bus, B the SFX bus; the HUD shows "MUSIC OFF" / "SOUND OFF". Nothing in the game reads the buses.
- **Music behaviour** is implemented (plays while playing, pauses in place, dips 12 dB while DYING and returns on retry without restarting, stops on COMPLETE, off in the menu) but **MUS-LOOP does not exist yet**, so it is untested with real music.
- **F4 (a sound fires twice) is checked automatically** by `godot/tests/test_audio.gd` (TEST-REPORT).

## Revision 2026-10-07 (playtest 3)

- Fire-death retry hold 0.9 s → **2.0 s** (R skips it). This changes A1's 1 s retry limit; the test now checks the new hold and that R retries at once.
- ENV-BG drawn darker in code (F2 "character disappears against the background" observed in playtest 3). A light character outline was tried and rejected (my decision); **ENV-BG is being regenerated** so the background itself lets him read.
- A bow close-up pops up on COMPLETE, like the DEVASTATED close-up on a fire death.
- New automated checks for sound: order after the state change, siren per session, no burn for falls or timeouts, missing sound files change nothing; music behaviour check ready (skipped until the loop exists).
- **Update (same day): ENV-BG regenerated (v2)** as an edit of v1 in ChatGPT: cool, hazy blue-gray, gray smoke, no warm glow. The code darkening was removed. F2 (character disappears against the background) is resolved by changing the background, not the character.
- **Update: MUS-LOOP is in** (ElevenLabs Music, not the planned Suno). The music behaviour above is now tested with the real file (`test_audio.gd` `music-behaviour`, `music-loops`). F5 (click at the seam): measured in the file (crossfaded seam, step 387 vs 736 typical); to confirm by ear over 3 repetitions.
