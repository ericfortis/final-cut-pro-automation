#!/bin/zsh

setopt nullglob 

# This shell script is a workaround for a bug in Compressor 4.10 when retiming with Machine Learning a batch.
# The workaround is scheduling a batch but one file at a time.
# Bug details: https://discussions.apple.com/thread/256096005

input_dir="$1"
output_dir="$2"
preset_file="$3"

if [ -z "$input_dir" ] || [ -z "$output_dir" ]; then
  echo "Usage: $0 <input_dir> <output_dir> <preset_file>"
  exit 1
fi

if [ ! -d "$input_dir" ]; then
  echo "Directory not found: $input_dir"
  exit 1
fi

if [ ! -f "$preset_file" ]; then
  echo "Preset not found: $preset_file"
  exit 1
fi

mkdir -p "$output_dir"

# Prevent system sleep
caffeinate -s &
caffeinate_pid=$!

start=$(date +%s)

for ext in mov mp4 mkv; do
  for f in "$input_dir"/*.$ext; do
    /Applications/Compressor.app/Contents/MacOS/Compressor \
     -batchname "MyBatch" \
     -settingpath "$preset_file" \
     -jobpath "$f" \
     -locationpath "$output_dir/$(basename "$f")" >/dev/null 2>&1
     
    printf "\rTranscoding $(basename "$f")"

    # Wait for TranscoderService to appear
    while ! pgrep TranscoderService >/dev/null; do
      sleep 0.5
    done

    # Wait for TranscoderService to finish
    while pgrep TranscoderService >/dev/null; do
      sleep 1
    done
  done
done

echo "\nElapsed: $(( ($(date +%s) - $start) /60 ))m"

kill $caffeinate_pid
