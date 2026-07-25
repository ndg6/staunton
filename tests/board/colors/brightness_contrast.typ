// Render-only sheet (no asserts): `color-theme(.., brightness: .., contrast: ..)`
// at real board size, for the human eyeball pass. The lightness math itself is
// pinned by the asserting test `board/style_options/color_theme_brightness_contrast.typ`
// (the pure `_adjust-color-pair` helper) -- this sheet exists only so Frank can
// confirm brightness/contrast actually look right, and that the 5%-separation
// floor keeps squares distinguishable even at an extreme setting.
// See tests/VISUAL_CHECKS.md.
#import "/lib.typ": board, color-theme
#import "/tests/board/_fixture.typ": test-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Brightness / contrast adjustment

Baseline (no adjustment):
#board(test-fen, size: 4cm,
  color-theme: color-theme(light: rgb("#f0d9b5"), dark: rgb("#b58863")))

`brightness: 30%` (both squares lighter):
#board(test-fen, size: 4cm,
  color-theme: color-theme(light: rgb("#f0d9b5"), dark: rgb("#b58863"), brightness: 30%))

`brightness: -30%` (both squares darker):
#board(test-fen, size: 4cm,
  color-theme: color-theme(light: rgb("#f0d9b5"), dark: rgb("#b58863"), brightness: -30%))

`contrast: 50%` (gap spread wider):
#board(test-fen, size: 4cm,
  color-theme: color-theme(light: rgb("#f0d9b5"), dark: rgb("#b58863"), contrast: 50%))

`contrast: -100%` (deliberately at the 5%-separation floor -- squares should
stay just barely distinguishable, not collapse to one flat color):
#board(test-fen, size: 4cm,
  color-theme: color-theme(light: rgb("#f0d9b5"), dark: rgb("#b58863"), contrast: -100%))
