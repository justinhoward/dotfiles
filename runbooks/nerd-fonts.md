Nerd Fonts
===================

To install Hack and the nerd font symbols, we'll want some font variations:

- Hack standalone font (homebrew `font-hack`)
- Victor Mono font (homebrew `font-victor-mono`)
- Nerd font [symbols font](https://github.com/ryanoasis/nerd-fonts/tree/master/src/glyphs).
  Download both the 1000em and 2048em TTF variations
  (or ttf-nerd-fonts-symbols on arch).
- Hack Nerd patched font (homebrew `font-hack-nerd-font`)

```sh
# OS X
brew install font-hack font-victor-mono font-hack-nerd-font
curl -LO https://github.com/ryanoasis/nerd-fonts/raw/master/src/glyphs/Symbols-1000-em%20Nerd%20Font%20Complete.ttf
curl -L0 https://github.com/ryanoasis/nerd-fonts/raw/master/src/glyphs/Symbols-2048-em%20Nerd%20Font%20Complete.ttf
open Symbols-*.ttf
```
