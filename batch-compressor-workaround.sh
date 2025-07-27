#!/bin/zsh

setopt nullglob 

# This shell script is a workaround for a bug in Compressor 4.10 when retiming with Machine Learning a batch.
# The workaround is scheduling a batch but one file at a time.
# Bug details: https://discussions.apple.com/thread/256096005

INDIR="$1"
OUTDIR="$2"
PRESET="$3"

if [ -z "$INDIR" ] || [ -z "$OUTDIR" ]; then
  echo "Usage: $0 <input_dir> <out_dir> <preset_path>"
  exit 1
fi

if [ ! -d "$INDIR" ]; then
  echo "Directory not found: $INDIR"
  exit 1
fi

if [ ! -f "$PRESET" ]; then
  echo "Preset not found: $PRESET"
  exit 1
fi

mkdir -p "$OUTDIR"

# Prevent system sleep
caffeinate -s &
CAFFEINATE_PID=$!

start=$(date +%s)
for ext in mov mp4 mkv; do
  for f in "$INDIR"/*.$ext; do
    /Applications/Compressor.app/Contents/MacOS/Compressor \
     -batchname "MyBatch" \
     -settingpath "$PRESET" \
     -jobpath "$f" \
     -locationpath "$OUTDIR/$(basename "$f")" >/dev/null 2>&1

    # Wait for TranscoderService to appear
    while ! pgrep TranscoderService >/dev/null; do
      sleep 0.5
    done

    printf "\rTranscoding $(basename "$f")"
    while pgrep TranscoderService >/dev/null; do
      sleep 1
    done
  done
done

echo "\nElapsed: $(( ($(date +%s) - $start) /60 ))m"

kill $CAFFEINATE_PID
