// EXPECT: color theme `light` must be a color; got "red"
// board() - the RAW-DICT bypass, same non-color-value guard as
// color_theme_non_color_value.typ but through a hand-rolled `color-theme: (..)`
// dict (NOT the constructor), so the resolve-time validation is what catches it.
// Do not "simplify" this to a `color-theme(..)` call.
#import "/lib.typ": board
#board((:), color-theme: (light: "red"))
