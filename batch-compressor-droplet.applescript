-- Instead of this AppleScript
--   use batch-compressor-workaround.sh

-- That’s because AppleScript uses a Droplet, and for automating it we need
-- to bring it to the foreground on each file, so that makes it brittle if you are
-- using the computer while that script is running. In contrast, the .sh automates
-- Compressor (not a Droplet), so there’s no GUI interfering.

-- This AppleScript is a workaround for a bug when retiming with Machine Learning a batch.
--   Bug details: https://discussions.apple.com/thread/256096005

-- This script prompts you to:
--   Pick the video files you want to process, then to
--   Pick the Compressor droplet you want to apply

-- It will automatically start processing one file at a time, which is the actual bug workaround.
-- It ensures there's no transcoding in progress before processing the next file. In other words, 
--  it waits until there's no "TranscoderService" process at all, regardless of what triggered it.
-- So if you are transcoding other things, this script will wait for them to finish.

set videoUTIs to {"public.mpeg-4", "com.apple.quicktime-movie", "public.avi", "public.mpeg", "public.3gpp", "public.3gpp2", "org.matroska.mkv", "org.webmproject.webm"}
set selectedFiles to choose file with prompt "Select video files" of type videoUTIs with multiple selections allowed

set dropletApp to choose file with prompt "Select your Compressor Droplet (.app)" of type {"app"}
set dropletPath to POSIX path of dropletApp


-- Wait until no transcoder job is active
repeat
	delay 1
	set transcoding to (do shell script "pgrep TranscoderService || true")
	if transcoding is "" then exit repeat
end repeat


repeat with f in selectedFiles
	try
		set fPath to POSIX path of f
		log "Processing: " & fPath
		do shell script "open -a " & quoted form of dropletPath & " -- " & quoted form of fPath
		
		-- wait until the Droplet app shows up in System Events
		repeat 20 times -- wait up to ~10 seconds
			tell application "System Events"
				if (exists application process "Droplet") then exit repeat
			end tell
			delay 0.5
		end repeat
		tell application "System Events"
			tell application process "Droplet"
				set frontmost to true
				
				repeat 10 times
					delay 0.2
					if exists button "Start Batch" of window 1 then exit repeat
				end repeat
				
				try
					delay 0.2
					click button "Start Batch" of window 1
				end try
			end tell
		end tell
		
		-- Wait until transcoding *has finished*
		repeat
			delay 2
			set transcoding to (do shell script "pgrep TranscoderService || true")
			if transcoding is "" then exit repeat
		end repeat
		
		delay 1
	on error errMsg
		log "Error with: " & fPath & " - " & errMsg
	end try
end repeat
