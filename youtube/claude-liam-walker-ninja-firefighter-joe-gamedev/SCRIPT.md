# Extinguisho: Generated Art, Sound, and Music in Godot

Final narration as voiced by Liam (Kokoro am_onyx), generated from beat_sheet.json. Edited from SCRIPT-DRAFT.md (v2, approved by Sreeja, then trimmed to about six minutes at her request).

## B00 — The prompt

Please use Walker to turn a game design into a playable Godot slice, with generated art, sound, and music. I'm Liam, the narrator voice of the Brutalist toolkit. This is Assignment Two for C S Y E seventy-two seventy, and the game is called Extinguisho.

## B01 — What was built

Extinguisho is Sreeja's game. It grew out of her Assignment One firefighter platformer: one level, two burning buildings, a forty-second clock, now played by a generated ninja firefighter, with a generated skyline and flames, five generated sound effects, and a looping track. This is an asset slice, not the full game.

## B02 — Four pillars, designed first

Extinguisho is grumpy, unimpressed, and fast. Four pillars set the bar for every asset: race the flames, too cool to care, every move is a kata, and failure is a punchline. The storyboard came first, as the specification for every prompt. Its text was committed two minutes after the first sketch; the log says so.

## B03 — The character sheet as a contract

The character sheet is the contract: twelve labeled poses, a silhouette at real game size, a collision overlay, a five-colour palette, and consistency rules. Every pose came from one reference image, attached to each prompt, so proportions held.

## B04 — One asset, traced: the design

Let's trace one asset. Storyboard panel three-b is the rescue: he tosses the survivor into his bag without looking, mid-yawn. The first generation did exactly that, sideways. Looking at it, Sreeja changed the idea: the toss should go straight up, sky-high.

## B05 — The edit, then the texture

So the next step was an edit, not a new prompt: keep the character and the view, change only the throwing arm. Then a script removes the cream background with a flood fill, scales every pose by one shared factor, and records an anchor at the feet. A hundred and twenty-eight pixel texture, drawn at half size.

## B06 — One image per state

In Godot, a state is one static image. Show pose swaps the texture, places it by its feet anchor, and flips the holder's scale when he faces left. No animation: the state change is the image change.

## B07 — The toss, in the running game

And here is that toss in play: the grab, the arm flung up, the survivor spinning skyward and dropping into the bag. The rescue counts the instant he touches the survivor; the arc is drawn afterwards, so it can never change what happens.

## B08 — Choosing the state

Update pose decides which image shows. Timed action poses come first, then air, then ground. A jump is one kick from takeoff to touchdown, then a landing held for a third of a second. That rule came from a playtest where three poses flashed in one jump.

## B09 — Every state in play

Every state, in real play: the respawn stance, idle, run, the flying kick, the landing, the hose, the grab and the toss, the bow, facing left, the meditating fall after a missed jump, and burned. The crane crouch stayed on the sheet; in play it flashed by too fast to read.

## B10 — The collision box

Collision is a separate object from the art. The box is twenty by forty game units, centred twenty above the feet, sized from the crouching poses so it never floats above his head while he runs.

## B11 — Art against the box

Drawn on real screenshots, the helmet, the kick, and the hose reach past the box. That only forgives the player. Art smaller than the box would kill without visible contact; there is none.

## B12 — A background that hid him

The environment is generated too: a skyline behind the level and three flame images keyed out from flat green. One change shows cause and effect. The first background's orange glow sat at his height and hid his red suit. Regenerated as a cool blue-grey haze, the colour difference at the worst spot rose from thirty-one to eighty-five.

## B13 — Five sounds, cleaned the same way

Five sound events: jump, hose, rescue, the fire death, and the win. Each was trimmed to start instantly, brought to minus fourteen L U F S with a limiter just under full scale, and saved as Ogg Vorbis.

## B14 — A sound follows its event

Each sound plays from the code that already represents its event, after the state changes: the burn plays once the game is already dying. The guards that stop a double death also stop a double sound, and nothing in the game reads a sound back.

## B15 — Burned, then back

Here is that branch in play: the fire touches him, the burned pose and the devastated close-up hold for two seconds, and he is back at the start in his ready stance.

## B16 — Game audio, no narration

*(no narration: the game’s own audio, labeled on screen)*

## B17 — Sixteen bars that loop

For the music, Sreeja kept the second version, with the taiko drums and plucked strings the ninja idea needed. At a hundred and fifty beats per minute one bar is one point six seconds; sixteen bars were cut where the last bar best matches the first, with a ten millisecond crossfade at the seam.

## B18 — The music follows the game

Music and effects run on two separate audio buses. The music plays while you play, pauses in place, dips under the burn, carries on after a retry without restarting, and stops at the win. N mutes the music, B the effects.

## B19 — Readable with the sound off

With both muted, the game still reads: music off and sound off in the corner, a help bubble at the window, saved when he grabs someone, and every death names its reason on screen.

## B20 — What the tests prove

Verification ran from a fresh copy. The added sound test steps the game one physics tick at a time: thirteen jumps make thirteen jump sounds, one hose, two rescues, one win. Muted, or with every sound file removed, the route ends the same, tick for tick. Whether the sounds feel right took a human listen.

## B21 — Verdict

The verdict. Working: eleven generated states on real events, a generated environment, five sounds that each fire once, a seamless loop, and separate mutes. Limits: his face doesn't read at sixty-four pixels, so the punchlines live in two close-ups, and the level and survivors are still drawn in code. ChatGPT made the images, ElevenLabs the sounds and music, Claude Code the code and tests. The choices were Sreeja's. Revision two-four-one-c-three-f-two.

## B22 — Your turn

Your turn, one step toward the full game: falling deaths are silent today. Ask Walker for a fall pose and its own sound, wired into the state that already exists. Predict what could fire twice, and let the sound test prove it. This has been Liam, from Brutalist.

## B23 — Outro

Extinguisho: Generated Art, Sound, and Music in Godot. At Nik Bear Brown.
