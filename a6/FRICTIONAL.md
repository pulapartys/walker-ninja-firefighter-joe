# FRICTIONAL — Assignment 6 (particle effects)

> **How this log was made:** Claude organised it from our one long interactive session (2026-11-06 to 2026-11-08) and the commits; I review it and correct anything that is not true. Quotes marked as mine are my words from that session, with typos fixed. It points to `a6/TUNING.md` for the tuning record rather than copying it. Entries are retrospective, written from the session record, not live notes.

## Setting up: which account does what

- **What happened:** I said my work GitHub account (`sreejapulaparty`) must not be used and every commit must come from my Northeastern account `pulapartys`. The game repository already had `pulapartys` pinned locally, and every A6 commit is authored by it. Before the first push, Claude checked that the stored token belongs to `pulapartys`.
- **What Claude found:** the Claude Code CLI on this Mac is logged into my work organisation, so the agent sessions ran there. I decided: "claude account doesnt matter as long as github is authenticated with pulapartys". SOURCES.md says so plainly.
- **Also:** plain `godot` was not on my PATH, so the course wrapper and the `claude -p` allow lists could not call it. Claude added a small shim in `~/.local/bin` (outside the repo) instead of editing the wrapper, which the assignment gives verbatim (`78d926e`).

## Choosing the effects (my decisions)

- I chose a **smoke puff on every jump** (Effect A) and **steam while hosing** (Effect B).
- On the node type I first answered "i dont understand". Claude re-explained: the CPU node is one worker moving every dot by hand, the GPU node is a thousand helpers. I chose a **CPU node for the puff**, so my two effects show both sides of the price: a real headless number and a near-zero one.
- Claude pointed out that "steam on/off while hosing" is not clearly one of the three allowed jobs. I chose to make it a **feedback loop**: the steam follows the fire's strength.
- I chose to let the steam **keep drifting under Esc**, the same as my A5 glow.

## Writing the brief (the parts that are mine)

- **What happened:** faced with the predictions and short answers, my answer was "idk i need help". Claude would not write them for me (the assignment makes them mine) and broke them into small questions instead.
- **Predicted failures:** I picked three from the assignment's list (the Godot 3 name, the puff glued to the player, steam before the hose) and matched each to a check (settings test, game test, my eyes).
- **Price guesses:** puff and steam headless "about 0"; puff GPU 0.05–0.5 ms; steam GPU under 0.05 ms; budgets 0.1 ms (puff) and 0.5 ms (steam).
- **Six short answers:** in my own words. Claude pointed out that my first Q4 said a headless run shows "0 GPU cost"; I rewrote it myself: a headless run measures CPU time only, close to 0 but not exactly 0.
- **Traceability:** brief v1 `45c4398`, committed before the first `claude -p` prompt.

## The agent sessions, and what they got wrong

- **CLAUDE.md (session 1, read-only):** the agent tried to run Godot five times, was refused by the allow list, and said the property names were unverified instead of inventing output. It also wrote two scratch files under `/tmp` although the prompt said to change no file but CLAUDE.md. Its draft dropped the "Headless facts" block that two of my A5 tests cite; the review restored it and added the three A6 lines after Claude confirmed each on my machine (`0651b6e` draft, `01fa15a` review).
- **Effect A build (session 2):** good scene and a 94-check config test. It deleted its own temporary test with `rm`, which is not on the allow list; Claude Code's accept-edits mode let it through. Its preview had a bug (next section).
- **Effect A wiring (sessions 3a/3b) and the landing change (session 4):** each session tried the runner without `./` and was refused, then used the allowed form. Session 4 found that the earlier state test's lower time bound was stricter than my own `lifetime_randomness` allows (a puff can finish at 0.72 s), so the test could have failed at random; it fixed the bound.
- **Effect B (sessions 5, 6a, 6b):** the build set `emitting = false` explicitly, which heads off my prediction P3. The wiring plan pointed out that the preview would show two steams once the driver existed, and fixed it.

## My first look showed nothing

- **What happened:** I ran the preview window and said "idk i couldnt tell to small maybe". The console was missing the "JumpPuff added" line. Claude ran the preview at real speed three times: the puff fired once. The agent's preview checked `frame == 10` inside the physics step, which a live window can skip.
- **What changed:** `>=` instead of `==`, plus a `-- loop` mode for watching by eye (`6b5c613`). Captures are unaffected. My verdict, in the loop preview: "for now it looks fine i wanna test once its in the game, the size looks fine".

## From the jump to the landing (my decision from play)

- **What I saw in the game:** "i checked the puff and it appearing at jumps looks good, but i think it doesnt make sense before, but makes sense to appear at the landing, so lets change that".
- **What I chose:** a `landed` signal in `player.gd`, fired where the game already starts the landing pose, over a driver that watches `is_on_floor()` itself (CHANGE-BRIEF Revision 2). This widens my own boundary by two lines in `player.gd`, which I accepted.
- **After the change:** "looks good and makes sense".

## Tuning the puff: Claude's reading against my eyes

- I asked to try both of Claude's proposed changes; Claude ran them as two rounds so each strip shows one change.
- **r1, greyer puff:** kept, but "honestly i couldnt tell the difference a lot". Claude's reading of the zoomed strip called frame 20 a visible improvement; at game size I saw little. That is our disagreement, recorded in TUNING.md.
- **r2, bigger puff:** kept: "i like this one better it shows those extra dots as more granular dust".

## Captures that lied

- **What happened:** the r2 capture showed no puff at all, then a second attempt froze after frame 26. Godot reported 7, then 27 of 60 frames drawn. The capture window, launched from Claude's session, had opened behind my other windows (the first time behind the game window left open from r1), macOS stopped redrawing it, and Movie Maker kept saving the last picture.
- **How it was caught:** Claude compared the frame files by md5 and found long runs of identical files. The r1 strip was checked the same way (its puff sits within 1 px of r0's).
- **What changed:** captures launched from Claude's session use `--always-on-top`; the third r2 capture drew 60 of 60.

## "Finish all": what I delegated

- I said "finish all and ill do the feedback then". So Claude did the remaining build work and marked every decision I would normally make:
  - ran the Effect A mutations (both fail the config test; the Godot 3 rename gives no Godot warning);
  - approved the steam wiring plan on my behalf, and chose that the steam draws behind Extinguisho (CHANGE-BRIEF Revision 5, marked for my confirmation);
  - captured the steam strip, but did **not** read it, so that my first look still comes first.

## Pricing: the GPU instrument

- **What Claude found:** on my M1 the viewport's GPU time reads 0 under Compatibility and under Mobile or Forward+ on Metal; only Mobile on the Vulkan driver reports it (`a6/evidence/probes/gpu_time_probe.log`). So the GPU price uses `--rendering-method mobile --rendering-driver vulkan`, a launch flag; `project.godot` is unchanged.
- **Script numbers (fixture):** the puff is not measurable on the GPU; the steam adds 0.08–0.18 ms. My guesses were off in both directions. My own Visual Profiler reading is still to do.

## The steam: my look, Claude's reading, one change

- **My first look (preview loop):** "i don't know if the steam is visible enough against the flashing of the firefighter the size is fine but idk if its that noticeable especially in the sky". The "flashing" is my own A5 hose glow breathing blue on Extinguisho, which pulls the eye from the fire; it stays as it is (A5 is out of this assignment's scope).
- **Claude's reading of r0** agreed: the white steam barely shows on the pale sky, and the darker `Haze` layer my brief relied on for contrast was invisible.
- **Change r1:** a darker, more solid haze (one setting, the `Haze` colour ramp). Claude predicted frame 16 would be unchanged; it was not: the first grey puff showed already, so r0's "slow start" was really the steam being invisible. My verdict in the game: "its better now" (Revision 6).
- **Checks after it:** both screen edges ("looks good ig", "good"), no steam at the start, Esc keeps it drifting, and the steam behind Extinguisho: "all ok" (Revision 7 confirms the Revision 5 that Claude chose for me). The puff on the dark street: "clearly visible".

## The Godot 3 name in play

- With the mutation applied again for a moment, I landed a few times: "yes its right under him doesnt look natural looks bad". The puff still fired; nothing reported an error; only the config test catches it.

## Step 6, the process shader

- Claude made a scratch scene with a private copy of the steam's material; I did the conversion in the editor myself (I asked "shader field?" once and found "Save As…" from the menu I had open).
- For the second question I first said "idk can you help". Claude explained it as a dance troupe (the shader is the choreographer's rulebook, the draw step the costume department) and asked me to sort my own settings; I sorted them and wrote the sentence myself (TEST-REPORT, "The process shader").

## The GPU profiler took four tries

- I could not play the game and work the Visual Profiler at the same time ("idk im not able to do both, can you do it for me"). Claude made the game play itself.
- **Try 1 and 2:** a `--script` run connected to the editor (the socket showed it) but the editor gave it no profiler; Start stayed grey. **Try 3:** a normal scene with the same three phases; Start worked.
- **Reading it:** typing a frame number did not take ("Frame # is not a box"), so I clicked the graph instead. Claude's frame estimates for the phases were wrong because the run went faster than 60 fps under Vulkan; frame 7182, meant to be the puff, already had the steam on. I recorded what the frames actually showed: the steam's particle row 0.04 → 0.25 / 0.27 ms.
- I skipped the optional FPS-with-vsync-off comparison.

## Still mine to do

- Skim this log and SOURCES.md and say what is not true.
- Watch the film before it is submitted.

## Who did what

| | Me | Claude (Claude Code, `claude-opus-5-5`) |
|---|---|---|
| Effects and jobs | chose both, the node types, the pause behaviour | listed options with facts from my code |
| Brief | decisions, predicted failures, price guesses, six answers, Revisions 1–2 | typed sections A and B and the revisions; measured contrast; Revision 5 under my delegation |
| Build and tests | approved the puff plans | wrote the scenes, drivers, previews and tests (`claude -p`), reviewed and re-ran them |
| Tuning | first looks and every verdict | strip readings, proposals, predictions, comparisons, the two edits |
| Captures | r0 of the puff | the later captures, at my request |
| Human checks | every look, verdict, edge and start check, the Godot 3 rename in play, the Step 6 conversion and answers, reading the Visual Profiler | launched the windows, made the fixtures that let the game play itself, located the shader line numbers, recorded my words |
| Rejected or changed | the jump trigger (moved to the landing) | Claude declined to write my predictions and answers |
