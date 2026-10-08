# COMPONENTS

The components explained in the film (machine-checked in `gamedev-evidence.json`):

| Component | Files | Beats |
|---|---|---|
| player-states | `features/player/player.gd`, `tuning.gd` | B06 show_pose → B07 toss in play; B08 _update_pose → B09 every state; B10 collision box → B11 art vs box |
| character-art | `art/character/*` (12 state textures, anchors, 2 close-ups) | B05, B09 |
| environment-art | `art/env/*` (ENV-BG v2, 3 flames) | B12 |
| session-events-audio | `game/session.gd`, `game/main.tscn` | B14 sound after state → B15 burned; B18 music → B19 muted |
| level-data | `levels/first_steps.json` | B12 |
| hud | `ui/hud.gd` | B15, B19 |
| audio-assets | `audio/*` (5 sfx, music loop) | B13, B17 (heard in B16) |
| tests | `tests/*` | B20 |
| project-config | `project.godot` | B01 |

Excluded: `.gitignore` (repository hygiene).
