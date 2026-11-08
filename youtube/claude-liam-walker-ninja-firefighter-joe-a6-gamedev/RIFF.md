# RIFF

Commentary tied to inspected evidence, not imagined play:

| Artifact | Visible observation | Interpretation (source) | Narration beat |
|---|---|---|---|
| `captures/jump_puff/r0/` | the flash and cluster at frame 10, about 25 px by 15, a pale haze by 20, gone by 50 | the timing matches the brief; small and low-contrast on the tan wall (a6/TUNING.md) | B06 |
| `capture/play.avi` 0.5–12.9 s, `play-marks.jsonl` | a puff on every landing; two alive after the double hop at the spawn | the event moved from the jump to the landing at her decision (CHANGE-BRIEF Revision 2) | B07 |
| `captures/jump_puff/r1`, `r2` | r1 greyer, r2 bigger and denser | r1: Claude saw an improvement, she "couldnt tell the difference a lot"; r2: "granular dust" (a6/TUNING.md) | B08 |
| `captures/hose_steam/r0` vs `r1` | r0 steam barely visible on the sky; r1 a grey cloud from frame 16 | her first look and Claude's reading agreed; Claude's frame-16 prediction was wrong (a6/TUNING.md) | B10 |
| `capture/play.avi` 11.0–20.85 s, `play-states.jsonl` | steam rises, thins as `amount_ratio` falls 0.99 → 0, stops with the water; the pause card hides it during Esc | the feedback loop as specified; Esc does not pause the tree, but the card covers the effect | B11 |
| `a6/evidence/probes/gpu_time_probe.log` | GPU time 0 under Compatibility and Metal; numbers only under Vulkan | the instrument decides what can be measured (a6/TEST-REPORT.md) | B14 |

Limitations named on screen and in the voice: headless proves settings and timing, never a pixel; the scripted take is not a human playtest; the GPU price was taken on Mobile + Vulkan, not the renderer the game ships with; the puff's GPU cost is not isolated.
