"""Write gamedev-evidence.json (schema 1, code-then-result-v1) for the A5 film (written by Claude Code).

    python scripts/evidence.py      # then: ./art godot-gamedev --check <reel> --game <repo>/godot

Every file in godot/ (except .godot/ and .uid) is hashed and assigned to a component with the beats that explain it.
This film is about the A5 layer (shaders, materials, textures, driver, tests); the A2 game and the A3 props are
covered by one component each, pointing at the beats that show them. Excerpts and code/result pairs come from
evidence/excerpts.json.
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


GLOW = ("shaders/hose_glow.gdshader", "features/player/hose_glow.gd", "tests/test_hose_glow.gd", "tests/capture_glow.gd")
HINT = ("shaders/hint_experiment.gdshader", "materials/hint_as_color.tres", "materials/hint_as_data.tres", "scenes3d/hint_experiment.tscn",
        "tests/write_grey_strip.gd", "tests/capture_hint.gd")
HYDRANT = ("shaders/hydrant_surface.gdshader", "materials/hydrant_fresh.tres", "materials/hydrant_rusty.tres", "tests/test_materials.gd",
           "tests/normal_map_check.gd", "tests/calibrate_normal_maps.gd", "tests/capture_hydrant.gd", "MATERIALS.md")
GENERATED = ("shaders/standard_generated.gdshader", "scenes3d/scratch_standard.tscn")
A3_TESTS = ("tests/check_props.gd", "tests/run_check_props.sh", "tests/capture_props.gd")

COMPONENTS = [
    ("hose-glow", "The shader from code: the hand-written canvas_item glow shader on Extinguisho's sprite, the agent-written driver that sets its uniform from player.hosing, its headless test at three frame rates, and the in-engine capture script.",
     lambda p: p in GLOW, ["What a shader is", "The colour line, measured", "The driver", "In play, and her revision", "What the tests proved"]),
    ("textured-hydrant", "The textured spatial shader and its two materials on the hydrant, the Poly Haven textures with their credits and explicit import settings, the materials audit, its headless test, the normal-map curl check and calibration, and the sweep capture script.",
     lambda p: p in HYDRANT or p.startswith("art/textures/"), ["Textures as information", "The textured shader", "The interface sweep", "Two materials, one shader", "What the tests proved"]),
    ("hint-experiment", "The hint experiment: the script that writes the 3×1 grey strip, its lossless import, the unshaded shader with two samplers of that file, the two materials and the scene with a Linear tonemap at exposure 1.0, and the capture script.",
     lambda p: p in HINT or p.startswith("art/hint/"), ["The hint experiment", "Predicted, measured"]),
    ("generated-shader", "Godot's own shader, converted in the editor from a StandardMaterial3D with the three rusty-metal textures, and the scratch scene it was made in; nothing in the game uses either.",
     lambda p: p in GENERATED, ["Godot's own shader"]),
    ("props-room", "The Assignment 3 props (hydrant, rescue backpack, flame as binary glTF with import settings; the hydrant's import now binds hydrant_fresh.tres through Use External) and the props room scene with its sun and environment, now holding the second hydrant instance.",
     lambda p: p.startswith("props3d/") or p == "scenes3d/props_room.tscn" or p in A3_TESTS, ["The game, the state, the object", "Two materials, one shader"]),
    ("a2-game", "The Assignment 2 game this layer is added to (2D player and its hosing state, session, level, HUD, generated art and audio, its tests and project settings); unchanged in A5 except the two-line hook that adds the glow driver to the player.",
     lambda p: True, ["The game, the state, the object", "In play, and her revision"]),
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
        "The colour line, measured": "In-engine captures at glow 0.0 / 0.5 / 1.0 / 2.0 (driver frozen, uniform set from code): P1 and P2 land within 2 levels of the brief's hand-computed mix(); at 2.0 the pixels overshoot to cyan, so hint_range did not clamp the code-set value.",
        "In play, and her revision": "Movie Maker take with scripted normal input: Extinguisho walks and jumps to the blocking fire, taps W, the water starts and the sprite brightens into a 0.4–0.8 breath while he stands; when the water stops the glow fades to 0 in a quarter second; per-tick glow values logged in capture/hose-states.jsonl.",
        "The interface sweep": "In-engine captures of the rusty hydrant at each uniform's min / default / max: rust_amount moves the body from (99, 29, 21) to (133, 131, 113), uv_scale from one smear to a fine tile; roughness_scale and normal_strength move the sampled pixel 1–3 levels and show no visible difference under the single sun.",
        "Predicted, measured": "In-engine capture of the two unshaded quads: both read 64 / 128 / 192 (5×5 flat); the colour quad matches its prediction, the data quad does not match the Forward+ prediction of 137 / 188 / 225, because GL Compatibility shades in sRGB space.",
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
    for c in comps.values():
        print(f"  {c['id']}: {len(c['files'])} files")


if __name__ == "__main__":
    main()
