"""Write gamedev-evidence.json (schema 1, code-then-result-v1) for the A7 film (written by Claude Code).

    python scripts/evidence.py      # then: ./art godot-gamedev --check <reel> --game <repo>/godot

Every file in godot/ (except .godot/ and .uid) is hashed and assigned to one component with the beats that explain it.
This film is about the A7 layer (the survivor's wave rig, Joe's sheet and toss clip, the state-machine wiring, the
read-back, pin, state and edge tests, the previews); the earlier layers (A2 game, A3 props, A5 shaders, A6 effects) are
one component pointing at the beats that show the game. Excerpts and code/result pairs come from evidence/excerpts.json.
"""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAME = ROOT.parents[1] / "godot"
SHEET = json.loads((ROOT / "beat_sheet.json").read_text())


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def beat(heading):
    return next(b["beat_id"] for b in SHEET["beats"] if b["heading"] == heading)


WAVE = ("features/survivor/survivor_person.tscn", "game/session.gd", "previews/wave_preview.tscn", "previews/wave_preview.gd")
TOSS = ("features/player/joe_art.tscn", "animations/joe.tres", "tools/bake_joe_clips.gd", "features/player/player.gd",
        "art/character/joe_sheet.png", "art/character/joe_sheet.png.import", "art/character/ATTRIBUTION.md",
        "previews/toss_preview.tscn", "previews/toss_preview.gd")
TESTS = ("tests/anim_checks.gd", "tests/test_toss_readback.gd", "tests/test_wave_readback.gd", "tests/test_pins_a7.gd",
         "tests/test_anim_states.gd", "tests/test_toss_edges.gd", "tests/probe_a7_headless.gd")

COMPONENTS = [
    ("survivor-wave", "The cycle, the person survivor's wave: the cutout rig rebuilt from the session's old drawing as Polygon2D parts, the Shoulder pivot and its wave clip keyed as resource text; session.gd, which places the rig once, hides it on rescue and shows it on restart; and the wave viewing fixture.",
     lambda p: p in WAVE, ["A clip is a list of keys", "The wave in play", "The game, the two clips"]),
    ("toss-sheet", "The committing action, Joe's survivor toss: the sheet packed from the A2 poses (with its import settings and credits), Joe's art scene with the sliced Sprite and the manual-callback AnimationPlayer, the clip library baked from the phase table, the player's state machine that plays one clip per state and advances it on the physics tick, and the frame-strip fixture.",
     lambda p: p in TOSS, ["The sheet and its slicing", "The real sheet", "Feel in frames", "The first strip", "One authority",
                           "The toss in play, interrupted", "Two clocks", "Pause and restart"]),
    ("a7-tests", "The A7 tests: the shared read-back helper (track_problems), both read-backs, the Step 2 pins, the structure and state test, the phase-boundary edge test, and the headless probe.",
     lambda p: p in TESTS, ["A wrong name fails silently", "What the read-backs caught", "What the pins caught", "What Claude got wrong"]),
    ("earlier-layers", "The game this layer is added to: the A2 2D game (level, HUD, generated art and audio, its tests and project settings), the A3 props room, the A5 shaders and materials, and the A6 particle effects with their drivers, previews and tests; unchanged in A7 except player.gd and session.gd, which belong to the components above.",
     lambda p: True, ["The game, the two clips", "The wave in play"]),
]
EXCLUDE = {".gitignore": "Repository hygiene (engine cache and local files ignored); not part of the running game."}
OBSERVATIONS = {
    "The wave in play": "Scripted-input take 10.5-15.9 s (Movie Maker, 4K): while Joe hoses the blocking fire the person in the window swings the raised arm out and back, one wave every 0.8 s; play-states.jsonl logs the Shoulder rotation each tick (0.346 rad at tick 800).",
    "The real sheet": "The committed sheet file joe_sheet.png magnified 3x with its 4 x 3 slicing, the cell numbers and the shared anchor (70, 133) drawn on top: cell 8 grab, 9 toss, 1 respawn are the three cells the toss uses.",
    "The first strip": "Fixture capture r0 (Movie Maker 30 fps, the real game at the window): per logs/toss_preview_r0.log, tick 0 the grab, tick 14 the throw with the survivor launched in the same frame, tick 30 the ready stance, tick 46 idle.",
    "What the read-backs caught": "Recorded headless output at the source revision: read-backs 66/66 and 13/13; the five mutation records, each exit 1 on its named check (track_problems names 'Sprite has no property frames'), and the empty-cache rebuild passing both read-backs.",
    "The toss in play, interrupted": "Scripted-input take 15.85-17.25 s and a labelled 0.25x replay: the grab on 16.02 s, a jump on toss frame 7, the toss cells continue in the air, the throw with the survivor launched on frame 14, the ready stance on 30, then the rising pose.",
    "Pause and restart": "Scripted-input take 19.4-21.9 s: the dog's toss; Esc in the active phase freezes the clip at 0.3667 s (cell 9) for 45 ticks behind the pause card, then it resumes; R on recovery frame 36 cuts it with the respawn stance at the spawn point.",
}


def main():
    files = sorted(p.relative_to(GAME).as_posix() for p in GAME.rglob("*")
                   if p.is_file() and not any(x in (".godot", ".git") for x in p.relative_to(GAME).parts) and p.suffix != ".uid")
    comps = {cid: {"id": cid, "explanation": ex, "beat_ids": [beat(h) for h in heads], "files": []} for cid, ex, _, heads in COMPONENTS}
    records, exclusions = [], []
    for f in files:
        if f in EXCLUDE:
            exclusions.append({"path": f, "reason": EXCLUDE[f]})
            continue
        cid = next(c for c, _, match, _ in COMPONENTS if match(f))
        comps[cid]["files"].append(f)
        records.append({"path": f, "sha256": sha(GAME / f), "role": comps[cid]["explanation"].split(":")[0], "component_ids": [cid]})
    ex = json.loads((ROOT / "evidence/excerpts.json").read_text())
    beats = {b["beat_id"]: b for b in SHEET["beats"]}
    pairs = []
    for code, result in ex["pairs"]:
        media = beats[result]["shot"]["evidence_media"]
        pairs.append({"code_beat": code, "result_beat": result, "observation": OBSERVATIONS[beats[result]["heading"]],
                      "media": {"path": media, "sha256": sha(ROOT / media)}})
    data = {"schema_version": 1, "teaching_contract": "code-then-result-v1", "source_revision": SHEET["metadata"]["source_revision"],
            "files": records, "components": list(comps.values()), "excerpts": ex["excerpts"], "exclusions": exclusions,
            "code_result_pairs": pairs}
    (ROOT / "gamedev-evidence.json").write_text(json.dumps(data, indent=2) + "\n")
    print(len(records), "files,", len(exclusions), "excluded,", len(comps), "components,", len(ex["excerpts"]), "excerpts,", len(pairs), "pairs")
    for c in comps.values():
        print(f"  {c['id']}: {len(c['files'])} files")


if __name__ == "__main__":
    main()
