# BUILD-PROMPT

Sreeja asked Claude Code to make the required Brutalist `godot-gamedev` walker explainer for Assignment 6. She asked for 5:00–5:30 ("lets make it 5-5:30"), then a "very slightly technical ... layman technical" register, and approved v3 ("approved"). Claude Code then did the rest:
- wrote the beat sheet, stills, capture, build and evidence scripts;
- recorded the scripted-input Movie Maker take on an isolated copy of the game;
- generated the Kokoro narration;
- rendered native 4K.

Build steps, from this folder with the Brutalist toolkit's venv Python. `./art final` calls plain `python3` for its gates, so put `<brutalist>/.venv/bin` first on `PATH` before running it (A5 lesson).

    python scripts/author.py stills sheet          # after cutting media/takeframes/play-{82,430}.png from capture/play.avi
    ART_HOME=<brutalist> python <brutalist>/runtime/scripts/generate_audio_kokoro.py <this folder>
    python scripts/build.py lock && python scripts/build.py footage
    BRUTALIST=<brutalist> python scripts/render.py
    python scripts/evidence.py && python scripts/docs.py
    <brutalist>/art godot-gamedev --check <this folder> --game <repo>/godot
    <brutalist>/art final <this folder> --height 2160 --fps 30 --out <this folder>/exports/landscape

`author.py sheet` rewrites `beat_sheet.json` and drops the locked durations. After `build.py lock`, patch the JSON directly for small changes.
