set zoom_name to "zoom.us"
set default_volume to 100
set cache_dir to POSIX path of (path to home folder) & ".cache/toggle_input_mute"
set cache_file to "volume.cache"

set input_volume to input volume of (get volume settings)
if input_volume = 0 then
  set input_volume to readVolumeCache(cache_dir, cache_file, default_volume)

  if application zoom_name is running then
    tell application "System Events"
      tell process zoom_name
        try
          click menu item "Unmute Audio" of menu 1 of menu bar item "Meeting" of menu bar 1
        end try
      end tell
    end tell
  end if
else
  writeVolumeCache(input_volume, cache_dir, cache_file)

  set input_volume to 0
  if application zoom_name is running then
    tell application "System Events"
      tell process zoom_name
        try
          click menu item "Mute Audio" of menu 1 of menu bar item "Meeting" of menu bar 1
        end try
      end tell
    end tell
  end if
end if
set volume input volume input_volume

on writeVolumeCache(value, dir, filename)
  do shell script ("mkdir -p '" & dir & "'")
  writeTextToFile(value as string, dir & "/" & filename, true)
end writeVolumeCache

on readVolumeCache(dir, filename, default)
  try
    readFile(dir & "/" & filename) as number
  on error
    default
  end try
end readVolumeCache

# Read/write functions from
# https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/ReadandWriteFiles.html
on writeTextToFile(theText, theFile, overwriteExistingContent)
  try
    set theFile to (POSIX file theFile)
    set theOpenedFile to open for access file theFile with write permission
    if overwriteExistingContent is true then set eof of theOpenedFile to 0
    write theText to theOpenedFile starting at eof
    close access theOpenedFile
    -- Writing was successful
    return true
  on error
    try
      close access file theFile
    end try
    -- Writing failed
    return false
  end try
end writeTextToFile

on readFile(theFile)
  set theFile to (POSIX file theFile)
  return read file theFile
end readFile
