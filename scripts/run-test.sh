#!/usr/bin/env bash
# scripts/run-test.sh <test-file.gd> <fps>
# Runs one headless Godot test under a time limit, pins the frame rate, keeps a log,
# and fails on SHADER ERROR / SCRIPT ERROR lines (Godot can exit 0 with errors).
# Exit 124 = the test hung. GODOT may point at the binary; it defaults to the one in PATH,
# then to the macOS app in ~/Downloads.
set -o pipefail
GODOT="${GODOT:-godot}"
if ! command -v "$GODOT" >/dev/null 2>&1; then
  GODOT="$HOME/Downloads/Godot.app/Contents/MacOS/Godot"
fi
cd "$(dirname "$0")/.."
mkdir -p logs
log="logs/$(basename "$1" .gd)_${2}fps.log"
timeout 120 "$GODOT" --headless --path godot --script "res://tests/$1" --fixed-fps "$2" 2>&1 | tee "$log"
status=$?
if grep -qE "SHADER ERROR|SCRIPT ERROR" "$log"; then status=1; fi
exit $status
