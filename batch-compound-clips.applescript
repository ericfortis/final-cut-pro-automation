-- This AppleScript wraps each Clip on its own Compound Clip.

-- The automation does the following:
--   a. Command + RightArrow (Selects Next Clip)
--   b. Alt + G (Compound Clip shortcut)
--   c. Return (Confirm Compound Modal)
--   d. Stop when "Edit > Select > Select Next" is disabled, which means there are no more clips

-- Before running this program:
--   1. Duplicate your Final Cut project (just in case) 
--   2. Put the playhead before the first clip you want to compound

-- Running:
--   1. Open Script Editor.app
--   2. Paste this program there
--   3. Click Run Script (Play button)
--   4. Let if finish (don’t try to stop it)

tell application "System Events"
	tell process "Final Cut Pro"
		set frontmost to true
		
		repeat while enabled of menu item "Select Next" of ¬
			menu "Select" of menu item "Select" of ¬
			menu "Edit" of menu bar 1
			
			keystroke "g" using {option down}
			keystroke return
			keystroke (ASCII character 29) using {command down}
		end repeat
	end tell
end tell
