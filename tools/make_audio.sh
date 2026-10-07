#!/bin/bash
# Clean the downloaded ElevenLabs WAVs into game OGGs (written by Claude Code).
# For each sound (ffmpeg): trim silence at the front and the end (below -50 dB), 20 ms fade-out,
# bring it to -14 LUFS with a peak limiter at -1 dBFS. Then encode OGG Vorbis (quality 0.6) with
# libsndfile through Python soundfile, because this ffmpeg build has no libvorbis encoder.
# Rejected takes are kept as small mono OGGs in rejected/audio/ (evidence, not used in the game).
#
#   PY=<python with soundfile> tools/make_audio.sh ~/Downloads   # folder with the raw WAVs (names as in SOURCES.md)
set -euo pipefail
RAW=${1:?folder with the raw WAVs}
HERE=$(cd "$(dirname "$0")/.." && pwd)
OUT=$HERE/godot/audio
REJ=$HERE/rejected/audio
PY=${PY:-python3}
TMP=$(mktemp -d)
mkdir -p "$OUT" "$REJ"
TRIM="silenceremove=start_periods=1:start_threshold=-50dB,areverse,silenceremove=start_periods=1:start_threshold=-50dB,areverse"

to_ogg() {  # to_ogg <in.wav> <out.ogg> <quality 0..1>
  "$PY" -c "import sys, soundfile as sf; d, r = sf.read(sys.argv[1]); sf.write(sys.argv[2], d, r, format='OGG', subtype='VORBIS', compression_level=1 - float(sys.argv[3]))" "$1" "$2" "$3"
}

clean() {   # clean <raw.wav> <out.ogg>
  ffmpeg -hide_banner -loglevel error -y -i "$1" -af "$TRIM" "$TMP/trim.wav"
  local dur lufs gain
  dur=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$TMP/trim.wav")
  lufs=$(ffmpeg -hide_banner -i "$TMP/trim.wav" -af ebur128 -f null - 2>&1 | awk '/Integrated loudness/{f=1} f&&/ I:/{print $2; exit}')
  gain=$(awk -v l="$lufs" 'BEGIN{printf "%.2f", -14 - l}')
  ffmpeg -hide_banner -loglevel error -y -i "$TMP/trim.wav" \
    -af "afade=t=out:st=$(awk -v d="$dur" 'BEGIN{printf "%.4f", d - 0.02}'):d=0.02,volume=${gain}dB,alimiter=limit=0.891:level=false" \
    "$TMP/clean.wav"
  to_ogg "$TMP/clean.wav" "$2" 0.6
  printf '%-20s %6.1f LUFS, gain %+5.1f dB, %.3f s -> %s\n' "$(basename "$1")" "$lufs" "$gain" "$dur" "$(basename "$2")"
}

clean "$RAW/sfx_jump_raw.wav"    "$OUT/sfx_jump.ogg"
clean "$RAW/sfx_hose_raw.wav"    "$OUT/sfx_hose.ogg"
clean "$RAW/sfx_rescue_raw2.wav" "$OUT/sfx_rescue.ogg"
clean "$RAW/sfx_burn_rawB.wav"   "$OUT/sfx_burn.ogg"
clean "$RAW/sfx_win_raw.wav"     "$OUT/sfx_win.ogg"

for r in sfx_burn_rawA sfx_rescue_raw1 sfx_siren_raw; do   # rejected takes: small mono copies (siren: playtest 3)
  ffmpeg -hide_banner -loglevel error -y -i "$RAW/$r.wav" -ac 1 "$TMP/rej.wav"
  to_ogg "$TMP/rej.wav" "$REJ/$r-rejected.ogg" 0.2
done
rm -rf "$TMP"
