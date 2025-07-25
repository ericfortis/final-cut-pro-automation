-- This AppleScript wraps each Clip in its own Compound Clip by automating these steps:
--   a. Command + RightArrow (Selects Next Clip)
--   b. Alt + G (Compound Clip)
--   c. Return (Confirm Compound Clip)
--   d. Stops when "Edit > Select > Select Next" is disabled, which means there are no more clips

-- Optionally, for speed, you can check:
--   Settings > Accessibility > Reduce Motion

-- Before running this program:
--   1. Duplicate your Final Cut project (just in case) 
--   2. Put the playhead before the first clip you want to compound

-- Running:
--   1. Open Script Editor.app
--   2. Paste this program there
--   3. Click "Run the Script" (Play button)
--   4. Let it finish (don't try to stop it)


set activeProjectName to ""

tell application "System Events"
	tell process "Final Cut Pro"
		set frontmost to true
		delay 0.2
		
		tell menu bar 1
			tell menu bar item "File"
				tell menu "File"
					repeat with mi in menu items
						set miName to name of mi
						if miName starts with "Close �" then
							set AppleScript's text item delimiters to {"�", "�"}
							set activeProjectName to text item 2 of miName
							set AppleScript's text item delimiters to ""
							exit repeat
						end if
					end repeat
				end tell
			end tell
		end tell
	end tell
end tell


tell application "Script Editor" to activate
display dialog "Enter clip name prefix:" default answer activeProjectName
set prefix to text returned of the result


set counter to 1
tell application "System Events"
	tell process "Final Cut Pro"
		set frontmost to true
		delay 0.2
		
		keystroke "a" -- Pick Select Tool
		
		repeat while enabled of menu item "Select Next" of menu "Select" of menu item "Select" of menu "Edit" of menu bar 1
			keystroke "g" using option down
			
			set paddedCounter to text -3 thru -1 of ("000" & counter)
			set clipName to prefix & "_" & paddedCounter
			keystroke clipName
			
			keystroke return
			key code 124 using command down
			
			set counter to counter + 1
		end repeat
	end tell
end tell
