# BUILD-PROMPT

Sreeja asked Claude Code to make the required Brutalist `godot-gamedev` walker explainer for Assignment 5 ("start the film, pause at the script and show me the script"), asked for a more technical version, then a subtler one ("too technical, we want it to be subtle"), then a 5–6 minute cut, and approved v4 ("approved"). Claude Code wrote the beat sheet, stills, capture, build and evidence scripts, recorded the scripted-input Movie Maker take, generated the Kokoro narration and rendered native 4K. Build steps, from the repository root with the Brutalist toolkit's venv Python. `./art final` calls plain `python3` for its gates, so put `<brutalist>/.venv/bin` first on `PATH` before running it; with the system Python the type gate is skipped and the final-frame check refuses the export (this happened once on this build and was re-run).

    python scripts/author.py stills sheet
    ART_HOME=<brutalist> python <brutalist>/runtime/scripts/generate_audio_kokoro.py <this folder>
    python scripts/build.py lock && python scripts/build.py footage
    BRUTALIST=<brutalist> python scripts/render.py
    python scripts/evidence.py && python scripts/docs.py
    <brutalist>/art godot-gamedev --check <this folder> --game <repo>/godot
    <brutalist>/art final <this folder> --height 2160 --fps 30 --out <this folder>/exports/landscape
