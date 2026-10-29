"""Write SCRIPT.md, SHOTLIST.md, COMPONENTS.md from beat_sheet.json and gamedev-evidence.json (written by Claude Code)."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sheet = json.loads((ROOT / "beat_sheet.json").read_text())
ev = json.loads((ROOT / "gamedev-evidence.json").read_text())
T = sheet["metadata"]["title"]
script = [f"# {T}", "", "Final narration as voiced by Liam (Kokoro am_onyx), generated from beat_sheet.json. Script v4 (the 5½-minute cut, plain voice), drafted by Claude Code from the A5 record and approved by Sreeja (SCRIPT-DRAFT.md).", ""]
shots = ["# SHOTLIST", "", f"{T} · native 3840×2160 · 30 fps · source revision {sheet['metadata']['source_revision']}", "",
         "| Beat | Heading | Duration (s) | Shot | Evidence on screen |", "|---|---|---|---|---|"]
for b in sheet["beats"]:
    script += [f"## {b['beat_id']} — {b['heading']}", "", b["narration_text"] or "*(no narration)*", ""]
    s = b["shot"]
    kind = s.get("remotion", {}).get("pattern") or ("SCREEN (real captures, full frame)" if s.get("type") == "SCREEN" else "VIDEO (Godot Movie Maker, scripted input)")
    shots.append(f"| {b['beat_id']} | {b['heading']} | {b.get('actual_duration_s', 0):.2f} | {kind} | {s.get('evidence_media', '—')} |")
comp = ["# COMPONENTS", "", "Godot project components covered by the film (`godot/`, hashed in gamedev-evidence.json).", ""]
for c in ev["components"]:
    comp += [f"## {c['id']}", "", c["explanation"], "", f"Files ({len(c['files'])}): " + ", ".join(f"`{f}`" for f in c["files"][:12]) + (" …" if len(c["files"]) > 12 else ""), "", "Beats: " + ", ".join(c["beat_ids"]), ""]
(ROOT / "SCRIPT.md").write_text("\n".join(script) + "\n")
(ROOT / "SHOTLIST.md").write_text("\n".join(shots) + "\n")
(ROOT / "COMPONENTS.md").write_text("\n".join(comp) + "\n")
print("wrote SCRIPT.md SHOTLIST.md COMPONENTS.md")
