tell app "System Events"
  tell appearance preferences
    set darkMode to not dark mode
    set dark mode to darkMode
  end tell

  if darkMode then
    set pictureFilename to "dark.png"
    do shell script "/Applications/kitty.app/Contents/MacOS/kitten themes --reload-in=all sonokai"
  else
    set pictureFilename to "light.png"
    do shell script "/Applications/kitty.app/Contents/MacOS/kitten themes --reload-in=all Everforest Light Hard"
  end if

  set picturePath to POSIX path of (path to home folder) & "/.config/skhd/resources/" & pictureFilename

  tell every desktop
    set picture to picturePath
  end tell

  if darkMode then
    set themeName to "sonokai"
  else
    set themeName to "Everforest Light Hard"
  end if

  do shell script "/Applications/kitty.app/Contents/MacOS/kitten themes --reload-in=all " & themeName
end tell
