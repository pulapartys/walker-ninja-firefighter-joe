# SOURCES

## Started from

- **My Assignment 1 project, `walker-jumpman-joe`** (firefighter rescue). The Godot project (`godot/`) was copied on 2026-10-01: control and retry engine, state machine, level, hose and rescue mechanics, timer, and tests.
- That project extended **[nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman)** ("First Steps" starter).

## Generative models

| Model | Version | Where it ran | License / terms | Used for |
|---|---|---|---|---|
| ChatGPT image generation | "Instant" mode; the image model name is not shown in the app | chatgpt.com, **ChatGPT Plus (paid subscription)** | OpenAI Terms of Use | storyboard sketches (SB-01 … SB-06) |
| Gemini (image) | | Northeastern access / free tier | | |
| Suno | | free tier | Free tier: non-commercial use; acceptable for coursework | |

## Tools (not generative)

- macOS `sips`: resizing images (panels to 1280 px wide, rejects to thumbnails).
- Audacity: trimming, loop points, export to OGG (the class repo ignores WAV).
- Claude Code: code, prompts, plans, and document drafting. Not an image or audio generator.

## Asset log

- One row per generation kept or seriously considered, including rejects.
- All storyboard prompts are recorded verbatim in STORYBOARD.md, section "Revision 2026-10-02", under the matching ID.
- Every SB row below was made with ChatGPT Plus (paid), Instant mode, after the base style prompt, in one chat.
- **Edits on every accepted panel:** resized with `sips` from 1672×941 to 1280×720.
- **Tries:** only the saved download was recorded for each panel.

| Asset ID | Prompt | Outcome and reason | Where used |
|---|---|---|---|
| SB-01 | Panel 1 | **Accepted** with one difference: the character came back large in the foreground instead of "small at the far left." **Generated before the storyboard text was committed** (text written 2026-10-01; image saved 2026-10-02 10:20; storyboard committed 10:22). | `design/storyboard/01-first-look.png` · Panel 1 |
| SB-02 | Panel 2 | **Accepted:** martial-arts stance, hose held like a weapon, water arrow, shrinking-flame arrow, eye level. His face is stern rather than bored. | `design/storyboard/02-core-action-hose.png` · Panel 2 |
| SB-03 attempt 1 | Panel 3, attempt 1 | **Rejected:** he carries the person in his arms, but in the game a rescued survivor rides as a head in the rescue bag on his back (`session.gd`, `player.gd`). The prompt never mentioned the bag. | not saved (no thumbnail) |
| SB-03 attempt 2 | Panel 3, attempt 2 (reckless toss) | **Superseded:** the toss into the bag matches the mechanic, but I split the rescue into three beats (3a–3c) instead. | thumbnail `rejected/SB-03-attempt2-single-toss.png` |
| SB-03 strip | 3a + 3b + 3c prompts sent together in one message | **Kept as reference only:** the content was right, but it came back as one 2172×724 strip of square frames, which breaks the single 16:9 frame shape. Also changed 3a so the person stays inside the window. | thumbnail `rejected/SB-03-strip-wrong-frame-shape.png` |
| SB-03a | Panel 3a, attempt 2 | **Accepted:** the person is inside the window; his arm reaches into it and grabs the collar; serious face. | `design/storyboard/03a-grab.png` · Panel 3 |
| SB-03b | Panel 3b, attempt 2 | **Accepted:** the person flies into the bag; his eyes are closed and a hand covers a yawn. | `design/storyboard/03b-throw.png` · Panel 3 |
| SB-03c | Panel 3c, attempt 2 | **Accepted:** the person is dazed in the bag with swirly eyes and a star; stern face, walking away. | `design/storyboard/03c-in-bag.png` · Panel 3 |
| SB-04 | Panel 4 | **Accepted:** close-up, huge devastated face, soot, debris, shake lines, tilted angle. | `design/storyboard/04-failure-burned.png` · Panel 4 |
| SB-05 | Panel 5 | **Accepted:** true high angle, ninja-run shuffle, arrow path with a jump arc over the ground flame. | `design/storyboard/05-retry.png` · Panel 5 |
| SB-06 | Panel 6 | **Accepted with a mismatch:** flying kick, arc, three-point landing, bored face; but the bag shows two people and a dog (the game has one person and one dog). | `design/storyboard/06-end-escape.png` · Panel 6 |

### Character exploration

Prompts are verbatim in CHARACTER-SHEET.md, "Revision 2026-10-02". All were made with ChatGPT Plus (paid), Instant mode, in a separate chat from the storyboard. Thumbnails were resized with `sips` to 900 px wide.

| Asset ID | Outcome and reason | Where kept |
|---|---|---|
| CHAR-EXPLORE-01 | Four looks (A–D). **Chose A** (Shinobi Smoke-Eater); wanted him more muscular and less comic-book. **Prompt not yet recorded.** | `design/character/explore/CHAR-EXPLORE-01-four-looks.png` |
| CHAR-EXPLORE-02 | Three builds of A on gray. **Chose A3's build**; still too cartoonish; wanted a cream background. | not downloaded (no thumbnail) |
| CHAR-EXPLORE-03 | Three realism levels (R1–R3), crusty and ashy, on cream. Red and yellow still read; posed in three-quarter view, not pure side view. R2/R3 body and skin chosen; **all three faces still cartoonish.** | `design/character/explore/CHAR-EXPLORE-03-crusty-R1-R3.png` |
| CHAR-EXPLORE-04 | R2 + R3 combined with a realistic face. **Kept as the master reference.** Game-size test: the silhouette reads, but the soot mutes the red and yellow and the face disappears at 32 px. Still three-quarter view. | `design/character/explore/CHAR-EXPLORE-04-realistic-face.png`; test images in `design/character/size-test/` |
| CHAR-REF-01 | Turnaround (front, side, ¾, back, height bar) from CHAR-EXPLORE-04. **Accepted**; weakness: the "side" view is nearly three-quarter. Resized to 1200 px wide. | `design/character/turnaround.png` |
| CHAR-REF-02 | True side profile from the turnaround. **Accepted**; the reference for every pose. Resized to 800 px wide. | `design/character/side-profile.png` |
| CHAR-EXPR-01 | Four-expression sheet. **Revising:** GRUMPY and SERIOUS look alike, BORED has no yawn, DEVASTATED is too subtle; adding hands on his head (my decision). | thumbnail `rejected/CHAR-EXPR-01-expressions-v1.png` (720 px wide) |
| CHAR-EXPR-02 | Revised expression sheet. **Accepted for now:** BORED (yawn) and DEVASTATED (hands on helmet) fixed; **GRUMPY reads as sleepy, open to revisit.** Resized to 1200 px wide. | `design/character/expressions.png` |
| CHAR-REF-03 | Game-readable side profile from CHAR-REF-02 (sprite approach B). **Accepted:** same gear and proportions, brighter red and yellow, lighter soot. At 32 px neither A nor B read; at the real on-screen size, and bigger, B reads best against the flames. Decided to make the character bigger in the game (exact size chosen during the build). Resized to 800 px wide. | `design/character/side-profile-game.png`; size tests in `design/character/size-test/CHAR-REF-0*` |
| CHAR-RESPAWN (pose 1, sent as CHAR-IDLE) | Kung-fu ready stance from CHAR-REF-03. Generated 2026-10-03. Gear, colors, and pose match; **not a true side profile** (chest turned about three-quarter, predicted failure F1). **Accepted 2026-10-05 as respawn / ready** (panel 5); idle uses CHAR-REF-03's true-side standing pose instead. Resized to 1025 px wide (same 0.78 scale as CHAR-REF-03). | `design/character/poses/pose01-respawn.png` |
| CHAR-WALK (pose 2, try 1) | Header only from CHAR-REF-03; **I forgot the "Pose:" line.** Came back as a calm walk, but a true side profile: the new "fully sideways" header sentence fixed the drift. **Superseded** by try 2 (I wanted a real run). | thumbnail `rejected/CHAR-WALK-pose02-header-only.png` (400 px wide) |
| CHAR-RUN (pose 2, try 2) | Edit of try 1's image into a low ninja dash. **Accepted:** true side profile, matches the reference, strongest "kata" pose. Wide and low (1536×1024), so art extends past the collision box. Resized to 1198 px wide. | `design/character/poses/pose02-run.png` |
| CHAR-STANCE (pose 3) | Crane stance from CHAR-REF-03 (jump crouch). **Accepted, first try:** the pose as asked, side profile (very slight chest turn), matches the reference. Resized to 800 px wide. | `design/character/poses/pose03-jump-crouch.png` |
| CHAR-RISE (pose 4, try 1) | Flying side kick from CHAR-REF-03 (rising). Strong kick, gear matches; **three-quarter view** (F1) and the torso is upright, not horizontal. **Superseded** by 4b. | thumbnail `rejected/CHAR-RISE-pose04-three-quarter.png` (400 px wide) |
| CHAR-RISE (pose 4b, edit) | Edit of try 1: change only the camera angle to a true side profile and lean the torso more. **Accepted:** head in profile, tank and axe now on his back, slight chest still visible from the spread arms. Resized to 1198 px wide. | `design/character/poses/pose04-rising.png` |
| CHAR-FALL (pose 5) | Cross-legged "meditating" fall from CHAR-REF-03. **Accepted, first try:** the pose as asked, true side profile, matches the reference. Resized to 800 px wide. | `design/character/poses/pose05-falling.png` |
| CHAR-LAND (pose 6, try 1) | Low ninja landing from CHAR-REF-03, with the dust puff I asked for. The pose and side view are right, but the cream-colored dust would ruin the background removal. **Superseded** by 6b. | thumbnail `rejected/CHAR-LAND-pose06-dust.png` (400 px wide) |
| CHAR-LAND (pose 6b, edit) | Edit of try 1: remove all the dust. **Accepted:** the dust is gone, everything else identical. Resized to 1198 px wide. | `design/character/poses/pose06-landing.png` |
| CHAR-SPRAY (pose 7, try 1) | Hose stance from CHAR-REF-03, no water (the game draws the water). Pose and side view right, but **the hose runs off the left edge**, so it would end in mid-air in the game (my catch). **Superseded** by 7b. | thumbnail `rejected/CHAR-SPRAY-pose07-hose-off-edge.png` (400 px wide) |
| CHAR-SPRAY (pose 7b, edit) | Edit of try 1: hose fully in frame, connected to the tank. **Accepted:** nothing touches the edges. Resized to 1198 px wide. | `design/character/poses/pose07-hose.png` |
| CHAR-RESCUE (pose 8) | Grab from CHAR-REF-03, with nobody in the image (the game draws the survivors). True side profile, stern face. **Accepted with notes:** the fist reads more like a punch than a grab; an extra thigh pouch (gear drift). Resized to 800 px wide. | `design/character/poses/pose08-grab.png` |
| CHAR-TOSS (pose 9, try 1) | Toss from CHAR-REF-03, nobody in the image. True side profile and mid-yawn as asked; the arm is flung sideways; extra thigh pouch again. **Superseded by my design change:** the toss should go **upward**, sky-high. | thumbnail `rejected/CHAR-TOSS-pose09-sideways.png` (400 px wide) |
| CHAR-TOSS (pose 9b, edit) | Edit of try 1: arm flung straight up, slight lean back, remove the extra pouch. Arm up, yawn kept, pouch gone, true side profile; fingertips about 10 px from the top edge. **Accepted.** Resized to 800 px wide. | `design/character/poses/pose09-toss.png` |
| CHAR-BURNED (pose 11) | Burned pose from CHAR-REF-03: hands clutching his helmet, heavy soot with colors still visible, thin dark smoke; side view. Smoke touched the top edge. **Accepted with a hand edit:** the top 60 px faded into the background so the smoke tips fade out (Python/Pillow script by Claude). Resized to 800 px wide. | `design/character/poses/pose11-burned.png` |
| CHAR-BURNED (pose 11b, edit) | Edit to shorten the smoke. ChatGPT offered two versions; both fixed the smoke but **drifted to three-quarter** (F1). **Rejected.** | thumbnail pending (`rejected/CHAR-BURNED-pose11b-three-quarter.png` once saved) |
