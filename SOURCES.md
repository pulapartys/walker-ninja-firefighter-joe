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
