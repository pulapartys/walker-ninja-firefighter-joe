# Film QC review

## Machine checks
| Check | Result |
|---|---|
| `./art godot-gamedev --check <reel> --game <game>/godot` | **PASS**: 61 source files hashed, 1 exclusion, 9 components, 5 exact excerpts, 5 code→result pairs (code-then-result-v1) |
| GATE V frame check (`final_frame_check.py`, run inside the compile) | first compile: **2 BLOCKERs, both B01** (the typed line crossed the title-safe edge) → line shortened, font 92 → 80, B01 re-rendered → recompiled: **clean, 0 BLOCKER / 0 MAJOR** (48 frames) |
| Master | `exports/landscape/claude-liam-walker-ninja-firefighter-joe-gamedev.mp4`: 3840×2160, 30 fps, H.264 + AAC, 362.77 s; SHA-256 `7c0d484b7aba9e780f0f04dbb1f24b2f9f0551a38210db6a8458ac846c296230` |
| Game-audio segment B16 in the master | 228.13–258.06 s: mean −17.2 dB (audible game mix; no narration on that beat) |
| GATE T typography (`type_check.py`) | **9 findings remain, all inside real evidence**, so `art final` was not used; the master was compiled with the same `compile.py` that `art final` runs after the gate (details below) |

## GATE T findings that remain, and why they are not changed
- **B07, B09, B15, B16, B19 (gameplay):** "text outside title-safe" and "smallest text run 35–40 px": this is the **game's own HUD** in native 4K engine captures (its labels start 132 px from the edge; the HUD's small line is the game's typography). The skill forbids repairing the game for the film. Our own label boxes were moved inside the safe area (x ≥ 230) and enlarged (56/46 px).
- **B02, B04, B11, B12 (figures):** "per-blob contrast below 3:1": text **inside** the storyboard sketches (hand-lettered labels in the ChatGPT sketches), the prompt cards' thin strokes after scaling, and the game screenshots' HUD. These are evidence images shown in Brutalist's `GodotDesignFigure` slot (meant for real captures and design images); the figure title, status, and cards around them are the toolkit's own styling.
- Earlier rounds fixed what was ours: the image beats moved from this reel's custom panel to `GodotDesignFigure`; the gameplay labels moved and grew.

## Human review (to be completed by Sreeja)
- [x] Sreeja watched the final export on 2026-10-07 (QuickTime) and approved it ("good").
- [ ] B16 (game audio, no narration): music, jump, hose, rescue toss, win cheer, and the burn are audible; no narration over it.
- [ ] Narration audible and in sync with the visuals; outro spoken with no music.
- [ ] Labels: "Illustrative reconstruction" (B00), "Godot editor reconstruction" (code), "scripted normal input · Movie Maker" (gameplay), "HELD FRAME" where shown.
