# walker-ninja-firefighter-joe

An asset slice for CSYE 7270 Assignment 2: **Extinguisho**, a deadpan ninja firefighter, has 40 seconds to rescue a person and a dog from two burning buildings: kung-fu jump over flames, hose the fire blocking the way, toss the survivors into his bag, and escape off the roof. The art (and, in progress, the sound and music) is generated with generative models and wired into a playable Godot scene.

> Status 2026-10-07: character art, the background, and the flames are in the slice; sound effects, music, and mute are in progress. Sections marked *(in progress)* will be updated before submission.

## Started from

My Assignment 1 project, `walker-jumpman-joe` (a firefighter rescue platformer), which extended [nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman) ("First Steps" starter). The Godot project in `godot/` was copied on 2026-10-01 (control and retry engine, state machine, level, hose and rescue mechanics, timer, tests). See SOURCES.md.

## Engine

Godot **4.7.2** stable (GL Compatibility renderer), macOS.

## Run it

1. Install Godot 4.7 or newer.
2. Open `godot/project.godot` in Godot and press Play, **or** from a terminal:
   ```
   <path-to-Godot> --path godot
   ```
   On macOS with Godot in Applications, double-click `walker-jumpman.command`.

Automated tests (from `godot/`):
```
<path-to-Godot> --headless --path . -s tests/test_game.gd       # 41 checks
<path-to-Godot> --headless --path . -s tests/test_keyboard.gd
<path-to-Godot> --path . -s tests/capture_game.gd               # screenshots of every state -> evidence/screens/
```

## Controls

| Key | Action |
|---|---|
| A / D or ← / → | move |
| Space | jump |
| W | hose the blocking fire (when close) |
| R | retry |
| Esc or P | pause |
| Enter | start / resume / play again |
| M | main menu (from pause or the end card) |
| N | mute / unmute music *(in progress)* |
| B | mute / unmute sound effects *(in progress)* |

## What the slice demonstrates

- **Character:** 11 generated state images swapped by game state: idle, run, flying-kick jump, meditating fall, landing, hose, rescue grab, upward toss, burned, respawn stance, and a bow at the end. Facing left mirrors the art. Collision box 20×40 (CHARACTER-SHEET.md, collision overlay).
- **Environment:** a generated burning-city skyline (ENV-BG) behind the level, and generated flames (ENV-FIRE) on every fire hazard; the fire blocking the person shrinks as it's hosed.
- **Failure punchline:** on a fire death, the generated DEVASTATED portrait pops up next to "The fire got you."
- **Sound and music:** five event sounds on real game events and a seamless music loop *(in progress)*.
- **Design and evidence:** CONCEPT.md, STORYBOARD.md, CHARACTER-SHEET.md, CHANGE-BRIEF.md (plan and predictions), SOURCES.md (models and asset log), TEST-REPORT.md, ../FRICTIONAL.md (design log), rejected outputs in `rejected/`, in-engine screenshots in `evidence/screens-web/`.

## Known limitations

- The character's face doesn't read at game size (64 px); attitude comes through the poses. The burned pose is dark and subtle on the dark background.
- The level, survivors, rescue bag, and HUD are code-drawn (from A1), not generated.
- The run is slower and the jump floatier than A1 (changed after playtest 2).
- ChatGPT does not expose seeds, so regenerating an image from its logged prompt gives a similar, not identical, result.
- *(to update after sound, playtest 3, and the film)*

## Film

*(in progress)*: final film link, filename, and SHA-256 will be added here.
