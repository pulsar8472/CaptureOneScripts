(*
	Creates new directories inside of the Capture directory and sets the capture directory.

	When running the script you'll be prompted for a new directory name. The prompt
	will repeat allowing going back to FileMaker or a spreadsheet, enter an empty string
	to end the loop.

	New directories are created adjacent to the current capture directory, _unless_
	the capture directory is "Capture", in which case new folders are made inside.

	If the boolean in `addFavorites(_:_:)` is `true` then the capture directory will be
	set to the *first* directory name entered.

	Created by Emory Dunn

*)

set newDirs to getDirs()
set fullPaths to makeDirs(newDirs)
addFavorites(fullPaths, true)

on getDirs()
	-- present a modal asking for a name
	set newDirs to []
	set previousAnswer to "nil"

	try
		repeat while previousAnswer is not ""
			set theResponse to display dialog ¬
				"New Folder Name" default answer ¬
				"" buttons {"Cancel", "Next"} ¬
				default button ¬
				"Next" cancel button "Cancel"

			set responseText to text returned of theResponse

			if responseText is not "" then
				set newDirs to newDirs & responseText
			end if
			set previousAnswer to responseText
		end repeat
	end try
	return newDirs

end getDirs

on makeDirs(dirNames)
	tell front document of application "Capture One 11"
		set currentCaptureDir to captures
		tell application "Finder" to set captureName to name of folder currentCaptureDir

		set newDirs to []

		-- if the name is not Capture, we need to create our folder under the main Capture dir
		if captureName is not "Capture" then
			tell application "Finder"
				set d to currentCaptureDir as alias
				set currentCaptureDir to container of d as alias
			end tell

		end if

		repeat with newName in dirNames
			set newDir to POSIX path of currentCaptureDir & newName
			set newDirs to newDirs & newDir

			tell application "Finder"
				try
					log "Making new dir " & newDir
					make new folder at currentCaptureDir with properties {name:newName}
				end try

			end tell
			log newDir
		end repeat

	end tell
	return newDirs
end makeDirs

on addFavorites(dirPaths, setCapture)
	tell front document of application "Capture One 11"

		-- Add all paths to favorites
		repeat with dirPath in dirPaths
			set captureCollection to make collection with properties {kind:favorite, file:dirPath}
		end repeat

		if setCapture is true and (count of dirPaths) is greater than 0 then
			-- Set the first item as the capture folder
			set captures to first item in dirPaths
		end if
	end tell

end addFavorites