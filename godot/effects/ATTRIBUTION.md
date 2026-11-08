# Effect textures — provenance

Assignment 6 uses **no sourced, downloaded or generated image** for its particle effects. Every particle texture is a `GradientTexture2D` defined inside the effect's own scene file, so the scene file is the texture's source:

| Scene | Sub-resource | Definition | Written by |
|---|---|---|---|
| `jump_puff.tscn` | `GradientTexture2D_disc` (shared by `Flash`, `Puff`, `Specks`) | 32 × 32, radial fill, `fill_from` (0.5, 0.5), `fill_to` (1.0, 0.5), gradient white α 1 → white α 0 | Claude Code (`claude -p` session 2, `a6/sessions/session-2.jsonl`), from the recipe in CHANGE-BRIEF.md A3 |
| `hose_steam.tscn` | `GradientTexture2D_disc` (shared by `Haze` and `Steam`) | the same recipe (CHANGE-BRIEF.md B3) | Claude Code (`claude -p` session 5, `a6/sessions/session-5-steam-build.jsonl`) |

- Licence: none needed; the definitions are part of this repository's code.
- Checked: 2026-11-07, by reading both scene files.
- No model, prompt or third-party asset is involved, so there is nothing to add to SOURCES.md's generative-model table for these textures.
