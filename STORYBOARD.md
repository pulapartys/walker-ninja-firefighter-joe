# STORYBOARD — Extinguisho, the ninja firefighter

> v1 · 2026-10-01 · written before any generation. The panel sketches go in `design/storyboard/`. Later revisions are added below, not rewritten.

## The idea this storyboard has to sell

Extinguisho is a **ninja firefighter**. He does an ordinary firefighter's job (hose the fire, carry people out, escape the building), but **every move is performed like a martial-arts movie**, and **every sound is exaggerated the same way**. The comedy comes from the gap between how dramatic his moves and sounds are and how bored his face stays. Nothing impresses him, except fire touching him, and then his face falls apart like a comic-book panel.

The four pillars from CONCEPT.md, and how each one shows up in movement and sound:

| Pillar | How the ninja exaggeration shows it |
|---|---|
| **Race the flames** | Fast, drum-led music with a martial-arts flavor runs under every panel of play; the 40-second countdown is always visible. |
| **Too cool to care** | His face stays flat and grumpy through flips, kicks, and rescues. Routine actions get crisp, understated sounds; he never cheers. |
| **Every move is a kata** | Walking is a sneaky ninja shuffle, a jump is a flying kick with a sharp "whoosh," a landing is a three-point superhero crouch with a heavy thud, and hosing is done from a wide martial-arts stance. |
| **Failure is a punchline** | When fire touches him, the cool act breaks: a giant devastated comic-book face, smoke puffs, and an over-the-top cartoon yelp, followed by a fast retry so the joke never gets old. |

## How the panels cover the rules

- **Frame shape:** 16:9 for every panel, the same shape as the game window (640×360).
- **Gameplay panels** show what the game camera shows: a side view, eye level, following Extinguisho left to right. **Design panels** are moments framed differently on purpose, to set how the world and character should feel. Each panel is labeled.

| Panel | Moment (required) | Shot size | Angle | Motion | View |
|---|---|---|---|---|---|
| 1 | First thing the player sees | wide | eye level | camera pans across the street | design (title) |
| 2 | Core action | medium | eye level | water-stream arrow, flame shrinking | gameplay |
| 3 | Success | medium | low angle | jump arrow, "SAVED!" rising | design |
| 4 | Failure | close-up | eye level, tilted (Dutch) | smoke puffs, camera shake | design |
| 5 | Retry | wide | high angle | run arrow, camera follows | design |
| 6 | End of the session | medium | low angle | leap arc, landing impact lines | design |

**Totals:** 3 shot sizes (wide, medium, close-up); 4 angles (eye level, low, high, tilted); motion on all 6 panels.

---

## Panel 1 — First look: the burning street

![sketch](design/storyboard/01-first-look.png)

- **Shot:** wide · eye level · design view (title screen) · motion: slow camera pan from left to right across the whole street.
- **Player action:** the player sees the title card and presses Enter to start. The game drops Extinguisho at the start line, and the 40-second countdown begins.
- **See:**
  - Two burning buildings across the street, flames in the windows, smoke rising, and a "HELP!" bubble from a trapped person and a trapped dog.
  - Extinguisho small at the left edge, standing in his **idle pose**: arms crossed, chin up, grumpy, completely unbothered by the inferno in front of him.
  - The title "Extinguisho."
- **Hear:**
  - Before starting: the music is quiet or off, with only distant fire crackle.
  - On Enter: the drum-led music kicks in at full speed.
- **Assets:** ENV-BG, ENV-FIRE, CHAR-IDLE, MUS-LOOP
- **Design reason** (pillars "Race the flames" + "Too cool to care"): in one glance the player should understand the job (two buildings, people trapped, a clock running) and the joke (the hero does not care how scary it is).

## Panel 2 — Core action: hosing the blocking fire

![sketch](design/storyboard/02-core-action-hose.png)

- **Shot:** medium · eye level · gameplay view · motion: arrow along the water stream from the hose to the fire; the flames drawn shrinking from tall to small.
- **Player action:**
  - The player reaches the large fire blocking the trapped person's window. The prompt "Press W to hose the fire" appears.
  - The player taps W. The water pours for about 4 seconds while the flames shrink, and the player waits it out, watching the clock.
- **See:**
  - Extinguisho in his **hose-spray pose**: a wide, low martial-arts stance, one leg forward, the hose held out like a weapon in a kung-fu movie.
  - His face still bored, as if hosing a giant fire were a chore.
  - The water stream hitting the fire, and the flames shrinking.
- **Hear:**
  - **SFX-HOSE:** an exaggerated, high-pressure blast, overdramatic for what is just water.
  - The music keeps driving underneath; it does not let up while he waits.
- **Assets:** CHAR-SPRAY, CHAR-IDLE, ENV-FIRE, SFX-HOSE, MUS-LOOP
- **Design reason** (pillar "Every move is a kata"): the core verb, putting out fire, should feel like a martial-arts technique, not a chore. It also costs time, which keeps the urgency.

## Panel 3 — Success: the rescue

*Picture revised 2026-10-02: the rescue is now three beats (grab, reckless toss, dazed in the bag). See the "Revision 2026-10-02" section.*

![3a grab](design/storyboard/03a-grab.png)
![3b throw](design/storyboard/03b-throw.png)
![3c in the bag](design/storyboard/03c-in-bag.png)

- **Shot:** medium · low angle (camera looking up at him) · design view · motion: arrow showing his leap into the window; "SAVED!" text drifting upward.
- **Player action:** the fire is out; the player walks into the window and touches the trapped person. The game marks them rescued, and they ride along in his rescue bag.
- **See:**
  - Extinguisho in his **rescue pose**: he scoops the person up in one smooth, heroic, kung-fu-movie motion, shot from below like a hero.
  - His face, again, totally deadpan: no smile, no celebration.
  - "SAVED!" floating up; the person's head now visible in his bag.
- **Hear:**
  - **SFX-RESCUE:** a short, bright sting, with a little martial-arts flourish.
  - The music continues.
- **Assets:** CHAR-RESCUE, ENV-BG, SFX-RESCUE, MUS-LOOP
- **Design reason** (pillar "Too cool to care"): the heroic camera angle and his bored face clash on purpose. The player feels the win; Extinguisho refuses to.

## Panel 4 — Failure: fire touches him

![sketch](design/storyboard/04-failure-burned.png)

- **Shot:** close-up on his face · eye level, tilted (Dutch angle) · design view · motion: smoke puffs rising, camera shake on contact.
- **Player action:** the player misjudges a jump and lands in the flames. The game ends the attempt at once and shows "The fire got you."
- **See:**
  - The **burned pose**: the one moment the cool act breaks. A huge, devastated, comic-book face: eyes wide, mouth open in horror, helmet knocked crooked, soot on his face, smoke rising.
  - The fire that caused it stays visible, so the player knows exactly what killed him.
  - The tilted camera makes the moment feel off-balance and dramatic.
- **Hear:**
  - **SFX-BURN:** an over-the-top cartoon yelp with a sizzle, exaggerated enough to be funny, not upsetting.
  - The music dips under the yelp.
- **Assets:** CHAR-BURNED, ENV-FIRE, SFX-BURN, MUS-LOOP
- **Design reason** (pillar "Failure is a punchline"): dying should make the player laugh, not feel punished, so they want one more try right away.

## Panel 5 — Retry: back at the start, instantly

![sketch](design/storyboard/05-retry.png)

- **Shot:** wide · high angle (looking down on the street) · design view · motion: a long run arrow from the start line toward the first building; note "camera follows."
- **Player action:** about half a second after the failure, the game puts Extinguisho back at the start with a fresh 40-second clock. The player immediately runs and jumps again.
- **See:**
  - The whole route from above, so the path to the first building is clear.
  - Extinguisho back in his **idle pose** for an instant, as if nothing happened, then the **walk poses**: a low, sneaky ninja shuffle.
  - The fire that got him, back in place, so the player can plan around it.
- **Hear:**
  - The music returns to full and keeps going. It does not restart, so the retry feels seamless.
  - **SFX-JUMP** on the first jump: a sharp martial-arts whoosh.
- **Assets:** CHAR-IDLE, CHAR-WALK-A, CHAR-WALK-B, ENV-BG, ENV-FIRE, SFX-JUMP, MUS-LOOP
- **Design reason** (pillars "Failure is a punchline" + "Race the flames"): a retry should cost almost nothing, so the player's attention goes straight back to beating the clock.

## Panel 6 — End: the rooftop escape and the bow

![sketch](design/storyboard/06-end-escape.png)

- **Shot:** medium · low angle · design view · motion: a big leap arc from the roof out through the fire escape; impact lines where he lands.
- **Player action:** with both survivors rescued, the fire escape on the roof unlocks ("JUMP OUT →"). The player jumps out. The game ends the run and shows "Everyone out!" with the number saved, the time, and the retries.
- **See:**
  - The full kung-fu move set in one shot: the **kung-fu stance** before the leap, the **flying-kick rise**, the **falling** pose, and the **three-point landing**.
  - The final **celebrate pose**: a slow, formal, deadpan bow, the most understated "victory" possible.
  - The person and the dog visible in his bag.
- **Hear:**
  - **SFX-JUMP** on the leap.
  - **SFX-WIN:** a big dramatic gong.
  - The music stops, so the gong lands in silence.
- **Assets:** CHAR-STANCE, CHAR-RISE, CHAR-FALL, CHAR-LAND, CHAR-BOW, ENV-BG, SFX-JUMP, SFX-WIN, MUS-LOOP
- **Design reason** (pillars "Every move is a kata" + "Too cool to care"): the ending is the biggest martial-arts moment, and his response to winning is a bored bow. That gap is the joke the whole game is built on.

---

## Readable with sound muted

Every panel must work with no sound:
- the failure has its own pose plus "The fire got you.";
- the rescue has its pose plus "SAVED!";
- the end has its pose plus "Everyone out!";
- the hose prompt and the countdown are on screen.

Sound adds the comedy and the urgency; it never carries information the screen doesn't show.

---

## Revision 2026-10-02 — sketch generation prompts

The panel sketches are generated in ChatGPT, one chat, one panel per message, after the base prompt. Each prompt is recorded exactly as sent, so any panel can be regenerated or tweaked later. The asset log in SOURCES.md has the matching rows (SB-01 … SB-06) with the outcome and edits.

**Status values:**
- **planned:** written but not yet sent.
- **sent:** used to make the image in `design/storyboard/`.
- **revised:** the prompt was changed after an attempt; both versions are kept.

### Base prompt (sent once, at the start of the chat)

```
I'm making storyboard thumbnails for a 2D side-scrolling platformer game. Every image I ask for should use this exact style:

- Rough black-and-white pencil sketch, loose lines, light gray shading, no color
- 16:9 frame with a thin black border, like a storyboard panel
- No words, letters, or captions anywhere in the image
- Main character: a short, stocky firefighter dressed like a ninja — helmet, heat-protective suit, a ninja face wrap, carrying a fire hose. His face is always flat, grumpy, and unimpressed unless I say otherwise.
- Draw movement with simple arrows and motion lines.

Reply "ready" and wait for my first panel.
```

### Panel 1 — SB-01 · status: sent 2026-10-02 · accepted

```
Panel 1. Wide shot, eye level. A city street with two burning buildings, flames in the windows, smoke rising. A trapped person waving from one window, a dog in a window of the other building. The ninja firefighter stands small at the far left, arms crossed, looking bored. A long horizontal arrow across the top shows the camera panning left to right.
```

**Result vs. this prompt:** everything matched except the character's size: "small at the far left" came back large in the foreground.

**Tweak to try if regenerating:** "The ninja firefighter is tiny, about one tenth of the frame height, standing at the far left edge."

### Panel 2 — SB-02 · status: sent 2026-10-02 · accepted

```
Panel 2. Medium shot, eye level, side view. The ninja firefighter in a wide, low martial-arts stance, one leg forward, holding the hose out like a weapon, spraying a thick stream of water at a large fire blocking a window. His face is bored. Show the flames shrinking with a downward arrow, and an arrow along the water stream.
```

### Panel 3 — SB-03 · status: revised

**Attempt 1 (sent 2026-10-02): rejected.**

```
Panel 3. Medium shot, low angle looking up at him, heroic framing. The ninja firefighter scooping a trapped person out of a smoky window in one smooth kung-fu motion. His face stays deadpan. An upward curved arrow shows his leap into the window.
```

- **Result:** he leaps and carries the person in his arms. The angle, the deadpan face, and the arrow were right.
- **Why rejected:** it contradicts how rescue works in the game. In `session.gd` the player touches the survivor; in `player.gd` the survivor then rides as a head poking out of the rescue bag on his back hip. The prompt said "scooping" and never mentioned the bag, so the model defaulted to an arms carry.

**Design change (2026-10-02, my decision):** the rescue is funnier if he does not care. He grabs the survivor and recklessly tosses them into his bag without looking, instead of a smooth heroic move. This serves the pillar "Too cool to care" more strongly than the original panel's "heroic scoop". The game mechanic, where the survivor rides in the bag, is unchanged.

**Attempt 2 (revised prompt): sent 2026-10-02 · superseded by 3a–3c** (thumbnail: `rejected/SB-03-attempt2-single-toss.png`).

```
Panel 3 again, with a change. Medium shot, low angle looking up at him. The ninja firefighter grabs the trapped person out of a smoky window by the collar with one hand and carelessly tosses them over his shoulder into a big rescue duffel bag strapped to his back hip, without even looking. The person flails mid-air, arms and legs flying, shocked. His face stays completely bored, eyes half-closed. He is NOT carrying the person in his arms. A curved arrow shows the person flying from the window into the bag, with small motion lines.
```

- **Result:** the person flies through the air into the bag, flailing and shocked, with a curved arrow and motion lines; low angle; no arms carry. This matches the bag mechanic.
- **Difference:** his face reads stern and grumpy, not the "eyes half-closed, bored" look the prompt asked for.

**Design change (2026-10-02, my decision): panel 3 becomes three beats.** The rescue is shown as three sub-panels. These can also become the three frames of the in-game rescue animation (CHARACTER-SHEET pose 9).

| Sub-panel | Beat | His face |
|---|---|---|
| 3a | He grabs the survivor by the collar. | serious |
| 3b | He flings them into the bag without looking. | couldn't care less |
| 3c | They sit dazed in the bag while he walks off. | serious again |

The person is shown here; the dog appears in panel 6. Attempt 2 is a candidate for 3b.

### Panel 3 strip — SB-03-strip · status: sent 2026-10-02 · kept as a design reference

**What was sent:** the three prompts below (3a, 3b, 3c), pasted together in **one message**, each with its heading.

**Result:** one wide image, 2172×724, holding three square frames.
- 3a: he grabs the person by the collar, face serious.
- 3b: he flings them, eyes closed, a hand over a yawn.
- 3c: the person sits dazed in the bag with swirly eyes and a star; his face is stern.

**Decision:**
- The content is what I wanted, but the shape breaks "keep one frame shape throughout" (every other panel is 16:9).
- It stays as a design reference for the rescue animation (CHARACTER-SHEET pose 9).
- I also want 3a changed: the person should still be inside the window, with his arm reaching into it.
- Each beat is regenerated as its own 16:9 image, one prompt per message (attempt 2 below).

**Lesson:** one message produces one image. Send each frame as its own message and state "single 16:9 image" explicitly.

#### Attempt 1 prompts (sent together, as one message)

### Panel 3a — SB-03a · status: attempt 1 sent (in the strip)

```
Panel 3a. Medium shot, low angle looking up. The ninja firefighter at a smoky window reaches in and grabs the trapped person by the back of their collar with one hand, lifting them like a kitten. The person dangles, shocked. His face is serious and focused: stern eyes, frowning, no emotion. An open rescue duffel bag hangs on his back hip.
```

### Panel 3b — SB-03b · status: attempt 1 sent (in the strip)

```
Panel 3b. Same scene, next moment. Medium shot, low angle. Without looking, he flings the person backward over his shoulder toward the open bag on his back hip. The person flails mid-air, arms and legs flying. His face shows he couldn't care less: eyes half-closed, looking away, mid-yawn. A curved arrow goes from his hand to the bag, with motion lines.
```

### Panel 3c — SB-03c · status: attempt 1 sent (in the strip)

```
Panel 3c. Same scene, final moment. Medium shot, low angle. The person now sits stuffed inside the bag on his back hip, only their head and hands poking out, dazed with swirly eyes. The firefighter is already turning to walk away, face serious and stern again, as if nothing happened.
```

#### Attempt 2 prompts: one message each, 16:9 · status: sent 2026-10-02 · all three accepted

- **3a:** the person is inside the window; his arm reaches right, into it, and grabs the collar; his face is serious.
- **3b:** the person flies into the bag; his eyes are closed and a hand covers a yawn.
- **3c:** the person is dazed in the bag with swirly eyes and a star; his face is stern and he is walking away.

The strip thumbnail is kept at `rejected/SB-03-strip-wrong-frame-shape.png`.

**3a (changed: the person is still inside the window, and his arm reaches into it):**

```
Single image only: one 16:9 storyboard frame, not a strip, not multiple panels. Same pencil style as before.

Panel 3a. Redraw the first beat of the previous 3-panel image, with one change. Medium shot, low angle looking up. The smoky, burning window is on the right side of the frame. The trapped person is still INSIDE the window, only their upper body visible through the frame, shocked. The ninja firefighter stands to the left of the window and reaches his arm to the right, INTO the window, grabbing the person by the back of their collar with one hand. His face is serious and focused: stern eyes, frowning. An open rescue duffel bag hangs on his back hip.
```

**3b (same content as the strip, new shape):**

```
Single image only: one 16:9 storyboard frame, not a strip, not multiple panels. Same pencil style as before.

Panel 3b. Redraw the second beat of the previous 3-panel image as its own frame, keeping everything the same: medium shot, low angle. Without looking, he flings the person backward over his shoulder toward the open bag on his back hip. The person flails mid-air, arms and legs flying. His eyes are closed and his other hand covers a yawn: he couldn't care less. A curved arrow goes from his hand to the bag, with motion lines.
```

**3c (same content as the strip, new shape):**

```
Single image only: one 16:9 storyboard frame, not a strip, not multiple panels. Same pencil style as before.

Panel 3c. Redraw the third beat of the previous 3-panel image as its own frame, keeping everything the same: medium shot, low angle. The person sits stuffed inside the bag on his back hip, only their head and hands poking out, dazed with swirly eyes and a little star above their head. His face is serious and stern again, as if nothing happened.
```

### Panel 4 — SB-04 · status: sent 2026-10-02 · accepted

```
Panel 4. Close-up of the ninja firefighter's face, camera tilted at a Dutch angle. For the first time, his expression breaks: a huge, exaggerated, devastated comic-book face — eyes wide, mouth open in horror, helmet knocked crooked, soot on his face, smoke puffs rising, flames at the edge of the frame. Short shake lines around the frame show camera shake.
```

### Panel 5 — SB-05 · status: sent 2026-10-02 · accepted

```
Panel 5. Wide shot, high angle looking down on the street from above. The ninja firefighter back at the start line, running in a low sneaky ninja shuffle toward the first building. A long arrow shows his path to the building, with a small flame on the ground he has to jump over.
```

### Panel 6 — SB-06 · status: sent 2026-10-02 · accepted with a noted mismatch

```
Panel 6. Medium shot, low angle. The ninja firefighter leaping off a burning rooftop in a flying kung-fu kick, a big curved arrow showing his arc, landing below in a three-point superhero crouch with impact lines. A small person and a dog peek out of the bag on his back. His face is bored.
```

- **Result:** flying kick, arc arrow, and a three-point landing with impact lines.
- **Mismatch:** the bag shows two people and a dog; the game has one person and one dog. Accepted for the storyboard because the moment (kung-fu escape, survivors in the bag, bored face) reads correctly. The in-game bag follows the code, not this sketch.
- **Tweak if regenerating:** "exactly one person and one dog in the bag."
