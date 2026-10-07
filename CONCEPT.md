# CONCEPT — walker-ninja-firefighter-joe

> v1 · 2026-10-01 · written before any generation. Later revisions are added below, not rewritten.

## The game in two sentences

You are **Extinguisho**, a grumpy, unimpressed ninja firefighter with 40 seconds to rescue a person and a dog from two burning buildings. Kung-fu leap over flames, hose down the fire blocking the way, and escape off the rooftop fire escape before the clock, or a very dramatic burn, ends the attempt.

## Core loop

- **Repeat:** move and jump across ledges toward the next survivor.
- **Decide:** which jump to commit to over the flames, and when to stop and hose. Hosing the blocking fire costs about 4 of the 40 seconds.
- **Risk:** touching fire or falling ends the attempt instantly, with a quick retry. Running out of time also ends it.

## Design pillars

Every asset must serve at least one of these.

| Pillar | What it means | Visual choice that honors it | Sound choice that honors it |
|---|---|---|---|
| **Race the flames** | The player always feels the clock and the fire pushing them. | The countdown is always visible; the flames flicker and glow. | A fast, percussion-driven music loop that never relaxes during play. |
| **Too cool to care** | Extinguisho is deadpan. Nothing fazes him, which is the joke. | A flat, grumpy face in idle, walk, and even during a rescue. | Routine actions get understated sounds; he does not cheer. |
| **Every move is a kata** | Movement looks like martial arts, not ordinary walking. | A flying-kick pose on the way up, a three-point kung-fu landing. | An exaggerated martial-arts whoosh on every jump. |
| **Failure is a punchline** | Dying should be funny, so retrying feels good instead of punishing. | A comic-book devastated face when fire touches him. | An over-the-top cartoon yelp or sizzle, then a fast retry. |

## Art direction

Comic-book-flavored pixel art with chunky dark outlines, flat colors, and exaggerated expressions. Extinguisho is about 32 px tall on screen, so the silhouette and face have to read at that size. That is why the style uses exaggeration and not detail. This serves **Too cool to care** and **Failure is a punchline**, which both depend on the face reading.

Reference notes, in words:
- Saturday-morning cartoon: flat fills, thick outlines, big readable shapes.
- Heat-protective gear: matte fabric, reflective trim, a hard helmet, a ninja face wrap.
- Lighting: warm firelight from below, cool smoky shadows above.
- Posing: martial-arts movie freeze-frames, held for a beat at the top of a jump.

**Revision 2026-10-02 (under test):** while exploring the character I chose a **more realistic, crusty, ashy** style instead of the comic-book style above: ancient ninja / kung-fu clothing combined with firefighter gear, soot, scorched fabric, and a muscular adult build. The reasons for the original choice still apply, because the character must read at about 32 px. The realistic style is tested at game size before it replaces this direction (CHARACTER-SHEET, "Revision 2026-10-02").

## Audio direction

- **Feel:** urgent, and funny. The music carries the urgency; the sound effects carry the comedy.
- **Music:** a fast, drum-led loop with a martial-arts flavor that plays during play.
  - Pause: the music pauses.
  - Death: the music dips under the burn sound and comes back on retry.
  - Rescue escape (win): the music stops and a short win sting plays.
  - Title menu: quiet, or off.
- **Sound effects:** exaggerated and cartoonish, short, with silence trimmed from the front so they feel instant.
- **Rule:** sound never decides what happens. The game reads the same with sound muted.

## Started from

My Assignment 1 project, `walker-jumpman-joe` (firefighter rescue), which extended [nikbearbrown/walker-jumpman](https://github.com/nikbearbrown/walker-jumpman). See SOURCES.md.

---

## Revision 2026-10-07 — the concept as built

The v1 text above is kept as the original plan. This revision records what changed after generating the art, building the slice, and two playtests (TEST-REPORT.md, FRICTIONAL.md). Nothing below replaces the game in two sentences or the core loop: both still hold.

### Art direction: closed (replaces "comic-book pixel art, ~32 px")

- **Style chosen:** semi-realistic painted art, not comic-book pixel art. Extinguisho is an ancient-ninja / kung-fu firefighter in a red heat suit and yellow helmet, generated in ChatGPT from one reference image and kept consistent by attaching that reference to every pose.
- **Why it changed:** while exploring the look (2026-10-02) I wanted him more muscular, realistic, and crusty than the comic-book versions. The fully realistic, sooty version turned muddy at game size, so every in-game pose comes from a brighter **game-readable** reference (CHAR-REF-03): saturated red and yellow, lighter soot, a strong dark outline.
- **Size:** 64 px tall in the 640×360 game (128 px in the window), twice the A1 character. At the planned ~32 px, the art's detail and the face disappeared (size tests in `design/character/size-test/`).
- **Not pixel art:** the art is painted and drawn at half its texture size with smooth filtering. Predicted failure F7 ("pixel art blurs, use Nearest") does not apply.
- **Reference notes, as built:** dusk and smoke (a cool blue-gray sky so his red and yellow stand out); firelight only low on the horizon; matte, scorched heat-suit fabric with reflective stripes; martial-arts freeze-frame poses.
- **Environment:** ENV-BG, a generated burning-city skyline, sits behind the level. **v2 (2026-10-07):** a cool, hazy blue-gray day with gray smoke columns replaced the dusk version with its orange glow, because the red-and-yellow character disappeared against the glow (playtest 3). The level itself (ledges, buildings, survivors, the rescue bag, the HUD) stays code-drawn from A1; the ledges and in-level text were recolored so they stay visible on the darker backdrop. Generated flames (ENV-FIRE, three images) replace the code-drawn flames on every fire hazard; they came out more comic than painted, which I accepted (SOURCES).

### Pillars: how the slice delivers them now

| Pillar | Delivered in the slice | Weak or missing |
|---|---|---|
| **Race the flames** | 40 s clock always visible; flames block the path until hosed (~4 s). | (Music loop added 2026-10-07: 150 BPM taiko drums.) |
| **Too cool to care** | Mid-yawn upward toss (the survivor flies sky-high and drops into his bag); meditating fall; deadpan bow at the end. | His grumpy face doesn't show at 64 px; the attitude reads through poses, not the face. |
| **Every move is a kata** | Flying kick for the whole jump, three-point ninja landing, low ninja dash, hose held in a martial-arts stance, kung-fu ready stance on respawn. | — |
| **Failure is a punchline** | Burned pose (both hands clutching the helmet) held 0.9 s, **plus the generated DEVASTATED portrait popping up big** next to "The fire got you." (added 2026-10-07, like storyboard panel 4's close-up), then a fast retry. | The sooty pose itself is still dark on the dark sky; the cartoon burn sound isn't in yet. |

The pillars are my own design choices from CONCEPT v1, not assignment requirements; the assignment asks for three or four pillars and judges whether the assets serve them.

### Core loop and gameplay: what changed

The loop (move, jump, hose, rescue, escape in 40 s) is unchanged, but some numbers changed so the bigger, generated character reads and fits:

| What | A1 | Now | Why |
|---|---|---|---|
| Run speed | 160 px/s | 120 px/s | Playtest 2: the poses changed too fast to read. |
| Jump | 53 px high, 0.67 s in the air | 64 px high, 0.8 s | Keeps the burning-street jump possible at the slower speed (option A). |
| Collision box | 18 × 28 | 20 × 40 | The character is twice as tall; the crouching poses set the height. |
| Retry after a fire death | 0.55 s | 2.0 s (R retries at once) | Playtests 2 and 3: the burned pose and "The fire got you" disappeared too fast. |
| Rescue | the survivor appears in the bag | grab → upward toss → drops into the bag | My design change (2026-10-05); visual only, the rescue still counts on touch. |

### Audio direction: status

The plan from v1 still holds (urgent music, funny effects, music pauses on pause, dips on death, stops on the win). **Sound effects are now in the slice** (ElevenLabs, see SOURCES): jump whoosh, hose blast, slide-whistle toss, sizzle-and-yelp burn, and a cheering crowd at the end. **Changed from v1:** the win is a silly crowd cheer, not a gong, because I wanted it funnier; that pulls against "he does not cheer" (Too cool to care), unresolved: the reading I'm considering is that the rescued people cheer while he stays deadpan and bows. **Music:** in the slice: a 150 BPM taiko-driven loop from ElevenLabs Music (the plan said Suno), 16 bars, sitting about 6 dB under the effects; it pauses, dips on a fire death, and stops on the win.
