module XMonadConfig
(
	Colors(..),
	colors
) where

data Colors = Colors
	{
		normal :: String,
		active :: String,
		inactive :: String,
		urgent :: String,
		highlight :: String,
		background :: String
	}

colors = Colors { normal = "#CCCCCC", active = "#45C0F5", inactive = "#CEFFAC", urgent = "#FF0000", highlight = "#FFFFCC", background = "#202020" }