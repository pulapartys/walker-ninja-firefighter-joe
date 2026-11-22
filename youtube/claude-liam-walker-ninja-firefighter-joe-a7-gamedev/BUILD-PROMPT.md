# BUILD-PROMPT

Sreeja asked Claude Code to finish Assignment 7 while she was away from the laptop ("don't stop until i tell you to, keep going until you finihs the assignemnt requireemnts"). The main session handed the required Brutalist `godot-gamedev` walker explainer to a background copy of itself (a fork) with these limits: build the film folder and a draft that proves the pipeline; leave her verdicts as **TODO-HUMAN** beats; never narrate an invented verdict; no final 4K render, commit or push. The register follows her A6 request ("very slightly technical ... layman technical"). The script (SCRIPT-DRAFT.md v1) is **not yet approved by her**.

The fork:
- wrote the capture driver, the beat sheet, stills, build, evidence and doc scripts (adapted from the A6 film's);
- recorded the scripted-input Movie Maker take on an isolated git worktree of the game at `7848c6e`;
- generated the Kokoro narration for every non-pending beat;
- rendered a draft.

Build steps, from this folder with the Brutalist toolkit's venv Python. `./art final` calls plain `python3` for its gates, so put `<brutalist>/.venv/bin` first on `PATH` (A5 lesson).

    python scripts/author.py stills sheet                  # draft; A7_FILM_PENDING=1 adds the TODO-HUMAN beats as pending cards
    ART_HOME=<brutalist> python <brutalist>/runtime/scripts/generate_audio_kokoro.py <this folder>
    python scripts/build.py lock && python scripts/build.py footage
    BRUTALIST=<brutalist> python scripts/render.py
    python scripts/evidence.py && python scripts/docs.py
    <brutalist>/art godot-gamedev --check <this folder> --game <repo>/godot
    <brutalist>/art final <this folder> --height 2160 --fps 30 --out <this folder>/exports/landscape

`author.py sheet` rewrites `beat_sheet.json` and drops the locked durations. After `build.py lock`, patch the JSON directly for small changes.

**To finish (main session, after her verdicts):** write H1–H3 in SCRIPT-DRAFT.md from her recorded words in a7/TUNING.md and a7/TEST-REPORT.md; add them to `build_sheet()` as narrated beats (r0/r1 fixture captures for H2); restore B18's credit line and the verdict card to "eye-tested and played by Sreeja" (TODO-HUMAN note in SCRIPT-DRAFT.md B18), update the verdict's "Her eyes" line, and REV if the game source changed (re-record the take if the toss changed); then re-run every step above with the final 4K `art final`.
