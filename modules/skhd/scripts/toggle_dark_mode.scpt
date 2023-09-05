tell app "System Events"
  tell appearance preferences
    set darkMode to not dark mode
    set dark mode to darkMode
  end tell

  if darkMode then
    set pictureFilename to "dark.png"
  else
    set pictureFilename to "light.png"
  end if

  set picturePath to POSIX path of (path to home folder) & "/.config/skhd/resources/" & pictureFilename

  tell every desktop
    set picture to picturePath
  end tell
end tell
