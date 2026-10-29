# FRICTIONAL — Assignment 5

> Assignment 2's log is in the class repo; Assignment 3's is [`../a3/FRICTIONAL.md`](../a3/FRICTIONAL.md).
>
> **How I worked:** I did this assignment in one long Claude Code session on 2026-10-28, from a repository I had not touched since A3. I made the decisions (which game state, the glow colour and timing, which textures, how the two materials differ) and typed the three shaders myself; Claude Code read my game's code, explained what a shader is, drafted the brief and CLAUDE.md from my decisions, wrote the driver, the tests and the capture scripts, ran the headless checks, and organised these notes from what happened in the session. I reviewed what it wrote. Everything below is dated 2026-10-28 unless said otherwise. **Retrospective note:** Claude drafted this log from the session; I read it and kept what is true.

## Entries

### Reading the assignment with no idea what a shader is

- **What I was working on:** understanding Assignment 5. I had the previous assignments' context and nothing else.
- **I tried / expected:** I pasted the assignment and asked what it says, then said I had no idea what a shader is.
- **What happened:** the first summary was too dense for me. Claude re-explained from zero with my own game as the example (the "painter with amnesia" picture: thousands of workers, one dot each, forgetting everything, so the game must pass a number in every frame). That version I understood.
- **What I did:** I asked how many things need a shader (three: the 2D effect, the 3D textured one, the hint experiment, plus one Godot generates) and what could be shaded. Claude listed Extinguisho's sprite and the sky as easy (their own nodes) and the fires and the pop-up as hard (drawn inside `_draw`, not nodes). I first worried the 2 s fire-death flash was too short to see; Claude pointed out it cannot be lengthened (timings are out of bounds) and listed longer states. I chose **Extinguisho glowing blue-white while hosing**, because it lasts 5 s and happens every run.
- **Decisions I made when asked:** pale blue-white (0.6, 0.85, 1.0); fade in, hold, fade out; Poly Haven rusty metal with a normal map; fresh red vs rusty old. My words were "start with 1 and see if we like it".
- **What I understand now:** a shader is the per-pixel program; a material is the shader plus the current dial values; a texture is numbers whose meaning the shader decides; the uniform is how game state reaches the pixel program.

### Repository and identity

- **What happened:** three copies of the repo existed on my Mac; Claude compared each with GitHub and used `~/Desktop/repos/walker-ninja-firefighter-joe` (identical to `origin/main`). It found that 27 of my 44 earlier commits were authored under my work e-mail by mistake (the global git config), and that pushes used the wrong account's token.
- **What I did:** had the repo pinned to `pulapartys <pulaparty.s@northeastern.edu>` with a repo-local credential rule; a dry-run push confirmed it. Earlier history was left alone (rewriting it would break the a2/a3 tags).
- **Unresolved:** the old commits keep the wrong author name.

### Wrapper and baseline

- **I tried:** `scripts/run-test.sh` exactly as the assignment gives it, with a fallback to my Godot in `~/Downloads`.
- **What happened:** `test_game` 41/41, `test_keyboard` 14/14, `check_props` PASS, but **`test_audio` 12/14** under `--fixed-fps 60`, which was 14/14 in A3. Re-run without the pin: 14/14. Re-run with the pin: 12/14 again, same two checks (`music-behaviour`, `music-loops`).
- **What I learned:** the two checks read the music stream's playback position, which runs on the real-time audio clock; pinning the frame rate decouples the game loop from real time, so the loop point is never reached inside the test. Not a game change, and the assignment forbids editing existing tests, so the baseline is recorded both ways (TEST-REPORT "Baseline").

### The brief, and two mistakes in it found later

- **What happened:** Claude drafted CHANGE-BRIEF v1 from my four decisions plus the code (`water_ticks`, `player.hosing`, the hose sprite's texels, the sky colour, the Poly Haven asset). I read the parts I will be quizzed on: the colour line, the pixel arithmetic, the 2.0 prediction, the grey-strip numbers, the short answers. Committed before any shader or prompt (`4a0d1ad`).
- **Revision 1:** while checking the CLAUDE.md draft, Claude found my brief named `start_session()` as the function that resets the water; it is `restart_attempt()`. Behaviour unchanged, name wrong. Dated revision, original kept.
- **Revision 2:** the driver plan pointed out that the game's `set_paused()` is not a tree pause, so a ramp in flight finishes its last 0.25 s before holding. The brief had said pause freezes the glow outright. Dated revision; the test checks the pause during the hold, where both readings agree.

### CLAUDE.md: the agent's draft was right, and I still changed it

- **What happened:** the read-only `claude -p` run (33 turns, ended normally, 4 Bash denials from the allowlist) wrote a 58-line draft. Every file reference and line number it cited was checked against the source and was correct. It listed helper scripts next to the tests and had no "Headless facts" block.
- **What I did (review commit):** line numbers replaced by function names so they do not rot; helpers moved to a "not tests" line; Headless facts added (no pixels headlessly, uniform list works, set-then-get proves nothing, fixed fps is game time, audio is not pinned-safe); the sprite size moved from Unconfirmed to confirmed (a headless probe had measured 126 × 84). Draft and review are separate commits (`7244161`, `16bf927`).

### Typing the shaders

- **I tried:** I asked Claude to type the shader for me and record it as mine, so I could "prepare" from a note. It declined to write it under my name and offered two honest options: I type it, or it types it and the record says so.
- **What I did:** I typed all three shaders myself in TextEdit from Claude's line-by-line explanation of the brief's uniform table and colour line. `hose_glow.gdshader` (7 lines) parsed first time. On `hint_experiment.gdshader` I saved without the first two lines (`shader_type spatial;`, `render_mode unshaded;`); Claude's disk check caught it before the import. `hydrant_surface.gdshader` (25 lines) parsed first time; Godot reports the two `group_uniforms` groups.
- **What I understand now:** the colour line `COLOR.rgb = mix(COLOR.rgb, glow_color.rgb, glow);` slides each pixel toward the glow colour by the dial; `.rgb` leaves alpha alone so the sprite's transparent edge stays transparent.
- **Traceability:** `5775582`, `7f54c75`, `32f5be2`, each committed alone before the agent touched anything that uses it.

### Driver and test (agent), plan first

- **What happened:** invocation 1 (read-only) proposed the plan and stopped; I approved all three steps. Invocation 2 wrote `hose_glow.gd` (26 lines, `move_toward` by `delta / 0.25`), a 2-line hook in `player.gd`, and `test_hose_glow.gd` (12 checks). It hit two GDScript type errors on its first run and fixed them (visible in the transcript). 12/12 at 30, 60 and 144 fps; existing suites unchanged; one Bash denial (an `; echo` appended to the allowed command).
- **What I checked:** I read the test for the assignment's recorded agent mistake (calling the update function directly) and grepped it: it presses W and R through `Input.parse_input_event` and never touches the driver. The 30 fps log shows real per-frame samples: 8 frames = 0.267 s, inside the one-frame tolerance.
- **Accepted as-is:** the agent's own caveat that the ramp-time check multiplies frames by the end delta instead of summing deltas. Noted, not changed.
- **Mutations:** semicolon deleted → `SHADER ERROR: Expected a ';'.`, empty uniform list, 3 checks fail, exit 1. Uniform renamed in the shader only → parses, 4 checks fail, exit 1. Restored, 12/12, shader diff empty.

### Controlled-value captures: two false starts before the numbers matched

- **I tried:** a windowed capture script (`capture_glow.gd`) that freezes the driver, sets `glow` from code and reads the rendered frame, as the assignment's `capture()` snippet does.
- **What happened, attempt 1:** every sample was sky-blue and identical across glow values. The script had pressed W during the 30-tick respawn stance, so the sprite was `respawn.png`, not `hose.png`, and the pose changed between captures. Fix: wait for `pose == "hose"`.
- **Attempt 2:** still sky. The sprite transform I used gives 640 × 360 game coordinates, but the frame is 1280 × 720; every sample was 220 px left of him. Fix: apply the viewport's final transform. The same mistake happened again in the hint-experiment capture and was fixed the same way.
- **Attempt 3:** P1 (227, 29, 25) / (190, 123, 140) / (153, 217, 255) / (79, 255, 255) against predicted (229, 29, 25) / (191, 123, 140) / (153, 217, 255) / (77, 255, 255); P2 and P3 likewise within tolerance. **`hint_range` does not clamp** a value set from code (2.0 stored, cyan overshoot). **`source_color` did not convert** the uniform in 2D.
- **Unresolved:** my verdict on the look. At glow 0.5 he goes ghostly against the sky (the brief's contrast arithmetic predicted 1.27 : 1); at 1.0 he is a flat blue-white silhouette with no detail. Options on the table: keep, or cap the target at ~0.7 (driver edit + Revision 3 + test expectation change). _Decision (2026-10-29, after the playtest): neither; make it breathe, 0.4–0.8 at a 1 s period in the driver. My words: "looks good, the blue breathes and this is better than a block of ice blue". See the playtest entry below and CHANGE-BRIEF Revision 3._

### Textures, import settings, and the normal-map check

- **What happened:** the importer's defaults on first import had `detect_3d/compress_to=1` on every PNG, which means the first time the editor draws the texture in 3D it silently reimports as VRAM Compressed. Set every value explicitly (Lossless; normal_map Enable on the two normal maps, Disabled elsewhere; mipmaps on for the 1K maps; detect off) and reimported; the values survived. The imported normal map is RGBA8 (brief's F9 ruled out); roughness imported as single-channel L8.
- **Calibration:** the assignment's `curl_ratio` on the Poly Haven GL/DX pair: GL file 0.54 as GL / 1.46 as DX, DX file the mirror image. Not ~0/~2, because Godot loads the 16-bit PNGs as 8-bit and quantization pulls toward 1, as the assignment's note says. Threshold set from the pair: below 1.0 in the right convention. Sign convention correct as given.

### The hint experiment under Compatibility

- **I expected (brief):** colour quad 64/128/192, data quad 137/188/225, with the caveat that Compatibility must be measured first.
- **What happened:** both quads 64/128/192. A first sampling attempt read 64 everywhere because it hit the 0.25-grey background (also 64) through the same stretch mistake; the fixed samples sit on flat band centres (5 × 5 min = max).
- **What I learned:** the Compatibility renderer shades 3D in sRGB space; there is no linear stage for `source_color` to decode into and no encode on output, so both samplers return the file's numbers. The hint still matters, and on Forward+ or Mobile the data quad would read 137/188/225. This is the brief's predicted failure F10, measured.

### Two materials from one shader

- **What happened:** the fresh material goes through the glb importer's Use External (so a reimport keeps it) and the rusty one through a surface override on a second instance; a headless probe showed both resolve. Captures: `rust_amount` 0 → 1 moves the rusty body from (99, 29, 21) to (133, 131, 113); setting one value on one material changed only that hydrant; scaling one `ALBEDO` line in the shader (temporarily, restored with `git checkout`) changed both.
- **Observation:** `roughness_scale` and `normal_strength` barely move the one sampled point (1–3 levels); they change highlights and shading across the surface. Judged by eye in TEST-REPORT. _My verdict (2026-10-29): side by side, "the first hydrant looks very realistic compared to the second, the second looks more like a cartoon"; the roughness and normal-strength sweeps showed no difference I could see under this one sun, and nothing looked broken. "I think we need to improve the structure of the hydrant" is a mesh change the assignment forbids here, so it is the known limitation and next step._

### 2026-10-29 — my playtest, and the glow becomes a breath

- **What I was working on:** the "In play" human check, in the real game window, keyboard.
- **What happened, in my words:** "1 worked, 2 yes, 3 i pressed r when he was glowing and the game restarted, 4 the game paused and asked if i wanted to resume, 5 this will never happen because rescues are after the hose". I also walked into the fire while hosing: he stayed icy blue through the "The fire got you." screen, and the water column froze with him.
- **What I asked:** "is the firefighter when hosing just supposed to look icy blue or glow and fade non stop" and "are we supposed to see his suit". Claude compared both options against the assignment text: a pulse written with `TIME` inside the shader would change my colour line and break the fixed-value predictions, a pulse in the driver keeps the shader untouched, and a plain cap at 0.7 is the smallest change. I chose **make it breathe** (band 0.4–0.8, 1 s period, in the driver). This is the inspect-and-revise cycle driven by looking at the screen; Revisions 1 and 2 had come from reading code.
- **What I learned:** the fade-down on R is real (the test shows it) but invisible in play because R also teleports him; and a fire death does not reset the water the same frame, it waits out the 2 s hold, so my brief's R7 wording was wrong. Both are in Revision 3. The fire-death glow was accepted, because the game already freezes the water visual during the hold.
- **Rejected:** the `TIME`-based pulse (would move the colour line) and reading `session.state` in the driver to stop the glow on death (widens the boundary for a cosmetic gain).
- **Traceability:** Revision 3 commit; the driver/test change is the agent's `session-4-breathe.jsonl`; screenshots `a5/evidence/playtest-*.png` (OS screenshots, labelled, not used for pixel values).

### 2026-10-29 — the language notes

- **What happened:** I asked Claude to write `a5/LANGUAGE-NOTES.md` for me, several times. It declined every time, on the assignment's own rule that the answers are mine and a TA can ask them face to face, and offered to explain any line instead. It gave a plain-English crib for each question pointed at lines in my shaders. I then wrote the eight answers myself in chat and sent them over.
- **Division of work:** the answers are my words, pasted in unchanged. Claude filled the section 1 line-number table from the generated file, added the _Lines:_ note under each answer, and verified every line reference with `sed`/`grep` against the shader files before committing. One path it first cited for the driver was wrong (`godot/scripts/`), caught by that check and corrected to `godot/features/player/hose_glow.gd`.
- **The annotated generated shader:** I asked Claude to write the line-by-line annotation of `standard_generated.gdshader`; it is in `a5/STANDARD-GENERATED-ANNOTATED.md`, labelled as agent-written and reviewed by me. The assignment names the shaders, the hint shader and the language notes as the parts I must write myself, and this annotation of Godot's own code is outside that list; I still have to be able to explain each line. Claude also closed the two "pending" verdict lines above by copying my recorded words from TEST-REPORT.

### 2026-10-29 — building the film, and two things it turned up

- **What happened:** the film (Brutalist `godot-gamedev`, walker) was built from the record: script in four drafts (v2 more technical at my request, v3 plainer, v4 the 5½-minute cut), approved by me; a Movie Maker take of the real game with scripted key presses (`youtube/…-a5-gamedev/capture/film_capture.gd`), labelled as scripted, not as my playtest. The first take paused itself at 1.35 s because the game pauses on window-focus loss and Movie Maker runs unfocused; `test_mode` turns only that off.
- **Two things it turned up:** (1) my two playtest screenshots were whole-desktop captures with other windows around the game; Claude noticed while composing the film and cropped both to the game window (TEST-REPORT "Screenshots"). (2) The brief's evidence split lists `Engine.time_scale = 0.5` as a check for my eyes, and I have not done it; TEST-REPORT now says so under Open items instead of leaving it implied.
- **Division of work:** Claude Code wrote the script from my decisions and words, the stills from the committed captures and logs, the capture driver, the beat sheet and the build; I chose the register and length and approved the script. Narration is Liam (Kokoro), not me.
- **Gates:** the first export was refused twice. Once because the toolkit's gate scripts ran under a Python without Pillow (fixed by putting the toolkit venv on PATH), then because the type gate flagged four beats: captured game pixels inside figure cards, and the game's own HUD text at the frame edge of the footage, both read as if they were the film's typography. The fix kept the rule rather than loosening it: the three capture-based figures became full-frame screen composites with a provenance plate (how the A3 film showed screenshots) and the take is typed as raw video. Second export: GATE T PASS, Gate V clean, 6 min 22 s.

## Human / AI contributions

| | Human (me) | AI (Claude Code, `claude-fable-5-1`) |
|---|---|---|
| Decisions | the state (hosing glow), colour, timing shape, textures, how the materials differ, "approve" on the driver plan, the commit order | listed the options, recommended defaults |
| Shaders | typed all three in TextEdit; fixed my own missing first lines | explained each line; checked each file on disk and headlessly; never edited one |
| Brief, CLAUDE.md | read and reviewed; the two revisions were found by Claude and accepted by me | drafted both from my decisions and the code; the CLAUDE.md draft came from a read-only `claude -p` run, the review edits from the interactive session |
| Driver, tests, captures, audit | approved, read the test for the recorded mistake, performed the mutations' commands through Claude | wrote all of it |
| Test report, this log, sources | reviewed; verdict lines are mine to fill | drafted from the session |
| Language notes | wrote all eight answers | filled the line-number table, added and verified the line references; declined to write the answers |
| Annotated generated shader | asked for it, reviewed it | wrote `a5/STANDARD-GENERATED-ANNOTATED.md` from Godot's file, labelled as such |
| Film | chose register and length, approved script v4, will watch the export | script, stills, scripted-input capture, beat sheet, render, QC (`youtube/claude-liam-walker-ninja-firefighter-joe-a5-gamedev/`) |
| Rejected | Claude declined to record agent-typed shader code as mine; I then typed it | — |
