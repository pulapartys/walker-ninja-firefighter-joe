"""Write gamedev-evidence.json (schema 1, code-then-result-v1) for this film (written by Claude Code).

    python scripts/evidence.py      # then: ./art godot-gamedev --check <reel> --game <game>/godot

Every file in godot/ (except .godot/ and .uid) is hashed and assigned to a component with the
beats that explain it; excerpts and code/result pairs come from evidence/excerpts.json (author.py).
"""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAME = ROOT.parents[1] / "godot"
SHEET = json.loads((ROOT / "beat_sheet.json").read_text())


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


COMPONENTS = [
    ("player-states", "The player body: movement tuning, the 20×40 collision box, and one generated image per state chosen by _update_pose and shown by show_pose (mirrored when facing left).",
     lambda p: p.startswith("features/player/"), ["B06", "B08", "B10"]),
    ("character-art", "The generated character images as game textures (background removed, one shared scale, 128 px tall, drawn at half size) with their feet anchors, plus the two generated close-ups.",
     lambda p: p.startswith("art/character/"), ["B05", "B09"]),
    ("environment-art", "ENV-BG v2 behind the level and the three generated flames drawn over the unchanged hazard rectangles.",
     lambda p: p.startswith("art/env/"), ["B12"]),
    ("session-events-audio", "The game session: state machine, hazards, rescue toss, sound playback after each state change, two audio buses, and music that follows the state.",
     lambda p: p.startswith("game/"), ["B14", "B18"]),
    ("level-data", "The level as data: ledges, buildings, hazard rectangles (which still decide what burns), survivors, and the exit.",
     lambda p: p.startswith("levels/"), ["B12"]),
    ("hud", "The HUD: controls including N/B mute, mute indicators, death reasons, and the DEVASTATED and bow close-ups.",
     lambda p: p.startswith("ui/"), ["B15", "B19"]),
    ("audio-assets", "The five generated sound effects and the 16-bar music loop (Loop on in its import settings).",
     lambda p: p.startswith("audio/"), ["B13", "B17"]),
    ("tests", "Automated checks: the A1 mechanics suite, real keyboard events, the added sound test (one sound per event; mute and missing files change nothing), and the screenshot capture.",
     lambda p: p.startswith("tests/"), ["B20"]),
    ("project-config", "Project settings: 640×360 game in a 1280×720 window, physics at 60 Hz, the main scene.",
     lambda p: p == "project.godot", ["B01"]),
]
EXCLUDE = {".gitignore": "Repository hygiene (engine cache and local files ignored); not part of the running slice."}


def main():
    files = sorted(p.relative_to(GAME).as_posix() for p in GAME.rglob("*")
                   if p.is_file() and ".godot" not in p.relative_to(GAME).parts and p.suffix != ".uid")
    comps = {cid: {"id": cid, "explanation": ex, "beat_ids": beats, "files": []} for cid, ex, _, beats in COMPONENTS}
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
    observations = {
        "B07": "The grab, the toss pose with the arm flung up, and the survivor spinning up and into the bag, in real play.",
        "B09": "Each state image appears on its real event: respawn, idle, run, kick, landing, hose, grab, toss, bow, facing left, the fall, burned.",
        "B11": "On real screenshots the cyan 20×40 box sits on the torso and legs; helmet, kick, and hose extend past it.",
        "B15": "The fire death shows the burned pose and the DEVASTATED close-up for 2 s, then the respawn stance at the start.",
        "B19": "With both buses muted the HUD shows MUSIC OFF and SOUND OFF and the run plays the same.",
    }
    pairs = []
    for code, result in ex["pairs"]:
        media = beats[result]["shot"]["evidence_media"]
        pairs.append({"code_beat": code, "result_beat": result, "observation": observations[result],
                      "media": {"path": media, "sha256": sha(ROOT / media)}})
    data = {"schema_version": 1, "teaching_contract": "code-then-result-v1", "source_revision": SHEET["metadata"]["source_revision"],
            "files": records, "components": list(comps.values()), "excerpts": ex["excerpts"], "exclusions": exclusions,
            "code_result_pairs": pairs}
    (ROOT / "gamedev-evidence.json").write_text(json.dumps(data, indent=2) + "\n")
    print(len(records), "files,", len(exclusions), "excluded,", len(comps), "components,", len(ex["excerpts"]), "excerpts,", len(pairs), "pairs")


if __name__ == "__main__":
    main()
