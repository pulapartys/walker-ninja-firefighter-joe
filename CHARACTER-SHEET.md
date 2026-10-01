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
