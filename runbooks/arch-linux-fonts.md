# Setup Fonts on Arch Linux

```sh
sudo pacman -S ttf-liberation noto-fonts ttf-emojione
sudo ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
sudo ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
sudo ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
sudo ln -s /etc/fonts/conf.avail/30-ttf-liberation-* /etc/fonts/conf.d
```

Create the file `/etc/fonts/local.conf`.

```xml
<?xml version="1.0"?>
  <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match>
      <edit mode="prepend" name="family"><string>Noto Sans</string></edit>
  </match>
  <match target="pattern">
      <test qual="any" name="family"><string>serif</string></test>
      <edit name="family" mode="assign" binding="same"><string>Noto Serif</string></edit>
  </match>
  <match target="pattern">
      <test qual="any" name="family"><string>sans-serif</string></test>
      <edit name="family" mode="assign" binding="same"><string>Noto Sans</string></edit>
  </match>
  <match target="pattern">
      <test qual="any" name="family"><string>monospace</string></test>
      <edit name="family" mode="assign" binding="same"><string>Hack</string></edit>
  </match>
</fontconfig>
```
