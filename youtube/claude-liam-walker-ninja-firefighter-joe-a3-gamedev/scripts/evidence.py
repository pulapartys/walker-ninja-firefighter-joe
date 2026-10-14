"""Write gamedev-evidence.json (schema 1, code-then-result-v1) for the A3 film (written by Claude Code).

    python scripts/evidence.py      # then: ./art godot-gamedev --check <reel> --game <repo>/godot

Every file in godot/ (except .godot/ and .uid) is hashed and assigned to a component with the beats that explain it.
The A2 game files are covered by one component pointing at the beat that shows the 2D game; this film is about the A3
layer (props3d/, scenes3d/, the prop check). Excerpts and code/result pairs come from evidence/excerpts.json.
"""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GAME = ROOT.parents[1] / "godot"
SHEET = json.loads((ROOT / "beat_sheet.json").read_text())
A3_TESTS = ("tests/check_props.gd", "tests/run_check_props.sh", "tests/capture_props.gd")


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def beat(heading):
    return next(b["beat_id"] for b in SHEET["beats"] if b["heading"] == heading)


COMPONENTS = [
    ("props", "The three props exported from Blender as binary glTF (+Y Up, transforms applied), with Godot's import settings: hydrant, rescue backpack, flame.",
     lambda p: p.startswith("props3d/"), ["Barrel to backpack", "One flame first", "In the engine"]),
    ("props-scene", "The 3D props scene: floor, one sun with shadows, camera, the three props placed by translation only, and a 1.8 m size-reference pole.",
     lambda p: p.startswith("scenes3d/"), ["Three props in one scene", "In the engine"]),
    ("prop-check", "The headless prop check (global AABB vs brief, scale chain, up axis, bottom vs floor, triangles), its strict runner that requires a printed PASS, and the screenshot capture.",
     lambda p: p in A3_TESTS, ["The headless check", "The numbers, labelled headless"]),
    ("a2-game", "The Assignment 2 game this layer is added to (2D player, generated art and audio, session, level, HUD, its tests and project settings); unchanged in A3.",
     lambda p: True, ["Why these three"]),
]
EXCLUDE = {".gitignore": "Repository hygiene (engine cache and local files ignored); not part of the running game."}


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
    observations = {
        "In the engine": "A full orbit in the running engine (Movie Maker): hydrant, backpack and flame stand upright with their bases on the floor beside the 1.8 m pole; shadows start at each base.",
        "The numbers, labelled headless": "Recorded headless output: all three props PASS (size = brief to the millimetre, scale 1, height along Y, bottom +0.0000 m vs floor, tris within budget); the planted-fault run FAILS all three.",
    }
    pairs = []
    for code, result in ex["pairs"]:
        media = beats[result]["shot"]["evidence_media"]
        pairs.append({"code_beat": code, "result_beat": result, "observation": observations[beats[result]["heading"]],
                      "media": {"path": media, "sha256": sha(ROOT / media)}})
    data = {"schema_version": 1, "teaching_contract": "code-then-result-v1", "source_revision": SHEET["metadata"]["source_revision"],
            "files": records, "components": list(comps.values()), "excerpts": ex["excerpts"], "exclusions": exclusions,
            "code_result_pairs": pairs}
    (ROOT / "gamedev-evidence.json").write_text(json.dumps(data, indent=2) + "\n")
    print(len(records), "files,", len(exclusions), "excluded,", len(comps), "components,", len(ex["excerpts"]), "excerpts,", len(pairs), "pairs")


if __name__ == "__main__":
    main()
