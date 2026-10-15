#!/bin/zsh
# Runs the A3 headless prop check and passes ONLY if the script printed "RESULT: PASS".
# Godot exits 0 even when a --script fails to parse, so its exit code alone proves nothing (found 2026-10-14).
#   GODOT=/path/to/Godot godot/tests/run_check_props.sh [mutate]
set -u
GODOT="${GODOT:-godot}"
cd "$(dirname "$0")/../.."
out="$(timeout 120 "$GODOT" --headless --path godot --script res://tests/check_props.gd --fixed-fps 60 -- "$@" 2>&1)"
print -r -- "$out" | grep -v -E '^Godot Engine|^$'
print -r -- "$out" | grep -q '^RESULT: PASS' && exit 0
echo "CHECK DID NOT PASS (no 'RESULT: PASS' line)"; exit 1
