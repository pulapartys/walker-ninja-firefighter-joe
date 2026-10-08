# SCRIPT DRAFT v2 — for you to read and edit before anything is voiced

**Film title (the outro re-reads it exactly):** *Extinguisho: Generated Art, Sound, and Music in Godot*
**Workflow:** Brutalist `godot-gamedev`, `walker` mode · narrator: Liam, Brutalist's local Kokoro voice · native 4K, landscape
**Source revision shown:** `241c3f2` (frozen game source) · Godot 4.7.2 · macOS
**Started from:** Sreeja's Assignment 1 project, `walker-jumpman-joe` (which extended walker-jumpman)

**What changed from v1 (your notes):** more technical beats (marked ⚙); Liam introduces himself only as Brutalist's narrator, so it's clear Professor Bear didn't work on this project; the game is presented as Sreeja's, with the tools assisting her ideas: said subtly in **three** places (B01, B05, B21), plus the required contributions line in the credits beat (B25); a beat that shows **every pose in play** (B10); and the requirement evidence in priority order (art in the slice → sound → music → mute and muted play → verification → asset log → design docs).

How to edit: change any **Liam says** text freely; cross out beats with ~~strikethrough~~; add `> NOTE: …` anywhere. Rough length: about 9 minutes (the narration sets the clock).

Labels the film must carry: code views are "Godot editor reconstruction" with file and line numbers; gameplay is "scripted-input capture, Godot Movie Maker, revision 241c3f2"; generated images are "raw generation" or "edited generation", never presented as in-engine footage; diagrams are "explanatory diagram".

---

## Opening (walker bookends)

### B00 — The prompt *(Claude composer; illustrative reconstruction)*
**On screen:** a Claude prompt box typing, labeled "Illustrative reconstruction — not a session transcript".
**Prompt text:** "Please use Walker to convert my game design document about a deadpan ninja firefighter who has forty seconds to rescue a person and a dog from two burning buildings into a playable Godot asset slice with generated art, sound, and music."
**Liam says:** Please use Walker to turn a game design into a playable Godot slice, with generated art, sound, and music. I'm Liam, the narrator voice of the Brutalist toolkit. This is Assignment Two for C S Y E seventy-two seventy, and the game is called Extinguisho.

### B01 — What was built *(hesitant-writer summary, with one correction)* · **Sreeja mention 1**
**On screen:** the summary being typed, one word struck out and corrected.
**Liam says:** Extinguisho is Sreeja's game. It grew out of her Assignment One firefighter platformer: one level, two burning buildings, and a forty-second clock, now played by a generated ninja firefighter, with a generated skyline and flames, five generated sound effects, and a looping track. This is an asset slice, not the full game. We'll trace how each piece was designed, generated, edited, and wired into Godot.

---

## 1 · Design first

### B02 — The concept and four pillars
**On screen:** CONCEPT.md, the pillar table highlighted row by row; a still from play.
**Liam says:** Extinguisho is a grumpy, unimpressed ninja firefighter. Four pillars set the bar for every asset. Race the flames: the clock and the fire push you. Too cool to care: nothing impresses him. Every move is a kata: movement reads as martial arts. And failure is a punchline: dying should be funny, so retrying feels good.

### B03 — Storyboard and character sheet as the specification
**On screen:** the six storyboard panels in sequence; the character sheet: silhouette strip, collision overlay, palette.
**Liam says:** The storyboard and the character sheet came first, and every prompt was checked against them: twelve labeled poses, a silhouette at real game size, a collision overlay, a five-colour palette, and consistency rules. The log is honest about order: the concept, sheet, and change brief were committed before any generation; the storyboard text, two minutes after the first sketch.

---

## 2 · Generated art in the slice *(highest priority)*

### B04 — One reference, every pose ⚙ *(explanatory diagram)*
**On screen:** side-profile-game.png in the middle, arrows to the twelve poses; a note "each prompt attaches this image".
**Liam says:** Consistency comes from one reference image, not from repeating text. Every pose prompt attached the same side profile. When a new prompt drifted into a three-quarter view, an edit of the existing image usually fixed it, and every edit was checked against the reference again, because an edit can fix one thing and break another.

### B05 — One asset traced: storyboard to raw output · **Sreeja mention 2**
**On screen:** storyboard panel 3b (sideways toss, "storyboard sketch"), then the pose 9 prompt and the raw try-1 image ("raw generation, rejected").
**Liam says:** Let's trace one asset. Storyboard panel 3b is the rescue: he tosses the survivor into his bag without looking, mid-yawn. The first generation did exactly that, sideways. Looking at it, Sreeja changed the idea: the toss should go straight up, sky-high, with the survivor dropping into the bag.

### B06 — The edit
**On screen:** the 9b edit prompt and the accepted image ("edited generation").
**Liam says:** So the next step was an edit, not a new prompt: keep the character and the view, change only the throwing arm, and remove a thigh pouch that had drifted in. The accepted image is the toss you'll see in the game.

### B07 — From image to game texture ⚙ *(tools/make_sprites.py; explanatory)*
**On screen:** the raw image → background removed → scaled → texture, with the anchor dot at the feet; `anchors.json` excerpt.
**Liam says:** Before the engine, a script removes the flat cream background with a flood fill from the image border, scales every pose by one shared factor so proportions match, and records an anchor at the feet. Each texture is a hundred and twenty-eight pixels tall, drawn at half size: sixty-four game pixels, a hundred and twenty-eight on screen.

### B08 — Code: one image per state *(Godot editor reconstruction: player.gd, show_pose)*
**On screen:** `show_pose` lines.
**Liam says:** In Godot, a state is one static image. Show pose swaps the texture, places it by its feet anchor, and flips the holder's scale when he faces left. No animation: the state change is the image change.

### B09 — Result: the toss in play *(scripted-input capture)*
**On screen:** grab, toss pose, the survivor flung up, spinning, dropping into the bag.
**Liam says:** And here is that toss in the running game. The rescue counts the instant he touches the survivor; the arc is drawn afterwards, so it can never change what happens.

### B10 — Every pose in play *(scripted-input capture, labeled per state)*
**On screen:** a labeled sequence of real play, one caption per state: idle · run · flying kick · landing · meditating fall (missed jump) · hose · grab · toss · burned · respawn · bow · facing left. A small card notes "jump crouch (crane): on the sheet, dropped from the game in playtest 1".
**Liam says:** Every state the sheet promised, in real play: idle, run, the flying kick, the landing, the meditating fall when he walks off a ledge, the hose, the grab and toss, burned, the respawn stance, and the bow. Facing left mirrors the same images. The crane crouch stayed on the sheet: in play it flashed by too fast to read.

### B11 — Code: picking the state *(Godot editor reconstruction: player.gd, _update_pose)*
**On screen:** `_update_pose` lines.
**Liam says:** Update pose decides which image shows. Timed action poses come first, then air, then ground. A jump is one kick from takeoff to touchdown, then a landing held for a third of a second. That rule came from a playtest where three poses flashed in a single jump.

### B12 — Result: the jump read clearly *(scripted-input capture)*
**On screen:** a jump in real time, then the same jump with the pose name captioned.
**Liam says:** Run, kick, land: three images, each on screen long enough to read.

### B13 — Code: the collision box ⚙ *(Godot editor reconstruction: player.gd, BOX)*
**On screen:** `const BOX := Vector2(20, 40)` and the collider placed half its height above the feet.
**Liam says:** Collision is a separate object from the art. The box is twenty by forty game units, centred twenty above the feet, sized from the crouching poses so it never floats above his head while he runs.

### B14 — Result: art against the box *(diagnostic overlay on real screenshots)*
**On screen:** character-vs-sheet rows with the cyan box drawn at the recorded position.
**Liam says:** Drawn on real screenshots, the helmet, the kick, and the hose reach past the box. That only forgives the player. Art smaller than the box would kill without visible contact; there is none.

### B15 — The environment: background and flames ⚙
**On screen:** ENV-BG v2 behind the level; the three flame images on green → keyed out → drawn over the unchanged hazard rectangles.
**Liam says:** The environment is generated too: a smoky skyline behind the level, and three flame images generated on flat green, keyed out by colour, and drawn over the hazard rectangles. The rectangles, not the pictures, still decide what burns, so the jump-clearance tests still pass.

---

## 3 · Cause and effect: the background

### B16 — The problem *(screenshots)*
**On screen:** a frame with ENV-BG version one: the red suit against the orange glow.
**Liam says:** One revision changed what the player sees. In the third playtest, the firefighter disappeared against the first background: its orange glow sat at his height, nearly the colour of his suit.

### B17 — The change and the result *(screenshots + numbers)*
**On screen:** the v2 edit prompt with the in-game screenshot attached; the same moment with v2; "suit vs background, worst spot: ΔE 31 → 85".
**Liam says:** An outline around him was tried and rejected: the background had to change, not the character. Regenerated as a cool blue-grey haze, the colour difference between his suit and the background, at its worst spot, rose from thirty-one to eighty-five.

---

## 4 · Sound effects *(next priority)*

### B18 — Five sounds, cleaned the same way ⚙ *(explanatory diagram)*
**On screen:** the five sounds as waveforms: raw → trimmed → levelled; a table: event → sound.
**Liam says:** Five sound events: jump, hose, rescue, the fire death, and the win. Each was trimmed so it starts instantly, brought to the same loudness, minus fourteen L U F S with a limiter just under full scale, and saved as Ogg Vorbis for Godot.

### B19 — Code: sounds follow events ⚙ *(Godot editor reconstruction: session.gd)*
**On screen:** the `jumped` signal in player.gd; `play_sfx("burn")` after the state becomes DYING; `play_sfx`.
**Liam says:** Each sound plays from the code that already represents its event, after the state changes. The jump is a signal the player emits once per real jump; the burn plays once the game is already dying. The guards that stop a double event also stop a double sound, and nothing in the game ever reads a sound back.

### B20 — Game audio, no narration *(labeled segment)*
**On screen:** label "GAME AUDIO — no narration · scripted-input capture, Godot Movie Maker, revision 241c3f2". A real run: the music; jump whoosh; hose blast; the slide-whistle toss; the fire death sizzle and yelp with the DEVASTATED close-up; the win cheer with the bow close-up.
**Liam says:** *(nothing: the game's own sound only, about 25 seconds)*

---

## 5 · Music, mute, and readable when muted

### B21 — The loop ⚙ *(explanatory diagram)* · **Sreeja mention 3**
**On screen:** the raw recording's waveform; the 16-bar window 14.10–39.70 s highlighted; the 10 ms crossfade at the seam.
**Liam says:** For the music, Sreeja kept the second version, the one with taiko drums and plucked strings that fit the ninja idea. It plays at a hundred and fifty beats per minute, so one bar is one point six seconds. Sixteen bars, twenty-five point six seconds, were cut where the last bar best matches the first, with a ten-millisecond crossfade at the seam, and set about six decibels under the effects.

### B22 — Code: the music follows the state *(Godot editor reconstruction: session.gd, _process)*
**On screen:** the `match state` block; the two audio buses.
**Liam says:** Music and effects run on two separate audio buses. The music plays while you play, pauses in place, dips under the burn, carries on after a retry without restarting, and stops at the win. N mutes the music, B the effects.

### B23 — Result: muted play is still readable *(scripted-input capture)*
**On screen:** "MUSIC OFF · SOUND OFF" in the HUD; HELP!, SAVED!, "You fell.", "Out of time!", the DEVASTATED and bow close-ups.
**Liam says:** With everything muted, every event still has something to see: a help bubble, "Saved!", the reason for each death, and the two close-ups.

---

## 6 · Verification

### B24 — Result: the tests that were added ⚙ *(recorded test output; fresh copy)*
**On screen:** the actual output of the three suites from a fresh copy: 41, 14, 14 passes; highlighted lines from test_audio.
**Liam says:** Verification ran from a fresh copy with no cache. The added sound test steps the game one physics tick at a time, so runs are identical: thirteen jumps make thirteen jump sounds, one hose, two rescues, one win. A held key, a mashed key, and a duplicate death each make one sound, and the same route, muted or with every sound file removed, ends the same, tick for tick. A test can count sounds; whether they sound right took a human listen.

---

## Closing (walker bookends)

### B25 — Verdict and credits
**On screen:** verdict columns (works / limits / human judgment); then a table: ChatGPT → images; ElevenLabs Sound Effects → sounds (elevenlabs.io); Eleven Music → loop ("Created in collaboration with ElevenLabs"); Claude Code → code, prompts, tests, this script; Brutalist → this film.
**Liam says:** The verdict. Working: eleven generated states on real events, a generated environment, five sounds that each fire once, a seamless loop, separate mutes, and a clean run from a fresh copy. Limits: his face doesn't read at sixty-four pixels, so the punchlines live in two close-ups; the level, survivors, and bag are still drawn in code; and the muted playtest is the thinnest evidence. ChatGPT made the images, ElevenLabs the sounds and music, Claude Code the code and tests. Every idea, generation, and accept-or-reject decision was Sreeja's. Source revision two-four-one-c-three-f-two.

### B26 — Your Turn
**On screen:** a Walker prompt card.
**Prompt text:** "Read my CHANGE-BRIEF and add a fall state and sound for 'You fell.': generate the pose from my side-profile reference, wire the sound to the existing DYING branch, and predict which test catches a double sound."
**Liam says:** Your turn, one step toward the full game: falling deaths are silent today. Ask Walker for a fall pose and its own sound, wired into the state that already exists. Predict what could fire twice, and let the sound test prove it before you trust it. This has been Liam, from Brutalist.

### B27 — Outro *(locked card)*
**On screen:** ClaudeTitleOutro: the exact title, @NikBearBrown, mascot.
**Liam says:** Extinguisho: Generated Art, Sound, and Music in Godot. At Nik Bear Brown.

---

## Notes and open questions
- **Sreeja count:** B01, B05, B21 subtle, plus B25's contributions line (required by the assignment). If B25 feels like a fourth, tell me and I'll rephrase it as "the student".
- **Liam's line:** the Brutalist skill's standard intro is "Liam, in for Professor Bear". I changed it to "the narrator voice of the Brutalist toolkit", so it doesn't suggest he worked on this project. The outro card still shows @NikBearBrown, because the skill locks that card.
- **Title:** keep it?
- **Game-audio segment (B20):** uses Brutalist's `preserve` beat, labeled. Anything different from the TA?
- **Facts to confirm:** your muted playtest result changes B23/B25 wording.
