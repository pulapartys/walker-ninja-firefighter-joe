# FRICTIONAL — Assignment 7

An honest log of what I tried, what happened, what I checked and what I learned. Claude Code organised these notes from our chat and the commits; my own words are quoted as I typed them. Where something is Claude's work or Claude's reading, it says so. Tuning revisions are in [TUNING.md](TUNING.md), not copied here.

## 1. The account check

- **What I asked:** "we need to use my northeastern github for all commits, make sure this session is authenticated with pulapartys."
- **What was checked (Claude):** the repository pins `pulapartys <pulaparty.s@northeastern.edu>` locally, pushes use a credential helper that asks `gh` for the pulapartys token, the token can push to `pulapartys/walker-ninja-firefighter-joe`, and a dry-run push succeeded. Every A7 commit's author is pulapartys (`git log --format='%an'`).

## 2. The run cycle I wanted first (parked)

- **What I tried:** a running cycle for Joe from ChatGPT, before the required work. Claude wrote four rounds of prompts; I sent them, downloaded the results and judged them. Details and outcomes: [SOURCES.md](SOURCES.md), "Run-cycle attempt".
- **What happened:** the first sheet looked like Joe but, in my words, "the running looks fak because only one leg folds everytime it should b alternate legs". Claude's measurements agreed (frames 1 and 3 were 86% the same outline, 2 and 4 82%) and found the head drifting about 30 px between frames. A single-frame edit fixed one fold, but I still judged that "it doesn;t look like the legs alternate". An eight-frame sheet came back with its bottom row copied from the top. Splitting the job into two small edits per frame (shade the far leg, then swap the shading) finally worked for frames 1 and 2. In a long chat, ChatGPT edited the previous image instead of the one I attached; a new chat per frame fixed that.
- **What I learned:** from the side, a left step and a right step have the same outline, so the only thing that shows which leg is which is shading and overlap. A generator asked for many things at once drops that; asked for one small edit at a time, it can do it.
- **Decision (mine):** "make sure we atleast meet the basic requiremnts first". The run cycle is parked with frames 1–2 done; it is not in the game or the graded clips.

## 3. Choosing the two clips

- **First plan (Claude's suggestion):** a run cycle from a sheet and the toss as a rig. **What changed it:** Claude found my A2 poses are painted images with overlapping limbs, which cannot be cut into a rig without holes.
- **Final plan (I approved it: "yes , go wiht it"):** the trapped person's wave as a cutout rig (the cycle), because the person is already drawn in code with one arm raised; Joe's toss as a sprite-sheet frame track (the committing action), packed from my existing poses so no new art was needed.

## 4. What the agent session did (Step 1)

- **The `claude -p` run** (read-only tools) wrote the CLAUDE.md draft: 39 turns, ended normally, four Bash denials (it tried `godot --version` three times and `git tag` once, outside its allowlist). Every file reference it gave held when checked. Its "Unconfirmed" list was useful: it noticed the brief never gave the shoulder pivot, how the rig is placed, or the test names. Those became brief Revision 1.
- **What the review changed:** the four required "Headless facts" lines, each confirmed first by a probe on this machine (`a7/evidence/probes/probe_a7_headless_60fps.log`).

## 5. What the pins caught (Step 2)

- **Expectation (in the brief, worked out by reading code):** the survivor launches on frame 15 after the touch, the landing lasts 20 ticks.
- **What the pins measured:** the launch is on frame 14 (the flight's counter already counts on the touch tick) and the landing is 19 ticks. So my brief's "0 seconds of disagreement" was wrong by one tick before anything was built. This is the off-by-one failure the brief itself predicted.
- **Response:** Revision 2 changed the phase table (the throw now begins on frame 14), and the keys were built from the revised table. The pins also found a pre-existing bug: R while still standing on a rescued survivor's window rescues them again at once. It is game logic outside this change, so it is recorded, pinned as it is, and not fixed.

## 6. Building and testing (Steps 3–6, Claude in the interactive session)

- **Why not `claude -p` for these steps:** packing the sheet needs Python and baking the clips needs a headless Godot tool script; neither is in the course's `claude -p` allowlist. The prompts are saved in `a7/prompts/` with a note saying where they ran.
- **Test bugs found on the way (Claude's, fixed before commit):** the state test compared the sheet before it had stored it (30 false "texture changed" ticks), and the edge test compared the hand-back frame 46 against the table. Both were in the tests, not the game; the failing runs are in the session, the fixes in the Step 5 and 6 commits.
- **Mutations:** see [TEST-REPORT.md](TEST-REPORT.md), "Mutations".

## 7. Still mine to do

These need my eyes and my words; Claude cannot do them for me.

- [ ] Play the game and watch the wave for at least five wraps; write what I see.
- [ ] Trigger the toss many times in play, including an interrupt in each phase; say whether grab, throw and settle read as three distinct phases.
- [ ] Look at the r0 frame strip before reading Claude's reading, and write my first verdict in TUNING.md.
- [ ] Make at least one change because of something I saw in the running game, and judge the result.
- [ ] Check both clips over the darkest and lightest level art they appear on.
- [ ] Watch the final film.

## Human and AI contributions

| Part | Me | Claude Code |
|---|---|---|
| Account and repo setup | asked for the Northeastern account | checked and confirmed it |
| Run cycle (parked) | sent every ChatGPT prompt, downloaded and judged every result, spotted the fake-looking legs | wrote the prompts, cut and measured the frames, made the previews |
| Clip choice and plan | approved the plan, chose to do the basics first | proposed the clips and routes, found why the toss couldn't be a rig |
| Brief and revisions | decisions (clips, order, the parked run cycle) | typed the brief at my instruction; found Revision 1's gaps and Revision 2's measured corrections |
| CLAUDE.md | — | the draft (`claude -p`) and the review edits |
| Sheet, clips, rig, wiring | — | all code, scenes, the sheet packer and the clip baker |
| Tests and mutations | — | pins, read-backs, state, edge and mutation runs |
| Strips, verdicts, tuning | see section 7 | captures and readings, labelled as Claude's |
