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
