#!/usr/bin/env bash
# A7 Step 6 mutations: each change is made in a fresh git worktree of HEAD, the named test runs
# through scripts/run-test.sh there, and the worktree is removed. The working tree is never touched.
# Run from the repository root: a7/evidence/mutations/run_mutations.sh
# Writes one result file per mutation next to this script.
set -u
repo=$(pwd)
out="$repo/a7/evidence/mutations"
wt="$repo/../a7-mutate"

# mutate <id> <test-file> <timeout> <python-snippet that edits files under the worktree's godot/>
mutate() {
    local id=$1 test=$2 secs=$3 edit=$4
    git worktree remove --force "$wt" 2>/dev/null
    git worktree add -q "$wt" HEAD
    (cd "$wt" && timeout 300 godot --headless --path godot --import > /dev/null 2>&1)
    (cd "$wt" && python3 -c "$edit")
    local diff
    diff=$(cd "$wt" && git diff --stat && git diff | head -40)
    (cd "$wt" && ./scripts/run-test.sh "$test" 60 "$secs" > /dev/null 2>&1)
    local status=$?
    local log="$wt/logs/$(basename "$test" .gd)_60fps.log"
    {
        echo "mutation: $id"
        echo "worktree of: $(git rev-parse --short HEAD)"
        echo "test: scripts/run-test.sh $test 60   exit $status"
        echo "--- change"
        echo "$diff"
        echo "--- failing checks and result line"
        grep -E '"status":"FAIL"|RESULT:|SCRIPT ERROR|Failed loading' "$log" | cut -c1-600
    } > "$out/$id.txt"
    echo "$id: exit $status"
    git worktree remove --force "$wt"
}

# 1a. Break the toss track's subname (in the clip only): Sprite:frame -> Sprite:frames.
mutate 1a-toss-subname test_toss_readback.gd 120 '
import re; p="godot/animations/joe.tres"; s=open(p).read()
tid=re.search(r"&\"toss\": SubResource\(\"([^\"]+)\"\)", s).group(1)
start=s.index("id=\""+tid+"\""); end=s.index("[sub_resource", start+1) if "[sub_resource" in s[start+1:] else s.index("[resource]", start)
block=s[start:end].replace("NodePath(\"Sprite:frame\")","NodePath(\"Sprite:frames\")",1)
open(p,"w").write(s[:start]+block+s[end:])'
# 1b. Break the wave track's subname (in the clip only): Shoulder:rotation -> Shoulder:rotaton.
mutate 1b-wave-subname test_wave_readback.gd 120 '
p="godot/features/survivor/survivor_person.tscn"; s=open(p).read()
open(p,"w").write(s.replace("NodePath(\"Shoulder:rotation\")","NodePath(\"Shoulder:rotaton\")",1))'
# 2. Flip the cycle loop mode: the wave LOOP_LINEAR (1) -> LOOP_NONE (0).
mutate 2-wave-loop-none test_wave_readback.gd 120 '
p="godot/features/survivor/survivor_person.tscn"; s=open(p).read()
open(p,"w").write(s.replace("loop_mode = 1","loop_mode = 0",1))'
# 3. Key a cell the sheet does not have: the toss's throw key 9 -> 12 (= hframes x vframes).
mutate 3-toss-cell-12 test_toss_readback.gd 120 '
import re; p="godot/animations/joe.tres"; s=open(p).read()
tid=re.search(r"&\"toss\": SubResource\(\"([^\"]+)\"\)", s).group(1)
start=s.index("id=\""+tid+"\""); end=s.index("[resource]", start) if "[sub_resource" not in s[start+1:] else s.index("[sub_resource", start+1)
block=s[start:end].replace("\"values\": [8, 9, 1]","\"values\": [8, 12, 1]",1)
open(p,"w").write(s[:start]+block+s[end:])'
# 5 (extra). A second writer on Joe's sprite: show_pose() also sets sprite.frame = 0.
mutate 5-second-writer test_anim_states.gd 180 '
p="godot/features/player/player.gd"; s=open(p).read()
open(p,"w").write(s.replace("\tpose = state\n\tart.scale","\tpose = state\n\tsprite.frame = 0\n\tart.scale",1))'

# 4. Reimport from an empty cache: delete godot/.godot, import, run both read-backs (no edit).
git worktree remove --force "$wt" 2>/dev/null
git worktree add -q "$wt" HEAD
(cd "$wt" && rm -rf godot/.godot && timeout 300 godot --headless --path godot --import > /dev/null 2>&1)
(cd "$wt" && ./scripts/run-test.sh test_toss_readback.gd 60 > /dev/null 2>&1); s1=$?
(cd "$wt" && ./scripts/run-test.sh test_wave_readback.gd 60 > /dev/null 2>&1); s2=$?
{
    echo "mutation: 4-empty-import-cache (no edit; godot/.godot deleted, then --import)"
    echo "worktree of: $(git rev-parse --short HEAD)"
    echo "cache existed before the import: $( [ -d "$wt/godot/.godot" ] && echo yes-after-import || echo no )"
    echo "test_toss_readback exit $s1: $(grep 'RESULT:' "$wt/logs/test_toss_readback_60fps.log")"
    echo "test_wave_readback exit $s2: $(grep 'RESULT:' "$wt/logs/test_wave_readback_60fps.log")"
    echo "expected: both pass. The wave is keyed in the scene and Joe's clips are a committed .tres, so"
    echo "nothing lives in the import cache; an imported rig with its loop mode set in the scene would lose it here."
} > "$out/4-empty-import-cache.txt"
echo "4-empty-import-cache: toss $s1 wave $s2"
git worktree remove --force "$wt"
