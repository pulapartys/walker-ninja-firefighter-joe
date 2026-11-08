"""Write gamedev-evidence.json (schema 1, code-then-result-v1) for the A6 film (written by Claude Code).

    python scripts/evidence.py      # then: ./art godot-gamedev --check <reel> --game <repo>/godot

Every file in godot/ (except .godot/ and .uid) is hashed and assigned to one component with the beats that explain it.
This film is about the A6 layer (two particle effects, their drivers, previews, tests, the generated process shader and
the price instruments); the earlier layers (A2 game, A3 props, A5 shaders) are one component pointing at the beats that
show the game. Excerpts and code/result pairs come from evidence/excerpts.json.
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


PUFF = ("effects/jump_puff.tscn", "features/player/jump_puff_driver.gd", "features/player/player.gd", "previews/jump_puff_preview.tscn",
        "previews/jump_puff_preview.gd", "tests/test_jump_puff_config.gd", "tests/test_jump_puff_state.gd", "effects/ATTRIBUTION.md")
STEAM = ("effects/hose_steam.tscn", "features/player/hose_steam_driver.gd", "previews/hose_steam_preview.tscn", "previews/hose_steam_preview.gd",
         "tests/test_hose_steam_config.gd", "tests/test_hose_steam_state.gd")
SHADER = ("shaders/particles_generated.gdshader", "previews/scratch_process_material.tscn", "tests/make_scratch_process_material.gd")
PRICE = ("tests/cost_effects.gd", "tests/gpu_price_effects.gd", "previews/gpu_price_preview.tscn", "previews/gpu_price_preview.gd",
         "features/debug/vsync_key.gd")

COMPONENTS = [
    ("landing-puff", "Effect A, the landing puff: three CPUParticles2D emitters in one scene file with a scene-defined texture (ATTRIBUTION.md), the driver that adds a fresh puff behind Extinguisho on every landed signal, the player script's landed signal and driver hooks, the preview fixture, and its configuration and state tests.",
     lambda p: p in PUFF, ["Three parts of a particle system", "Effect A, built", "The first strip", "Her decision from play: the landing", "Tuning the puff", "What the tests proved"]),
    ("hose-steam", "Effect B, the hose steam: two GPUParticles2D emitters with turbulence and a box emitter in one scene file, the driver that writes emitting, amount_ratio from the fire's height and the position, the preview fixture, and its configuration and state tests.",
     lambda p: p in STEAM, ["Effect B: a feedback loop", "Steam: her look, one change", "Steam in play", "What the tests proved"]),
    ("process-shader", "The process step as a shader: Godot's own code generated from a unique copy of the steam's ParticleProcessMaterial (converted by Sreeja in the editor), the scratch scene that holds the copy, and the helper that wrote it; nothing in the game uses them.",
     lambda p: p in SHADER, ["The process step is a shader"]),
    ("price", "The price instruments: the headless CPU cost script with its empty-scene control, the windowed GPU-time helper and the self-playing fixture used with the Visual Profiler under Mobile + Vulkan, and the F9 vsync debug key.",
     lambda p: p in PRICE, ["The price, twice"]),
    ("earlier-layers", "The game this layer is added to: the A2 2D game (session, level, HUD, generated art and audio, its tests and project settings), the A3 props room and the A5 shaders, materials, textures and their tests; unchanged in A6 except the player's landed signal and driver hooks.",
     lambda p: True, ["The game, the two jobs", "Steam in play"]),
]
EXCLUDE = {".gitignore": "Repository hygiene (engine cache and local files ignored); not part of the running game."}
OBSERVATIONS = {
    "The first strip": "Fixture capture r0 of the puff preview (Movie Maker, 30 fps): triggered on frame 10, a white cluster with dark specks; about 20 px across by frame 12 and 25 px by frame 15; a pale haze by frame 20 that nearly melts into the tan wall; faint at 30; gone at 50.",
    "Steam: her look, one change": "Fixture captures of the steam preview, r0 against r1 at frames 16 and 40: r0's white steam barely shows on the pale sky; r1's darker, more solid haze shows the first grey puff at frame 16 and a defined grey cloud around the white steam at frame 40.",
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
