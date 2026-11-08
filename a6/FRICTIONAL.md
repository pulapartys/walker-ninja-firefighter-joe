# FRICTIONAL — Assignment 6 (particle effects)

> **How the work was split:** directed and decided by me; implemented by Claude Code; eye-tested and played many times by me.
>
> **How this log was made:** Claude organised it from our one long interactive session (2026-11-06 to 2026-11-08) and the commits, and I checked it. Quotes marked as mine are my words from that session, with typos fixed. For each tuning round it points to `a6/TUNING.md` instead of repeating it. Every entry is retrospective, written from the session record, not live notes.

## Setting up: which account does what

- **What I asked:** every commit must come from my Northeastern GitHub account `pulapartys`, never my work account (`sreejapulaparty`).
- **What happened:** the repository already had `pulapartys` pinned locally. Every A6 commit is authored by it, and before the first push Claude checked that the stored token belongs to `pulapartys`.
- **Something Claude raised:** the Claude Code login on this Mac is my work organisation's. I decided: "claude account doesnt matter as long as github is authenticated with pulapartys"; SOURCES.md says so.
- **What worked immediately:** the course wrapper, once plain `godot` was on my PATH. Claude added a small shim in `~/.local/bin` (outside the repo) instead of editing the wrapper, which the assignment gives verbatim (`78d926e`). The baseline came out identical to A5's except for one finding: realtime `test_audio` needs the 300 s timeout (`2be25da`).

## Choosing the effects

- **What I chose:** a smoke puff on every jump (Effect A) and steam while hosing (Effect B).
- **The node type:** my first answer was "i dont understand". Claude re-explained it with an analogy: a CPU node is one worker moving every dot by hand; a GPU node is a thousand helpers. I then chose a CPU node for the puff, so my two effects show both sides of the price.
- **The steam's job:** Claude pointed out that steam that is only on or off is not clearly one of the three allowed jobs. I made it a feedback loop that follows the fire's strength.
- **Esc pause:** I chose to let the steam keep drifting, the same as my A5 glow.

## Writing the brief

- **What happened:** faced with the predictions and short answers, my answer was "idk i need help". Claude would not write them for me and split them into small questions instead.
- **What I wrote:**
  - the three predicted failures, picked from the assignment's list and matched to a check;
  - my price guesses and budgets;
  - the six short answers, in my words.
- **One answer I corrected myself:** my first Q4 said a headless run shows "0 GPU cost". After Claude's note I rewrote it: a headless run measures CPU time only, close to 0 but not exactly 0.
- **Sections A and B:** I decided everything in them in chat; Claude typed them. The v1 header said I had reviewed them line by line, which I had not, so Revision 8 corrects it.
- **Traceability:** v1 `45c4398`, committed before the first `claude -p` prompt.

## What the agent sessions got wrong

| Session | What went wrong | How it was caught |
|---|---|---|
| 1 (CLAUDE.md, read-only) | wrote two scratch files under `/tmp` although told to change only CLAUDE.md; dropped the "Headless facts" block my A5 tests cite | reading its tool calls; the tests' header comments. Restored in the review (`0651b6e` draft, `01fa15a` review) |
| 1 | tried to run Godot five times and was refused | the result event's permission denials. It said the names were unverified instead of inventing output, the opposite of the chapter's recorded mistake |
| 2 (puff build) | deleted its own temporary file with `rm`, which is not on the allow list | reading its tool calls (accept-edits mode allowed it) |
| 2 | its preview fired on `frame == 10`, which a live window skips | my first look showed nothing (next section) |
| 3b (puff state test) | a lower time bound stricter than my own `lifetime_randomness` allows | found by session 4 when it failed once |
| 7 (cost script) | assumed a fixed puff life, so "two alive" did not hold on every frame; changed its "different" rule after seeing a result | my re-run through the wrapper exited 1; fixed in `db26889`, three clean re-runs |

**What worked immediately:** the steam's build (session 5) passed its 89-check config test on the first run. It also set `emitting = false` in the scene, which heads off my prediction P3. I checked by re-running the test myself (`28eeeaf`).

## My first look showed nothing

- **What happened:** in the preview window I said "idk i couldnt tell to small maybe". The console never printed "JumpPuff added". At real speed the puff fired in 1 of 3 runs, because of the `frame == 10` bug.
- **What changed:** `>=` instead of `==`, plus a loop mode for watching by eye (`6b5c613`). The captures were unaffected. My second look is in TUNING, Effect A r0.

## From the jump to the landing (my decision from play)

- **What I saw in the game:** the puff on the jump worked, but it made sense to me at the landing, not the take-off (TUNING, "the event moves from the jump to the landing").
- **What I chose:** a `landed` signal in `player.gd`, fired where the game already starts the landing pose. I chose it over a driver that watches the floor itself. It widens my own boundary by two lines in `player.gd`, which I accepted (Revision 2, `237cba4`; implemented by session 4, `a618ef8`).
- **What I learned:** the change exposed a test bug no one had seen: the time bound above.

## Tuning: Claude's reading against my eyes

- **The puff:** I asked to try both of Claude's proposed changes, run as two rounds so each strip shows one change (TUNING r1 and r2).
  - **r1:** I kept it but "couldnt tell the difference a lot" at game size, while Claude's zoomed reading called it a clear improvement. That is our disagreement.
  - **r2:** I liked it.
- **The steam:** my first look said it was hard to notice on the sky; Claude's reading agreed. Its r1 prediction was wrong at frame 16, which showed that the "slow start" was really the steam being invisible (TUNING, Effect B r1). I kept the change.

## Captures that lied

- **What happened:** the first r2 capture of the puff showed no puff at all, and the second froze after frame 26. Godot reported 7, then 27 of 60 frames drawn. The capture window, launched from Claude's session, opened behind my other windows, and macOS stopped redrawing it.
- **How it was caught:** Claude compared the frame files by md5 and found runs of identical frames. r1 was checked the same way and was valid.
- **What changed:** captures launched from Claude's session use `--always-on-top` (`5afb846`).

## "Finish all": what I delegated, and what I checked afterwards

- I said "finish all and ill do the feedback then". Claude then:
  - ran the puff mutations;
  - approved the steam's wiring plan on my behalf, and chose that the steam draws behind Extinguisho (Revision 5);
  - captured the steam strip, but did not read it, so my first look came first.
- **In my feedback session I checked the results myself:**
  - the steam's first look and its tuning round;
  - both screen edges, no steam at the start, Esc, and the draw order, which I confirmed (Revision 7);
  - the puff on the dark street;
  - the Godot 3 name in play ("yes its right under him doesnt look natural looks bad");
  - Step 6 and the Visual Profiler.

  For the rest: "for the steam and everything I've played the game multiple times so that's good".

## Step 6, the process shader

- **The conversion:** I did it in the editor myself, on a scratch copy Claude prepared. I asked "shader field?" once, then found "Save As…" in the menu I had open (`bf9bbfc`).
- **The second question:** I first said "idk can you help". Claude explained it as a dance troupe (the shader is the choreographer's rulebook, the draw step the costume department) and asked me to sort my own settings. I sorted them and wrote the sentence myself.
- **The line numbers:** Claude located them with `grep`. I chose line 331, the `AMOUNT_RATIO` line, as the one tied to my brief (TEST-REPORT, "The process shader").

## Pricing

- **The GPU instrument:** on my M1, GPU time reads 0 under Compatibility and under Metal. Only Mobile on the Vulkan driver reports it (`d08f9f9`), so every GPU price runs there, a different renderer from the one my game ships with.
- **The profiler took three tries.** I could not play the game and work the Visual Profiler at once ("idk im not able to do both, can you do it for me"), so Claude made the game play itself.
  - **Tries 1 and 2:** `--script` runs connected but got no profiler.
  - **Try 3:** a normal scene worked.
  - **Reading it:** typing a frame number did not take ("Frame # is not a box"), so I clicked the graph. Claude's phase estimates were wrong, because the run went faster than 60 fps. I recorded what the frames showed (`1a1b778`).
- **My guesses:** off in both directions. The puff was not measurable on the GPU or the CPU, and the steam cost more than I guessed, though still under budget (TEST-REPORT, "My predictions against the results").

## What the film build found

- **The finding:** while capturing the steam for the film, Claude found that the game's pause card covers the fire during Esc. My choice that the steam "keeps drifting" under Esc is true inside the engine, but no player can see it. Recorded as Revision 9, with no code change.
- **The film's numbers:** 5:13 at the 5–5:30 I asked for, in the plain "layman technical" register I asked for (script v3, which I approved). It passed the toolkit's checks (`680a2d4`).

## Unresolved questions

- **What does the steam look like when it is shown again after being hidden?** Only the headless state was checked; nothing in the game hides it.
- **How much does the puff cost the GPU?** It is a CPU node, so the profiler has no particle row for it, and I never isolated it in the profiler.
- **Does the steam visibly thin between 1 s and 2 s?** It is hard to see in the strips (TUNING, Effect B r1).
- **Would the GPU numbers differ on the Compatibility renderer the game actually ships with?** This Mac cannot measure it.
- **The A5 hose glow pulls the eye from the steam.** Toning it down belongs to A5's scope, not this assignment.

## The film

- I asked for 5–5:30 and a layman-technical register, approved script v3, and uploaded the MP4 to my Northeastern SharePoint myself. One mishap: the first `open` started it in Audacity, my Mac's default for `.mp4`, so it was reopened in QuickTime Player.

## Who did what

| | Me (directed, decided, eye-tested, played) | Claude Code (`claude-opus-5-5`, implemented) |
|---|---|---|
| Effects and jobs | chose both, the node types, the pause behaviour, the landing | listed options with facts from my code |
| Brief | every decision; predicted failures, price guesses, six answers; Revisions 1, 2, 7 | typed sections A and B and every revision; measured contrast; Revision 5 under my delegation |
| Build and tests | approved the puff plans; delegated the steam's | wrote the scenes, drivers, previews and tests (`claude -p`), reviewed and re-ran them |
| Tuning | first looks and every verdict, in the running game | strip readings, proposals, predictions, comparisons, the edits I approved |
| Captures | the first puff strip | the later captures, at my request |
| Human checks | every look, verdict, edge and start check, the Godot 3 name in play, the Step 6 conversion and answers, reading the Visual Profiler; many plays of the game | launched the windows, made the fixtures that let the game play itself, located the shader line numbers, recorded my words |
| Rejected or changed | the jump trigger (moved to the landing) | declined to write my predictions and answers |
