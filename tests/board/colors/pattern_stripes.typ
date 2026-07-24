// Render-only sheet (no asserts): `color-theme(pattern: "stripes")`
// at real board size, for the human eyeball pass. The fill mapping itself is
// pinned by the asserting test `board/style_options/color_theme_pattern.typ`
// (the pure `_square-fill` helper) -- this sheet exists only so Frank can
// confirm the stripes actually look like diagonal stripes, and that light
// squares stay flat. See tests/VISUAL_CHECKS.md.
#import "/lib.typ": board, color-theme
#import "/tests/board/_fixture.typ": test-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Stripe pattern

#board(test-fen, size: 5cm,
  color-theme: color-theme(light: rgb("#eeeed2"), dark: rgb("#769656"), pattern: "stripes"))
