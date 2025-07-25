#!/bin/zsh

setopt nullglob 

# This shell script is a workaround for a bug in Compressor 4.10 when retiming with Machine Learning a batch.
# The workaround is scheduling a batch but one file at a time.
# Bug details: https://discussions.apple.com/thread/256096005

INDIR="$1"
PRESET="$2"
OUTDIR="$HOME/Movies/out/$(basename "$INDIR")"

if [ -z "$INDIR" ] || [ ! -d "$INDIR" ]; then
  echo "Usage: $0 <input_dir> <preset_path>"
  echo "Example: $0 ~/Movies/foo/ ~/mypreset.compressorsetting"
  exit 1
fi

if [ ! -f "$PRESET" ]; then
  echo "Preset not found"
  exit 1
fi

mkdir -p "$OUTDIR"

# Prevent system sleep
caffeinate -s &
CAFFEINATE_PID=$!

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

    sleep 2
  done
done

echo "\n"
date

kill $CAFFEINATE_PID
