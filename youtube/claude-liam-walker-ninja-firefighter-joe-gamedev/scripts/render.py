"""Render this film's Remotion beats through Brutalist's canonical wrapper (written by Claude Code).

    BRUTALIST=<path to brutalist.art> python scripts/render.py [--only B00 B01] [--force]

Uses runtime/scripts/remotion_scenes.py (render_beat, stamp, update_consumers) unchanged,
pointed at this reel's own Remotion entry. The toolkit path comes from $BRUTALIST, so no
machine path is stored in the repository.
"""
import argparse
import importlib.util
import json
import os
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ART = Path(os.environ.get("BRUTALIST", Path.home() / "Desktop" / "brutalist.art"))
SHEET = ROOT / "beat_sheet.json"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--only", nargs="*")
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--sheet", default=str(SHEET))
    args = ap.parse_args()
    sys.path.insert(0, str(ART / "runtime/scripts"))
    spec = importlib.util.spec_from_file_location("canonical", ART / "runtime/scripts/remotion_scenes.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    mod.PROJECT = ROOT / "remotion"
    mod.ENTRY = "src/index.tsx"
    mod.CONSUMERS = ROOT / "remotion" / "consumers.json"
    # Evidence images used by EvidencePanel beats are copied into the Remotion public folder.
    for p in (ROOT / "media" / "stills").glob("*"):
        shutil.copy2(p, ROOT / "remotion" / "public" / p.name)
    sheet_path = Path(args.sheet)
    sheet = json.loads(sheet_path.read_text())
    for b in sheet["beats"]:
        if not b["shot"].get("remotion") or (args.only and b["beat_id"] not in args.only):
            continue
        print("RENDER", b["beat_id"], b["shot"]["remotion"]["pattern"], flush=True)
        result = mod.render_beat(ROOT, b, args.force)
        print(result, flush=True)
        if result.startswith("FAIL"):
            raise SystemExit(result)
        mod.stamp(b, ROOT, datetime.now(timezone.utc).isoformat())
        sheet_path.write_text(json.dumps(sheet, indent=2) + "\n")
    mod.update_consumers(sheet, ROOT)


if __name__ == "__main__":
    main()
