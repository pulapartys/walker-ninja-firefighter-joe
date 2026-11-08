"""Write SCRIPT.md, SHOTLIST.md, COMPONENTS.md from beat_sheet.json and gamedev-evidence.json (written by Claude Code)."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sheet = json.loads((ROOT / "beat_sheet.json").read_text())
ev = json.loads((ROOT / "gamedev-evidence.json").read_text())
T = sheet["metadata"]["title"]
script = [f"# {T}", "",
          "Final narration as voiced by Liam (Kokoro am_onyx), generated from beat_sheet.json. Script v3 (layman-technical, 5:00–5:30 at Sreeja's request), "
          "drafted by Claude Code from the A6 record and approved by Sreeja (SCRIPT-DRAFT.md).", "",
          "**One change to the approved text, for accuracy (B11):** \"so the steam keeps drifting, which Sreeja chose\" is voiced as \"so the steam keeps drifting "
          "behind the pause card, which Sreeja chose\". The scripted-input take shows the game's pause card covering the fire and the steam while Esc is down; "
          "the steam keeps simulating (the state test shows it) but cannot be seen. Nothing was trimmed: the measured narration is 5:06 and the film 5:13.", ""]
shots = ["# SHOTLIST", "", f"{T} · native 3840×2160 · 30 fps · game source revision {sheet['metadata']['source_revision']}", "",
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
