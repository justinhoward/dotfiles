local w = require 'wezterm'
local config = {}

config.font = w.font 'Victor Mono Medium'
config.font_size = 14

function swap_cyan_blue(colors)
  blue, cyan = colors[5], colors[7]
  colors[5], colors[7] = cyan, blue
  return colors
end

local sonokai_custom = w.color.get_builtin_schemes()['Sonokai (Gogh)']
sonokai_custom['ansi'] = swap_cyan_blue(sonokai_custom['ansi'])
sonokai_custom['brights'] = swap_cyan_blue(sonokai_custom['brights'])
config.color_scheme = 'My Sonokai'
config.color_schemes = {
  ['My Sonokai'] = sonokai_custom
}

return config
