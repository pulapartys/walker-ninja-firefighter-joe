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
