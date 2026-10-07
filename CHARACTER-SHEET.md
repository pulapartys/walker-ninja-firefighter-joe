# Character sheet — Extinguisho

> v1 · 2026-10-01 · written before any generation. Images in `design/character/` are added after generation as later revisions; this text is the contract they are judged against.

- **Concept in one sentence:** a deadpan ninja firefighter who does everything with kung-fu flair and never looks impressed, until fire touches him and his face falls apart comic-book style.
- **Silhouette at on-screen size:** `design/character/silhouette.png`. Solid black, about 32 px tall in the 640×360 game viewport. *(Added after the reference is chosen.)*
- **Orientation:** drawn facing **right**; left is flipped at runtime. No left-facing frames are generated.
- **Reference:** `design/character/turnaround.png`: front, side, three-quarter, and back at the same height, with a height bar. Every pose is derived from this one reference.

## Look: fixed and still open

**Fixed (my decisions):**
- A firefighter first, and readable as one: helmet, protective suit, hose.
- **Yellow helmet or cap.**
- **Heat-protective suit, mostly red.**
- **Ninja elements:** a face wrap or mask and martial-arts posture.
- **Face:** a flat, grumpy, serious, unbothered default; **devastated, comic-book** when burned.

**Open, decided by generating candidates and testing them** (logged in FRICTIONAL.md):

| Candidate | Description |
|---|---|
| A — Classic plus ninja | A standard firefighter look with a ninja face wrap and headband tails. |
| B — Full ninja heat suit | A fitted red heat suit like a martial-arts uniform, with a yellow helmet over the ninja wrap. |
| C — Big-head comic | Chunky, big-head proportions, which give the face more pixels at 32 px. |

**The winner must pass all of these:**
1. It reads as a firefighter **and** a ninja in the solid-black silhouette at 32 px.
2. The grumpy face and the devastated face are distinguishable at 32 px.
3. It stays visible next to the fire (see Palette).
4. It still works when flipped left.

## Poses

Each pose is labeled with the game state it serves; the state names match `godot/game/session.gd` and `godot/features/player/player.gd`.

| # | Pose | Game state it serves | Plays |
|---|---|---|---|
| R1 | Turnaround (front, side, ¾, back, height bar) | reference only | — |
| R2 | Silhouette at game size | reference only | — |
| 1 | Idle: arms crossed, grumpy | on the floor, not moving | loop |
| 2 | Walk: contact | on the floor, moving | loop |
| 3 | Walk: passing | on the floor, moving | loop |
| 4 | Kung-fu stance (jump anticipation) | the first frames of a jump (see note) | once |
| 5 | Rising: flying kick | in the air, moving up | once |
| 6 | Falling: arms out, still unimpressed | in the air, moving down | once |
| 7 | Landing: three-point kung-fu landing | touching the ground after air time | once |
| 8 | Hose spray: ninja stance, hose forward | while the water is pouring (W) | loop |
| 9 | Rescue: grabs a survivor, deadpan | the moment a survivor is rescued | once |
| 10 | Burned: comic devastated face, smoke | death by fire (`DYING`) | once |
| 11 | Celebrate: deadpan bow | level complete (`COMPLETE`) | loop |

**Note on pose 4:** the game jumps the instant the key is pressed, and I am not adding a delay because it would change how the jump feels. The stance shows only for the first 2–3 frames of the jump, or it is used on the sheet only. To decide during the build.

## Collision overlay

`design/character/collision.png` shows the collision box drawn over each pose at the same scale. *(Added after the poses exist.)*

- **Shape:** an 18 × 28 px rectangle, feet at the origin. It is unchanged from Assignment 1, so jump distances and fire margins stay the same.
- **The body (torso, legs, head) stays inside the box.**
- **Art beyond the box:** the flying-kick leg, the hose, and the helmet brim.
  - **Why this is fair:** art beyond the box can only make the game more forgiving. A kick that visually brushes a flame without killing him is acceptable. Art smaller than the box is not, because the player would die without seeing contact.

## Palette

3–6 colors, checked against the environment.

**Environment colors already in the game:**
- Flames: `#d0341a` / `#e0411c` (red), `#f39a1e` (orange), `#ffe95a` (yellow core).
- Sky/background: `#f6f3ec`.
- Building walls: `#e0cdaf`.
- Ledges: `#25354a`.

**Known conflict:** a **red suit** sits on the flame reds, and a **yellow helmet** sits on the flame yellow core. Near fire, he could disappear. This is predicted failure F2 in CHANGE-BRIEF.md.

| Option | Colors | Trade-off |
|---|---|---|
| A — Keep red and yellow, add a dark outline | red suit, yellow helmet, `#1b2a3f` thick outline and ninja wrap | Closest to my idea; relies on the outline to separate him from the fire. |
| B — Deeper red | crimson suit (darker than the flames), yellow helmet, dark wrap | The suit separates from the flames by value, not by outline alone. |

**Test:** place the downscaled sprite on an in-game screenshot next to the blocking fire, then view it at 1× and in grayscale. If it disappears, change the palette and log the change.

**Final hex values:** `#______ #______ #______` *(filled in after the test).*

## Consistency rules

These must be identical in every frame. Generated frames that break them are rejected or edited.

- Head-to-body ratio and total height, measured against the turnaround's height bar.
- Helmet shape and color, and the ninja wrap's position.
- Eye line height. The default expression is grumpy everywhere except pose 10.
- Outline weight: 1 px at game size, the same dark color.
- Feet on the same baseline; facing right.
- Only palette colors are used.

---

## Revision 2026-10-02 — look exploration

### Decisions so far (mine)

| Decision | Detail |
|---|---|
| **Look direction** | **Ancient ninja / kung-fu style combined with firefighter gear.** The storyboard showed the ninja side was too weak (FRICTIONAL, 2026-10-02). |
| **Look chosen** | **A, Shinobi Smoke-Eater:** red hooded ninja wrap suit, yellow firefighter helmet with a shield badge, black face mask, split-toe ninja boots, arm and shin wraps, reflective yellow stripes, a scroll-case air tank, a fire axe worn across the back like a katana, and long red headband tails. B, C, and D were not chosen. |
| **Build** | **A3, balanced athletic:** muscular and strong, adult proportions, not chibi. |
| **Style** | **More realistic, not cartoonish**, and **crusty / ashy:** soot, ash, scorched and frayed fabric, a dented smoke-blackened helmet, grimy stripes, as if he has walked out of a hundred fires. |
| **Mood** | Stated in every prompt: deadpan and grumpy, heavy-lidded unimpressed eyes. |
| **Background** | Plain cream / off-white, so it removes cleanly and matches the game's sky color. |

**Risk noted (Claude):**
- Realistic detail may not read at the sprite's ~32 px game size, and the realistic direction departs from the comic-book art direction in CONCEPT.md.
- **Check:** shrink the chosen version to game size and test it as a silhouette and against the fire colors before generating poses.

### Poses picked from the four-look concept sheet (tentative mapping)

| Pose in CHAR-EXPLORE-01 | Game state | Replaces |
|---|---|---|
| Look A's dashing lunge, headband trailing | walk / run (the game has one speed) | poses 2–3, walk contact / passing |
| Look B's low stance, palm forward | idle / ready | pose 1, arms crossed |
| Look D's wide stance, palm pushing out | hose spray, hose in the pushing hand | pose 8 |

The rescue (pose 9) becomes three beats, from the storyboard's panels 3a–3c: grab (serious), reckless toss (couldn't care less), dazed in the bag (serious). More poses will be chosen as exploration continues.

### Prompt log

All prompts were sent in ChatGPT (Plus, Instant mode). Asset log rows are in SOURCES.md.

#### CHAR-EXPLORE-01 — four looks · sent 2026-10-02 · chose A

- **Prompt:** not recorded. *To fill in from the ChatGPT chat.*
- **Result:** one concept sheet of looks A–D, with poses, a turnaround, and faces for each. Thumbnail: `design/character/explore/CHAR-EXPLORE-01-four-looks.png`.
- **Decision:** A chosen. My notes: build on it, make him more muscular and strong; it looks too much like a comic book character.

#### CHAR-EXPLORE-02 — three builds of A · sent 2026-10-02 · chose A3 · not downloaded

```
Character concept sheet for a 2D side-scrolling video game. Plain flat light-gray background, no scenery, no shadows on the ground.

Show THREE variations of the same character side by side, each full body, in a side view facing right, all the same height. Under each, only the label A1, A2, or A3. No other text.

Character: Extinguisho, a ninja firefighter. An ancient ninja / kung-fu outfit blended with firefighter gear:
- heat-proof red ninja wrap suit with a hood under a yellow firefighter helmet with a front shield badge
- black face mask showing only his eyes
- split-toe ninja boots, cloth wraps on forearms and shins
- reflective yellow firefighter stripes on the sleeves and shins
- an air tank shaped like a scroll case on his back, and a fire axe worn across his back like a katana
- long red headband tails trailing behind him

Build: muscular and strong. Broad shoulders, thick arms, solid chest, adult athletic proportions. Not chibi, not a big head.

Mood: deadpan and grumpy. Heavy-lidded, unimpressed eyes, brow slightly furrowed, as if nothing in the world could impress him.

Style: semi-realistic proportions and anatomy, but clean bold outlines and flat colors, so he still reads clearly as a small game sprite. Not a cartoon.

Variations:
A1: lean, agile ninja build
A2: heavy, powerful brawler build
A3: balanced athletic build
```

- **Result:** three builds on a gray background.
- **Decision:** A3's build chosen. Still too cartoonish; I wanted a white/cream background, not gray.

#### CHAR-EXPLORE-03 — realism levels, crusty and ashy · sent 2026-10-02 · pick pending

```
Take A3 from the previous image and keep his build, outfit, and colors exactly. Change only the art style, to look more realistic and battle-worn.

Background: plain flat cream / off-white, no scenery, no floor shadow.

Show THREE versions side by side, each full body, side view facing right, all the same height. Under each, only the label R1, R2, or R3. No other text.

R1: semi-realistic. Realistic anatomy and fabric folds, soft painted shading, clean outlines.
R2: realistic. Like a high-quality 3D-rendered video game character, with real fabric texture and subtle lighting.
R3: gritty realistic. Visible muscle under the suit, dramatic lighting.

Make him crusty and ashy in every version: soot smeared across his suit and mask, ash dust on his shoulders and helmet, scorched and singed fabric edges, burn marks, a dented and smoke-blackened helmet, frayed headband tails, grimy faded reflective stripes, dirt caked on his boots and wraps. He looks like he has walked out of a hundred fires.

Keep in every version: muscular athletic build, yellow firefighter helmet with a front shield badge, red hooded ninja suit, black face mask showing only his eyes, split-toe ninja boots, arm and shin wraps, reflective yellow stripes, scroll-case air tank, fire axe across his back like a katana, long red headband tails.

Mood: deadpan and grumpy. Heavy-lidded, unimpressed eyes, brow slightly furrowed.
```

- **Result:** three crusty, ashy versions on cream; the red and yellow still read under the grime. Thumbnail: `design/character/explore/CHAR-EXPLORE-03-crusty-R1-R3.png`.
- **Differences:** he is posed in a three-quarter turn, not a pure side view. R3 shows bare, muscular forearms.
- **Decision:** R2 and R3's body, ash, and hand skin look realistic, but the face in all three still looks cartoonish.

#### CHAR-EXPLORE-04 — R2 + R3 combined, realistic face · sent 2026-10-02 · kept as the master reference

```
Take R2 and R3 from the previous image and combine them into ONE character: keep R3's gritty muscular body, bare forearm skin, and heavy ash, with R2's clean realistic rendering. Keep the outfit, colors, crusty soot, and pose exactly.

The main change is the FACE. It still looks cartoonish. Make the visible part of his face fully realistic, like a photoreal video game character:
- realistic adult human eyes with a detailed iris and slightly bloodshot whites, not big cartoon eyes
- real skin around the eyes: pores, creases, crow's feet, a heavy furrowed brow, a scar across one eyebrow
- sweat and soot settled into the wrinkles, ash on his eyelashes
- heavy-lidded, half-closed, unimpressed stare: deadpan and grumpy, a tired veteran who has seen a thousand fires

Single image only: one character, full body, side view facing right, plain flat cream / off-white background, no scenery, no text.
```

- **Result:** one realistic, crusty character on cream with a realistic stern face. Still posed in a three-quarter turn, not a pure side view. Thumbnail: `design/character/explore/CHAR-EXPLORE-04-realistic-face.png`.

### Game-size test of CHAR-EXPLORE-04 (2026-10-02)

**How it was made (Claude, with Pillow):**
- Removed the cream background by color difference and cropped to the character.
- Shrank it to **32 px tall** (17 × 32), the on-screen height in the 640×360 viewport.
- Rendered it as a sprite, a solid-black silhouette, and in a mock scene using the game's sky, wall, ledge, and three flame colors.
- Enlarged the results with nearest-neighbor so the pixels can be seen.

Images: `design/character/size-test/`.

| What | Result at 32 px |
|---|---|
| Silhouette | Reads as a standing figure with a helmet and trailing headband tails. The axe and air tank merge into the body. |
| Colors | The soot turns the red suit muddy brown-red, and the yellow helmet shrinks to a few dull pixels. The red-and-yellow identity is mostly lost. |
| Face | Not visible at all. The realism there only shows in close-ups (storyboard panel 4, the film, this sheet). |
| Against the fire | Stays visible because he is darker than the flames. |

**Conclusion:**
- The realistic, crusty look works as the **master reference** (character sheet, close-ups, film).
- As a sprite, its detail turns to noise. The parts that survive are the silhouette, the headband tails, and color blocks, and the grime is weakening the color blocks.
- **Open decision for the sprite frames:** keep the realistic art as is, or derive a game-readable version from this reference (side view, brighter red and yellow under lighter grime, a bolder axe and headband shape).

---

## Revision 2026-10-02 — reference sheet, side profile, expressions

All prompts below were sent in the same ChatGPT chat as CHAR-EXPLORE-01 … 04 (Plus, Instant mode), with the named image attached.

### CHAR-REF-01 — turnaround · sent 2026-10-02 · accepted with a weakness

Attached: `characterv2.png` (CHAR-EXPLORE-04).

```
Use the attached image as the exact character reference. Keep his face, build, outfit, colors, soot, and gear identical.

Create a character turnaround sheet: the same character shown FOUR times side by side, all at exactly the same height and scale, standing in a neutral relaxed pose:
1. front view
2. side view facing right (true profile)
3. three-quarter view facing right
4. back view (show the air tank, the axe across his back, and the headband tails)

Add a thin vertical height bar on the far left with tick marks, and keep his feet on the same baseline in every view.

Plain flat cream / off-white background, no scenery, no shadows, no text except small labels under each view: FRONT, SIDE, 3/4, BACK.

Mood in every view: deadpan and grumpy, heavy-lidded, unimpressed eyes.
```

- **Result:** four views at the same height, with a height bar, feet on one baseline, and labels. The look matches CHAR-EXPLORE-04.
- **Weakness:** the "SIDE" view is nearly the same angle as the three-quarter view; his head and chest turn toward the camera.
- **File:** `design/character/turnaround.png` (this is the sheet's **Reference**).

### CHAR-REF-02 — true side profile · sent 2026-10-02 · accepted · the reference for every pose

Attached: `turnaround.png`.

```
Use the attached turnaround as the exact character reference: same face, build, outfit, colors, soot, and gear.

Single image only: the same character in a TRUE SIDE PROFILE facing right, full body, standing neutral. Show him exactly from the side, like a silhouette: his chest and shoulders do not turn toward the camera, only one eye is visible, his nose and mask point straight to the right edge of the image. The air tank and axe are visible on his back on the left side.

Plain flat cream / off-white background, no scenery, no shadows, no text.
```

- **Result:** a true side profile: one eye visible, chest not turned toward the camera, tank, axe, and headband clear on his back.
- **Why it matters:** every in-game pose is a side view.
- **File:** `design/character/side-profile.png`.

### CHAR-EXPR-01 — expression sheet · sent 2026-10-02 · revising · not downloaded

Attached: `side-profile.png`.

```
Use the attached image as the exact character reference.

Single image: a row of FOUR close-up head-and-shoulders portraits of this same character, all facing right in side or three-quarter view, same lighting and soot. Only the eyes and brow change, since his mask covers the rest:
1. GRUMPY: default. Heavy-lidded, unimpressed, brow furrowed.
2. COULDN'T CARE LESS: eyes closed, mid-yawn, relaxed brow.
3. SERIOUS: narrowed, focused, stern eyes.
4. DEVASTATED: eyes huge and wide with shock, brows shot up, helmet knocked crooked, face scorched with soot, smoke rising.

Plain flat cream / off-white background. Small labels under each: GRUMPY, BORED, SERIOUS, DEVASTATED.
```

- **Result:** four labeled portraits, consistent helmet, mask, and soot.
- **Problems:**
  - GRUMPY and SERIOUS look almost identical.
  - BORED shows closed eyes but no yawn.
  - DEVASTATED is right (wide eyes, dented smoking helmet) but subtle.
- **Decision (mine):** for DEVASTATED, add **both hands on his head**. **Claude's reason to keep it:** at 32 px the face is invisible, so body language has to carry the emotion. Burned pose 11 gets the same gesture.

### CHAR-EXPR-02 — expression sheet, revised · sent 2026-10-02 · accepted for now, GRUMPY open

Sent in the same chat, editing CHAR-EXPR-01 (no new attachment).

```
Redo this same 4-portrait expression sheet. Keep the character, helmet, mask, lighting, soot, framing, and labels exactly the same. Only change these:

GRUMPY: make it clearly different from SERIOUS: eyes half-closed and droopy, one eyebrow slightly raised, looking unimpressed and annoyed, like he's sick of everyone.
BORED: he is mid-yawn: eyes squeezed shut, head tilted back slightly, one gloved hand covering the mask over his mouth.
SERIOUS: keep as is: narrowed, focused, stern eyes looking straight ahead.
DEVASTATED: widen the shot to show his shoulders and arms. Both gloved hands clutching the sides of his smoking helmet in horror, elbows out, eyes huge and wide with shock, brows shot up, helmet knocked crooked, smoke rising, soot everywhere.
```

**Result vs. the prompt:**
- **BORED:** fixed. Eyes squeezed shut, a gloved hand over his mouth, mid-yawn.
- **SERIOUS:** unchanged, as asked.
- **DEVASTATED:** fixed. Both gloved hands clutch his smoking helmet, eyes wide, and it reads clearly.
- **GRUMPY: still wrong.** The half-closed, droopy eyes read as **sleepy, not grumpy**.

**Decision (mine):** accept the sheet for now and come back to GRUMPY later. GRUMPY is his default face, used in idle, run, jump, and most poses, so it matters.

**Tweak to try** (Claude's suggestion): ask for an active scowl instead of droopy lids: "eyes narrowed into a glare, brow pulled down hard into a deep V, eyes cutting sideways at the viewer, annoyed and irritated, NOT sleepy or tired."

### Pose prompts · planned

Each pose is sent as its own message with `side-profile.png` attached. The header goes first, then one pose line.

```
Use the attached image as the exact character reference: same face, build, outfit, colors, soot, and scale. Single image only: one character, full body, TRUE SIDE PROFILE facing right (chest not turned toward the camera), plain flat cream / off-white background, no scenery, no text.

Pose:
```

| # | Game state | Pose line | Plays |
|---|---|---|---|
| 1 | idle | Low kung-fu ready stance, knees bent, one open palm pushed forward, other fist at his hip. Grumpy, unimpressed stare. | loop |
| 2 | run | Dashing forward in a low lunge, body leaning forward, arms swept back, headband tails streaming behind him. | loop |
| 3 | jump anticipation | Crane stance: one knee raised high, arms spread out like wings, balanced on one foot. Grumpy face. | once |
| 4 | rising | Mid-air flying side kick, front leg fully extended, body horizontal, headband tails flying. Grumpy face. | once |
| 5 | falling | Falling through the air sitting cross-legged as if meditating, arms folded, eyes half-closed, completely calm. | once |
| 6 | landing | Landing in a low ninja crouch, one knee bent deep, one hand flat on the ground, a dust puff at his feet. | once |
| 7 | hose spray | Wide low martial-arts stance, one arm pushing a fire hose nozzle forward, water blasting out. Bored face. | loop |
| 8 | rescue: grab | Reaching forward and grabbing a small shocked person by the back of the collar with one hand. Serious, stern face. | once |
| 9 | rescue: toss | Flinging the person backward over his shoulder into the open rescue bag on his back without looking, eyes closed mid-yawn. | once |
| 10 | rescue: done | Walking away with a dazed small person poking out of the rescue bag on his back. Serious, stern face. | once |
| 11 | burned | Scorched black from head to toe with smoke rising off him, both gloved hands clutching the sides of his smoking crooked helmet in horror, elbows out, huge shocked devastated eyes. | once |
| 12 | celebrate | Kung-fu salute: right fist pressed into his open left palm in front of his chest, a slow formal bow. Deadpan face. | loop |

Poses 1, 2, and 7 come from my picks in CHAR-EXPLORE-01; 8–10 come from the storyboard rescue beats. Pose 11's hands-on-helmet gesture is from the CHAR-EXPR-01 decision.

### Sprite approach · decided 2026-10-02 · provisional, review after testing

**The problem:** the size test showed the realistic look turns muddy at the ~32 px game size. The soot dulls the red and yellow, and the face disappears.

**Two options:**
- **A:** shrink the realistic side profile as it is. It's like a movie poster: great up close, muddy in the game.
- **B:** first generate one game-readable version of the same character (brighter red and yellow, lighter soot, bolder headband and axe, a clean outline), then make every pose from it.

**Decision:** B, Claude's recommendation. I didn't yet understand how either option would look in play, so I chose B as a test. If it doesn't read well in the game, I'll switch to A or try something else, and log it here.

**Pose prompts change:** if CHAR-REF-03 is accepted, each pose is sent with `side-profile-game.png` attached instead of `side-profile.png`. The header and pose lines above stay the same.

### CHAR-REF-03 — game-readable side profile · sent 2026-10-02 · accepted · the reference for every pose

Attached: `side-profile.png` (CHAR-REF-02).

```
Use the attached image as the exact character reference: same face, build, proportions, outfit, helmet with badge, black face mask, headband, axe across his back, scroll-case air tank, wraps, and split-toe boots. Redraw him as a game-ready version that stays readable at small size. TRUE SIDE PROFILE facing right (chest not turned toward the camera), full body, standing neutral, arms relaxed. Keep the realistic style, but: brighter, more saturated red suit and yellow helmet; much lighter soot and grime; longer, bolder headband tails; axe blade and handle clearly visible; strong clean dark outline around the whole figure; clear contrast between the black mask and the face. Single image only: one character, plain flat cream / off-white background, no ground shadow, no scenery, no text.
```

- **Result at full size:** same helmet with badge, mask, headband, axe, tank, wraps, and proportions as CHAR-REF-02. The red and yellow are brighter and the soot is lighter, as asked.
- **Size test 1, 32 px** (`size-test/CHAR-REF-03-vs-02-sprite-32px-x8.png`, `size-test/CHAR-REF-03-vs-02-in-scene-x6.png`): B's helmet reads yellow and the suit reads red where A's were muddy, but the face and outline disappear. **My judgment:** neither A nor B looked like the character at that size.
- **Correction (found by Claude):** 32 px was harsher than the real game. The game draws at 640×360 and shows it in a 1280×720 window, so the character is about **64 px tall on screen**.
- **Size test 2, real window** (`size-test/CHAR-REF-03-window-1280x720-64px-current.png`, `...-128px-doubled.png`, `size-test/CHAR-REF-02-vs-03-window-1280x720-128px.png`): at 64 px he is still small; at 128 px both A and B clearly look like the generated art.
- **Decisions (mine):**
  - **Look: B.** It is brighter and better, and it stays clearer than A in front of the flames.
  - **Size: bigger than the A1 firefighter.** The exact size will be chosen when the character goes into the game, by playtesting. A bigger character needs a bigger collision box and level adjustments (CHANGE-BRIEF).
- **Why this matters:** the in-game character has to be the generated art and meet this sheet. At the A1 size, the art's detail disappears.
- **File:** `design/character/side-profile-game.png` (resized to 800 px wide).

### Pose 1, sent as CHAR-IDLE, now CHAR-RESPAWN · sent 2026-10-03 · accepted 2026-10-05 as respawn / ready

Sent in the same ChatGPT chat (Plus, Instant mode), with `side-profile-game.png` (CHAR-REF-03) attached. Generated Saturday 2026-10-03; downloaded 2026-10-05 as `pose1.png` (1312×1199).

**What I wanted:**
- **Game state:** idle, standing on the floor, not moving. It's the pose the player sees most.
- **The pose:** a low kung-fu ready stance, palm forward, fist at the hip. It comes from my pick of Look B's stance in CHAR-EXPLORE-01 and replaces the original "arms crossed" idle.
- **Pillars:** *Every move is a kata* (even standing still is a martial-arts stance) and *Too cool to care* (a grumpy, unimpressed stare).
- **Sheet rules:** the same character as the reference, in a true side profile facing right (left is flipped at runtime), on a flat cream background so it can be removed later.

Prompt as sent (the trailing "-" was a typo in my message):

```
Use the attached image as the exact character reference: same face, build, outfit, colors, soot, and scale. Single image only: one character, full body, TRUE SIDE PROFILE facing right (chest not turned toward the camera), plain flat cream / off-white background, no scenery, no text.

Pose: Low kung-fu ready stance, knees bent, one open palm pushed forward, other fist at his hip. Grumpy, unimpressed stare.-
```

**Result vs. what I wanted:**
- **Matches:**
  - **Gear:** helmet with the flame badge, black mask, red hood, headband tails, axe and tank on his back, belt pouch, stripes on his arms and legs, wraps, split-toe boots.
  - **Look:** the same brighter red and yellow and light soot as CHAR-REF-03.
  - **Pose:** exactly as asked. It reads strongly as kung fu, which helps the open "too much plain firefighter" worry.
- **Off:**
  - **Not a true side profile.** His chest and hips turn toward the camera, about three-quarter. This is predicted failure **F1** (drift from the reference view), the same drift as the turnaround's side view.
  - **Wide image** (1312×1199) because of the wide stance. To keep in mind for the in-game size and the collision overlay.
- **Decision:** pending. Either accept with the note (a slight three-quarter view still reads in a side-scroller), or regenerate with a stronger side-view instruction.
- **Decision, 2026-10-05 (mine):**
  - **Idle** uses `side-profile-game.png` (CHAR-REF-03) instead. I noticed we already had a standing pose that is a true side profile. Claude added that its narrow shape also fits the tall, narrow collision box, which matters for the pose seen most.
  - **Pose 1 is kept** as **CHAR-RESPAWN**, the "recover / respawn" state: he snaps back into his ready stance when the level restarts after he burns (storyboard panel 5, retry). It's accepted with the three-quarter note, which matters less for a brief state.
  - **Caution:** the standing idle is close to the turnaround's neutral stance, so it may not count as a separate pose. Poses 2–12 are still planned, which keeps the total above 10.
- **File:** `design/character/poses/pose01-respawn.png`, resized to 1025 px wide. That's the same 0.78 scale as `side-profile-game.png`, so the poses stay at one scale.

### Pose 2, run (CHAR-RUN) · sent 2026-10-05 · first try superseded, edit accepted

**What I wanted:** the run, his one moving state (the game has one speed). A low ninja dash with arms swept back and headband tails streaming. Pillar: *Every move is a kata*. This replaces the original walk contact/passing pair.

**Header change (inspect and revise):** pose 1 drifted to three-quarter, so Claude suggested adding one sentence to the end of the header: "His body is turned fully sideways like the reference: we see only his left side, his back faces the left edge of the image, only one eye is visible."

**Try 1 · superseded.** Attached `side-profile-game.png`. **By mistake, I sent only the header, without the "Pose:" line:**

```
Use the attached image as the exact character reference: same face, build, outfit, colors, soot, and scale. Single image only: one character, full body, TRUE SIDE PROFILE facing right (chest not turned toward the camera), plain flat cream / off-white background, no scenery, no text. His body is turned fully sideways like the reference: we see only his left side, his back faces the left edge of the image, only one eye is visible.
```

- **Result:** an upright, calm walking stride (1024×1536). It's a **true side profile** with all the gear matching, so the new sentence fixed the drift. But no dash was asked for, so none came back.
- **Decision (mine):** replace it with a real run. Kept as a thumbnail: `rejected/CHAR-WALK-pose02-header-only.png`.

**Try 2 · accepted.** Attached the try 1 image (`pose2.png`) instead of the side profile, to keep its side view, and asked for an edit:

```
Edit the attached image. Keep everything else exactly the same: the same character, face, outfit, gear, colors, soot, scale, the TRUE SIDE PROFILE view facing right (we see only his left side, his back faces the left edge, only one eye visible), and the plain flat cream / off-white background, no scenery, no text. Single image only.

Change only the pose: he is sprinting forward in an extreme low ninja dash: torso leaning far forward almost horizontal, front knee deeply bent, back leg stretched far behind him, both arms swept straight back behind him, headband tails streaming behind him. Grumpy face.
```

- **Result:** a low ninja dash: torso leaning forward, front knee bent, back leg stretched, arms swept back, tails streaming, grumpy face. It's a true side profile, and the gear and colors match the reference.
- **Notes:**
  - the hands near the tank look a little awkward (they won't show at game size);
  - the tank and axe lie along his leaning back;
  - the image is very wide and low (1536×1024), so the art extends well past a tall, narrow collision box. To address in the collision overlay.
- **Decision (mine):** accepted as the run. It's the strongest "kata" pose so far.
- **File:** `design/character/poses/pose02-run.png`, resized to 1198 px wide (the same 0.78 factor as the other poses).

### Pose 3, jump crouch (CHAR-STANCE) · sent 2026-10-05 · accepted

Attached `side-profile-game.png`. **What I wanted:** the jump-crouch state, the instant before the jump, as a crane stance. Pillar: *Every move is a kata*. The header is the revised one from pose 2 (with the "fully sideways" sentence).

```
Use the attached image as the exact character reference: same face, build, outfit, colors, soot, and scale. Single image only: one character, full body, TRUE SIDE PROFILE facing right (chest not turned toward the camera), plain flat cream / off-white background, no scenery, no text. His body is turned fully sideways like the reference: we see only his left side, his back faces the left edge of the image, only one eye is visible.

Pose: Crane stance: one knee raised high, arms spread out like wings, balanced on one foot. Grumpy face.
```

- **Result:** the crane stance as asked: one knee raised high, arms spread like wings, balanced on one foot, stern face (1024×1536). It's a side profile with one eye; the chest turns very slightly toward the camera, much less than pose 1. The gear and colors match the reference.
- **Note:** his spread arms reach wider than his body, which matters for the collision overlay.
- **Decision (mine):** accepted, first try.
- **File:** `design/character/poses/pose03-jump-crouch.png`, resized to 800 px wide (0.78 factor).

### Pose 4, rising (CHAR-RISE) · sent 2026-10-05 · try 1 superseded, edit (4b) accepted

Attached `side-profile-game.png`. **What I wanted:** the rising state, moving up through a jump, as a flying side kick. Pillar: *Every move is a kata*; CONCEPT names "a flying-kick pose on the way up".

```
Use the attached image as the exact character reference: same face, build, outfit, colors, soot, and scale. Single image only: one character, full body, TRUE SIDE PROFILE facing right (chest not turned toward the camera), plain flat cream / off-white background, no scenery, no text. His body is turned fully sideways like the reference: we see only his left side, his back faces the left edge of the image, only one eye is visible.

Pose: Mid-air flying side kick, front leg fully extended, body horizontal, headband tails flying. Grumpy face.
```

- **Result:** a mid-air flying kick (1536×1024). The front leg is fully extended and the back leg tucked; tails flying; fists up; stern face. The gear and colors match the reference.
- **Off:**
  - **Three-quarter, not a true side profile:** his chest and both shoulders face the camera, and the tank is half hidden (predicted failure F1). The "fully sideways" sentence did not hold for this pose.
  - **The body is not horizontal**, as asked; the torso stays upright.
- **Decision:** pending.

**Try 2 (4b) · accepted.** Because editing fixed pose 2's view, I attached the try 1 image (`pose04-rising.png`) and asked for an edit:

```
Edit the attached image. Keep the same character, outfit, gear, colors, soot, flying-kick pose, and plain flat cream / off-white background, no scenery, no text. Single image only.

Change only the camera angle: show him in a TRUE SIDE PROFILE facing right. His body is turned fully sideways: we see only his left side, his back and the air tank face the left edge of the image, his chest is NOT visible, only one eye is visible. Lean his torso back so his body is more horizontal, in line with his extended kicking leg.
```

- **Result** (1536×1024; downloaded as `pose04b-rising.png.png`, double extension by mistake):
  - the head is in profile with one eye showing;
  - the tank and axe are now clearly on his back, facing the left edge;
  - the same kick; the torso leans a bit more into it.
  - **Still a little off:** his arms spread wide, so some chest shows, much less than try 1.
- **Decision (mine):** accept 4b; try 1 is superseded and kept as the thumbnail `rejected/CHAR-RISE-pose04-three-quarter.png`.
- **File:** `design/character/poses/pose04-rising.png`, resized to 1198 px wide (0.78 factor).

### Pose 5, falling (CHAR-FALL) · sent 2026-10-05 · accepted

Attached `side-profile-game.png`. **What I wanted:** the falling state, moving down through a jump. He floats down calmly, cross-legged, like meditating. Pillar: *Too cool to care*, unbothered even mid-fall.

```
Use the attached image as the exact character reference: same face, build, outfit, colors, soot, and scale. Single image only: one character, full body, TRUE SIDE PROFILE facing right (chest not turned toward the camera), plain flat cream / off-white background, no scenery, no text. His body is turned fully sideways like the reference: we see only his left side, his back faces the left edge of the image, only one eye is visible.

Pose: Falling through the air sitting cross-legged as if meditating, arms folded, eyes half-closed, completely calm.
```

- **Result:** sitting cross-legged in mid-air, arms folded, eyes closed, calm (1024×1536). It's a **true side profile on the first try**: one eye, chest sideways, tank and axe on his back. The gear and colors match the reference.
- **Note:** the headband tails stream sideways rather than upward, as they would in a real fall. Not visible at game size.
- **Decision (mine):** accepted, first try.
- **File:** `design/character/poses/pose05-falling.png`, resized to 800 px wide (0.78 factor).

### Pose 6, landing (CHAR-LAND) · sent 2026-10-05 · try 1 superseded, edit (6b) accepted

Attached `side-profile-game.png`. **What I wanted:** the landing state, touching the ground after air time, as a low ninja crouch with one hand on the ground. Pillar: *Every move is a kata*; CONCEPT names "a three-point kung-fu landing".

```
Use the attached image as the exact character reference: same face, build, outfit, colors, soot, and scale. Single image only: one character, full body, TRUE SIDE PROFILE facing right (chest not turned toward the camera), plain flat cream / off-white background, no scenery, no text. His body is turned fully sideways like the reference: we see only his left side, his back faces the left edge of the image, only one eye is visible.

Pose: Landing in a low ninja crouch, one knee bent deep, one hand flat on the ground, a dust puff at his feet.
```

- **Try 1 result** (1536×1024; downloaded as `pose06-landing.png.png`): a low ninja landing, front knee deep, back leg stretched, one hand on the ground, true side profile, gear matching. But the dust cloud is light brown, close to the cream background, so background removal would leave a messy edge. And it would show on every landing, even on rooftops.
- **Superseded:** kept as the thumbnail `rejected/CHAR-LAND-pose06-dust.png`. (The dust was in my own planned prompt; Claude flagged the risk before generating.)

**Try 2 (6b) · accepted.** Attached the try 1 image and asked for an edit:

```
Edit the attached image. Keep everything exactly the same: the same character, pose, outfit, gear, colors, soot, scale, TRUE SIDE PROFILE view, and the plain flat cream / off-white background, no scenery, no text. Single image only.

Change only this: remove all the dust, dirt particles, and debris around his feet and hand. Nothing on the ground around him, just the character on the plain flat background.
```

- **Result:** the dust is fully gone; the pose, view, gear, and colors are identical.
- **Decision (mine):** accepted 6b.
- **File:** `design/character/poses/pose06-landing.png`, resized to 1198 px wide (0.78 factor).

### Pose 7, hose (CHAR-SPRAY) · sent 2026-10-05 · try 1 superseded, edit (7b) accepted

Attached `side-profile-game.png`. **What I wanted:** the hose state, while water pours on the fire (W). A wide martial-arts stance holding the nozzle forward. Pillars: *Every move is a kata* and *Too cool to care* (bored face).

**Prompt change before sending (decided with Claude):** the planned line said "water blasting out". Claude checked the game code and found that the game already draws the water stream itself (`godot/game/session.gd`, around line 395) and shrinks the fire as it pours. Water in the image would give two streams and a messy edge for background removal. So the pose shows no water, and the hose's path is described.

```
Use the attached image as the exact character reference: same face, build, outfit, colors, soot, and scale. Single image only: one character, full body, TRUE SIDE PROFILE facing right (chest not turned toward the camera), plain flat cream / off-white background, no scenery, no text. His body is turned fully sideways like the reference: we see only his left side, his back faces the left edge of the image, only one eye is visible.

Pose: Wide low martial-arts stance, one arm pushing a fire hose nozzle straight forward, aimed to the right, the hose running back to his tank. No water coming out of the nozzle. Bored face.
```

- **Try 1 result** (`pose07-hose.png`): a wide low stance with both hands on the nozzle, no water, true side profile, gear matching. **But the hose runs off the left edge of the image.**
- **Superseded, my catch:** in the game the character image is cut out on its own, so the hose would end in mid-air behind him. I wanted the whole hose in frame, connected to the tank. Kept as the thumbnail `rejected/CHAR-SPRAY-pose07-hose-off-edge.png`.

**Try 2 (7b) · accepted.** Attached the try 1 image and asked for an edit:

```
Edit the attached image. Keep everything exactly the same: the same character, wide stance, nozzle grip, outfit, gear, colors, soot, scale, TRUE SIDE PROFILE view, and the plain flat cream / off-white background, no scenery, no text, no water. Single image only.

Change only the hose: it must stay fully inside the image. From the nozzle, the hose curves back behind his hip and connects to the bottom of the air tank on his back. No part of the hose goes off the edge of the image.
```

- **Result** (1536×1024):
  - the hose curves from the nozzle past his hip and connects to the bottom of the tank;
  - nothing touches the image edges (Claude measured: the nozzle tip stops about 18 px from the right edge);
  - the stance, view, gear, and colors are unchanged.
- **Notes:**
  - the face is stern rather than bored (minor; the face doesn't show at game size);
  - the nozzle points right at about chest height, which is where the game's code-drawn water should start (for the build).
- **Decision (mine):** accepted 7b.
- **File:** `design/character/poses/pose07-hose.png`, resized to 1198 px wide (0.78 factor).

### Pose 8, rescue: grab (CHAR-RESCUE) · sent 2026-10-05 · accepted with notes

Attached `side-profile-game.png`. **What I wanted:** the rescue moment, when he reaches the survivor. Storyboard panel 3a (grab, serious face).

**Prompt change before sending (decided with Claude):** the planned line had him grabbing a small person by the collar. But the game draws the survivors itself (a person **and** a dog), removes the rescued one from the window, and shows its head in his bag. A person baked into the image would be wrong when he rescues the dog, and could show two people at once. So the pose has him gripping with nobody in the image.

```
Use the attached image as the exact character reference: same face, build, outfit, colors, soot, and scale. Single image only: one character, full body, TRUE SIDE PROFILE facing right (chest not turned toward the camera), plain flat cream / off-white background, no scenery, no text. His body is turned fully sideways like the reference: we see only his left side, his back faces the left edge of the image, only one eye is visible.

Pose: Leaning forward and reaching out with one arm, his gloved hand closed in a tight grip as if grabbing someone by the back of the collar, other arm braced back. Nobody else in the image, just him. Serious, stern face.
```

- **Result** (1024×1536): a true side profile with one arm reaching forward, the other braced back, a stern face, nobody else in the image, and nothing touching the edges. The gear and colors match, with one exception.
- **Off:**
  - the reaching hand is a **closed fist with the knuckles forward**, so it reads more like a punch than a grab;
  - he barely leans forward;
  - **gear drift:** a second pouch appeared on his thigh (the reference has one belt pouch), which breaks the consistency rules.
- **Claude's suggestion:** an edit to hook the fingers, lean him forward, and remove the extra pouch.
- **Decision (mine):** accepted as is.
- **File:** `design/character/poses/pose08-grab.png`, resized to 800 px wide (0.78 factor).

### Pose 9, rescue: toss (CHAR-TOSS) · sent 2026-10-05 · try 1 superseded by my design change · edit (9b) accepted

Attached `side-profile-game.png`. **What I wanted (as planned):** storyboard panel 3b, the reckless toss: he tosses the survivor into his bag without looking, mid-yawn. Pillar: *Too cool to care*. As with pose 8, nobody is in the image, because the game draws the survivors.

```
Use the attached image as the exact character reference: same face, build, outfit, colors, soot, and scale. Single image only: one character, full body, TRUE SIDE PROFILE facing right (chest not turned toward the camera), plain flat cream / off-white background, no scenery, no text. His body is turned fully sideways like the reference: we see only his left side, his back faces the left edge of the image, only one eye is visible.

Pose: Standing, his right arm flung back over his shoulder with an open hand, as if he just tossed something behind him without looking. His other hand covers his mouth mid-yawn, eyes squeezed shut, completely bored. Nobody else in the image, just him.
```

- **Try 1 result** (`pose09-toss.png`, 1024×1536): a true side profile, eyes squeezed shut, hand over the mouth mid-yawn, as asked. The arm is flung sideways and back. The extra thigh pouch from pose 8 appeared again (gear drift).
- **Superseded by my design change:** looking at it, I decided the toss should be **exaggerated and go upward**. He launches the survivor sky-high without looking, and they fall into the bag. That's funnier and more *Too cool to care* than a sideways toss. Kept as the thumbnail `rejected/CHAR-TOSS-pose09-sideways.png`.
- **What the image can and can't show:** the image shows only his throw. The survivor flying up and dropping into the bag would be drawn by the game (see CHANGE-BRIEF, "Revision 2026-10-05").

**Try 2 (9b).** Attached the try 1 image and asked for an edit (Claude wrote it from my idea):

```
Edit the attached image. Keep the same character, outfit, colors, soot, scale, TRUE SIDE PROFILE view, the yawn (eyes squeezed shut, other hand covering his mouth), and the plain flat cream / off-white background, no scenery, no text. Single image only, nobody else in the image.

Change only these:
1. His throwing arm: flung straight UP above his head, fully extended toward the sky, open hand with fingers spread, as if he just launched someone very high into the air with one careless toss. His body leans back slightly with the follow-through.
2. Remove the second pouch on his thigh; keep only the one pouch on his belt, like the reference.
```

- **Result** (1024×1536):
  - his arm is flung up overhead (angled slightly back), open hand with fingers spread;
  - he leans back slightly; the yawn is kept (eyes shut, hand over his mouth);
  - true side profile; the extra thigh pouch is gone, so the gear matches the reference again.
- **Note:** the fingertips come within about 10 px of the top edge. Not cut off, but tight.
- **Decision (mine):** accepted 9b.
- **File:** `design/character/poses/pose09-toss.png`, resized to 800 px wide (0.78 factor).

### Pose 10, rescue: done · skipped 2026-10-05

The planned pose (walking away with a dazed person poking out of the bag) can't work as a single image. His reference has no bag (the tank is on his back), and a person baked into the image would be wrong when he rescues the dog. **Decision (mine):** skip it. The set still has 12 poses: the side-profile idle, poses 1–9, 11, and 12, plus the turnaround.

### Pose 11, burned (CHAR-BURNED) · sent 2026-10-05 · try 1 accepted with a hand edit; edit attempt rejected

Attached `side-profile-game.png`. **What I wanted:** the failure moment when fire touches him (`DYING`, storyboard panel 4). The one time his cool act breaks: both hands clutching his helmet in horror (my CHAR-EXPR-01 decision). Pillar: *Failure is a punchline*.

**Prompt changes before sending (Claude suggested, I agreed):**
- "scorched black from head to toe" became heavy soot with the red and yellow still showing. Fully black, he'd be an unrecognizable blob in the game.
- the smoke became a few thin dark-gray wisps close above the helmet. A big pale cloud would blend into the cream background, like the dust in pose 6.

```
Use the attached image as the exact character reference: same face, build, outfit, colors, soot, and scale. Single image only: one character, full body, TRUE SIDE PROFILE facing right (chest not turned toward the camera), plain flat cream / off-white background, no scenery, no text. His body is turned fully sideways like the reference: we see only his left side, his back faces the left edge of the image, only one eye is visible.

Pose: Just got burned: heavily scorched with black soot all over him, but his red suit and yellow helmet still clearly visible underneath. Both gloved hands clutching the sides of his crooked, dented helmet in horror, elbows out, huge shocked devastated eyes. A few thin dark-gray smoke wisps rising just above his helmet, close to him; no big smoke cloud.
```

- **Result** (1024×1536): both hands on his dented helmet, elbows out, a wide shocked eye, heavy soot with the red and yellow still visible, thin dark smoke wisps; side view; gear matches.
- **Off:** the smoke wisps touch the top edge of the image (Claude measured 0 px), so they'd be cut flat in the game.
- **Front view?** I asked whether this pose was meant to face the camera. Claude checked: the docs only have front-facing close-ups (storyboard panel 4, a design view, and the DEVASTATED portrait). The in-game pose was always side view. I kept side view, consistent with the other poses.

**Edit attempt (11b) · rejected.** Attached try 1 and asked to shorten the smoke:

```
Edit the attached image. Keep everything exactly the same: character, pose, soot, colors, view, and the plain flat cream / off-white background. Single image only.

Change only the smoke: make the dark-gray smoke wisps shorter so they stay fully inside the image, ending well below the top edge.
```

- **Result:** ChatGPT offered two versions to choose from. Both fixed the smoke, but **both turned him to three-quarter** (chest and both shoulders facing the camera, F1).
- **Decision (mine):** reject the edit and keep try 1's side view.

**Hand edit on try 1 (done by Claude, with my OK):** the top 60 px rows of the image were faded linearly into the background color, so the smoke tips fade out instead of being cut. The smoke now ends 28 px below the top edge. Nothing else in the image changed (only background and smoke are in those rows).
- **File:** `design/character/poses/pose11-burned.png`, the faded version, resized to 800 px wide (0.78 factor).

### Pose 12, celebrate (CHAR-BOW) · try 1 2026-10-05 · bow edits failed · try 2 (12b, new chat) accepted 2026-10-06

**What I wanted:** the end of the level (`COMPLETE`, storyboard panel 6): a deadpan formal kung-fu bow after the escape. Pillars: *Every move is a kata* and *Too cool to care*.

**Try 1 · rejected.** Sent in the "Character Concept Sheet" chat with `side-profile-game.png` attached, using the revised header and the planned pose line ("Kung-fu salute: right fist pressed into his open left palm in front of his chest, a slow formal bow. Deadpan face."). *The prompt text here is reconstructed from the plan, not copied from the chat.*
- **Result:** a true side profile, gear matching, but he stands **upright with his palms pressed together**: no bow, and almost the same shape as idle. At game size it would not read as a different state.
- Thumbnail: `rejected/CHAR-BOW-pose12-salute-no-bow.png`.

**Bow edits · failed.** I asked ChatGPT twice to edit try 1 into a bow; both times it returned an error and no image (possibly because the chat had become very long, or the image wasn't attached). Nothing to judge.

**Try 2 (12b) · accepted.** A **new chat** ("Character Profile Prompt", Plus, Instant mode), with `side-profile-game.png` attached. Claude wrote the prompt with the bow built into the pose line:

```
Use the attached image as the exact character reference: same face, build, outfit, colors, soot, and scale. Single image only: one character, full body, TRUE SIDE PROFILE facing right (chest not turned toward the camera), plain flat cream / off-white background, no scenery, no text. His body is turned fully sideways like the reference: we see only his left side, his back faces the left edge of the image, only one eye is visible.

Pose: A formal kung-fu bow: his upper body bent forward at the waist about 45 degrees, head lowered, his right fist pressed into his open left palm in front of his chest, feet together. Deadpan, bored face.
```

- **Result** (1024×1536, `pose12b.png`): a clear forward bow with the head lowered, true side profile, one belt pouch, gear and colors matching the reference.
- **Off:** the hands are palms pressed together, not a fist in a palm. Minor; it still reads as a formal bow, and the hands don't show at game size.
- **Decision (mine):** accepted 12b. Its bent shape is distinct from idle at game size.
- **File:** `design/character/poses/pose12-celebrate.png`, resized to 800 px wide (0.78 factor).

**Pose count:** 12 labeled pose images (idle, poses 1–9, 11, 12) plus the turnaround.

---

## Revision 2026-10-07 — final sheet: states in the game, silhouette, collision, palette, consistency

Written after the character was built into the game and playtested twice (TEST-REPORT.md). The v1 sections above are kept as the original contract; this section records what was actually built and checked. Images below were made by Claude with `tools/make_sheet_extras.py` from the exact in-game images (`godot/art/character/`), so they show what the game draws.

### Requirement change: one image per state

The assignment was updated: animation is not required; each state is one static image that the game swaps in. The "Plays" column (loop / once) in the v1 pose table is therefore informational only.

### Pose → game state, as built

| State in the game | Image | When it shows |
|---|---|---|
| idle | `side-profile-game.png` (CHAR-REF-03) | on the floor, not moving |
| run | `pose02-run.png` | on the floor, moving |
| rising (flying kick) | `pose04-rising.png` | the whole jump, up and down (playtest 1: "too many poses in one jump") |
| falling (meditating) | `pose05-falling.png` | in the air without jumping (walked off a ledge) |
| landing | `pose06-landing.png` | 20 ticks (0.33 s) after touching down from real air time |
| hose | `pose07-hose.png` | standing still while the water pours; the water starts at its nozzle tip |
| rescue grab | `pose08-grab.png` | 15 ticks at the moment of a rescue |
| rescue toss | `pose09-toss.png` | 30 ticks after the grab, while the survivor flies up |
| burned | `pose11-burned.png` | fire death (`DYING`), 0.9 s until the retry |
| respawn / ready | `pose01-respawn.png` | after a retry, until he moves (max 30 ticks) |
| celebrate (bow) | `pose12-celebrate.png` | level complete (`COMPLETE`); the end card waits 1.25 s so the bow is seen |
| jump crouch (crane) | `pose03-jump-crouch.png` | **sheet only**: dropped from the jump in playtest 1 |

12 distinct labeled poses plus the turnaround; 11 of them are used in the game.

### Size

**64 px tall** (idle) in the 640×360 game, which is **128 px in the 1280×720 window**. Every pose uses one scale factor, so proportions match across poses (the v1 "about 32 px" is replaced; the A1 size hid all the art's detail, see CHAR-REF-03). Still to confirm in my next playtest.

### Silhouette at on-screen size

`design/character/silhouette.png` (1×, the real size) and `silhouette-x4.png` (enlarged to inspect), all 12 states in solid black.

- Every state has its own shape: the run and landing are long and low, the kick is horizontal, the fall is a compact ball, the hose has a straight bar forward, the toss has one arm straight up, burned has both elbows up at the helmet, the bow leans forward.
- The helmet and the headband tails read in every state, so he stays one character.
- **Weakest:** idle, burned, toss, and bow are all upright, and differ only by the arms and head. At game size burned also loses its soot detail on the dark backdrop (predicted failure F3); it reads by shape.

### Orientation

Drawn facing **right**; facing left is the same image mirrored at runtime (`player.gd`, the art holder's x scale is negative). No left-facing images were generated. Unchanged from v1.

### Collision overlay

`design/character/collision.png`: every state with the collision box at the same scale (4×), the box bottom-center on the character's origin.

- **Box: 20 × 40 px** (v1 said 18 × 28, unchanged from A1). Changed because the character is bigger. **My decision, option A** (2026-10-06): the crouching poses (run, landing, hose, respawn) are only 41–49 px tall, so a box as tall as the standing idle (≈58 px) would sit above his head while running, and a flame could kill him without visibly touching him.
- **Art beyond the box, and why it's fair:**
  - Standing poses: the head and helmet stick out about 24 px above the box. A flame can brush his helmet without killing him. That only forgives.
  - Headband tails behind him, the kick leg, the hose nozzle, the reaching or raised arms (grab, toss, respawn), and the stretched back leg in the run and landing: all outside the box, all forgiving.
  - Falling (meditating): the box is centered on his body, so his crossed legs hang a few px below the box. When he touches down, the landing pose (feet on the box bottom) replaces it.
- **Nothing in the box is empty art in a way that kills unfairly:** the box sits on the torso and legs in every pose.
- The level's tests still pass with the bigger box (TEST-REPORT, steps 1–2), including the flame-clearance check.

### Palette (final hex values)

Sampled from the idle image; `design/character/palette.png` shows each color with its contrast ratio against the backdrop and the level.

| Color | Hex | Role |
|---|---|---|
| Suit red | `#be1a16` | most of the body |
| Suit shadow | `#77110c` | folds, shaded side |
| Helmet yellow | `#f1bc27` | helmet, reflective stripes |
| Outline / mask | `#0e0a08` | outline, face mask, boots |
| Gear brown | `#705340` | belt pouch, wraps, straps |

**Check against the environment** (luminance contrast; 1.0 = identical brightness):
- **Near the flames:** suit red vs flame red 1.3, helmet yellow vs flame orange 1.3 and flame core 1.4. The suit and helmet alone would vanish in the fire (predicted failure F2). **The dark outline carries him there:** outline vs flames 3.9 to 16.0.
- **On the ENV-BG backdrop:** the outline is weak on the dark fog (1.6), but the helmet yellow (7.0 on fog, 3.4 on the glow) and the suit red (2.0 on fog) carry him. The weakest spot is the red suit on the orange horizon glow (1.1).
- **ENV-BG v2 (2026-10-07):** `palette.png` is now checked against the new backdrop's colours in his play band (dark `#4e5b71`, mid `#798aa2`, light `#dbd3cd`). The orange glow that matched his suit is gone; suit red vs the background improved from worst-spot ΔE 31 to 85 (colour difference, which brightness ratios alone miss).
- **Playtest 3 (2026-10-07):** in play he still got lost against the backdrop, so the backdrop is drawn darker and cooler in code. A light outline around him was tried and **rejected by me**: the fix belongs in the background, which is being regenerated. The palette is unchanged.
- These are brightness ratios only; red on blue-gray also differs in hue, which helps. Judged in the game, he reads against the backdrop (TEST-REPORT, ENV-BG).
- This is v1's palette **option A** (keep red and yellow, rely on a dark outline), and no recolor was needed.

### Consistency rules: check of the accepted images

Checked by Claude against `side-profile-game.png`; each note was already logged when the pose was accepted.

| Rule | Result |
|---|---|
| Same proportions and height | Every pose is filed at the same 0.78 scale and shrunk by one factor for the game. Standing heights: idle 128, toss 129, burned 128, jump crouch 124 texture px (within 3%). |
| Same helmet, mask, headband, tank, axe | Holds in all 12. **Drift:** pose 8 (grab) has an extra thigh pouch (accepted as is, my decision). |
| Side view, facing right | Holds, except pose 1 (respawn, about three-quarter, accepted for a brief state) and pose 4b (rising, some chest showing). |
| Eye line, grumpy default face | Not visible at game size. Several poses came back stern rather than grumpy (accepted; the face doesn't read at 64 px). |
| Outline weight | All generated with the same dark outline from CHAR-REF-03; at game size it is about 1 px. |
| Feet on the same baseline | In the game, the feet of every grounded pose sit on the origin (anchors in `godot/art/character/anchors.json`). |
| Only palette colors | Painted art, so not literally 5 colors; the five above are the main colors in every pose. Pose 11 adds soot and gray smoke by design. |
