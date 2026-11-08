#!/usr/bin/env bash
# scripts/run-all-tests.sh — runs every suite through scripts/run-test.sh in the mode CLAUDE.md gives
# it and prints one summary line per run, then the expected-versus-actual verdict. Run from the
# repository root. test_audio at a pinned 60 fps has two known failures (a5/TEST-REPORT.md); every
# other run must exit 0. Exit 1 if any run differs from that.
set -u
cd "$(dirname "$0")/.."
bad=0
run() {
    local file=$1 mode=$2 timeout=${3:-} expect=${4:-0}
    ./scripts/run-test.sh "$file" "$mode" $timeout > /dev/null 2>&1
    local status=$?
    local tag=$([ "$mode" = realtime ] && echo realtime || echo "${mode}fps")
    local log="logs/$(basename "$file" .gd)_${tag}.log"
    local pass=$(grep -c '"status":"PASS"' "$log")
    local fail=$(grep -c '"status":"FAIL"' "$log")
    local summary=$(grep -h -E "TESTS:|CONFIG: [0-9]|STATE:|RESULT:|COST EFFECTS" "$log" | grep -v features | tail -1 | cut -c1-70)
    local errors=$(grep -c -E "SHADER ERROR|SCRIPT ERROR" "$log")
    local ok="ok"
    if [ "$status" != "$expect" ] || [ "$errors" != 0 ]; then ok="UNEXPECTED"; bad=1; fi
    printf "%-26s %-9s exit %-3s (expected %s) PASS %-3s FAIL %-2s %-10s | %s\n" "$file" "$mode" "$status" "$expect" "$pass" "$fail" "$ok" "$summary"
}
echo "Godot: $(godot --version 2>/dev/null)   revision: $(git rev-parse --short HEAD)   $(date '+%Y-%m-%d %H:%M')"
run test_game.gd 60
run test_keyboard.gd 60
run test_audio.gd 60 "" 1
run test_audio.gd realtime 300
run check_props.gd 60
run test_hose_glow.gd 30
run test_hose_glow.gd 60
run test_hose_glow.gd 144
run test_materials.gd 60
run test_jump_puff_config.gd 60
run test_jump_puff_state.gd 60
run test_hose_steam_config.gd 60
run test_hose_steam_state.gd 60
run cost_effects.gd 60 300
if [ "$bad" = 0 ]; then echo "ALL AS EXPECTED"; else echo "SOMETHING DIFFERS: read the line marked UNEXPECTED"; fi
exit $bad
