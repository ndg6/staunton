// Render-only sheet (no asserts): `color-theme(pattern: "marble")` and
// `color-theme(pattern: "wood")` at real board size, for the human eyeball
// pass. Both patterns now draw a transparent per-square SVG overlay on top of
// the theme's flat fill (the pattern -> overlay mapping itself is pinned
// machine-checkably by the asserting test
// `board/style_options/color_theme_pattern.typ`, via the pure
// `_material-asset` / `_material-orientation` helpers). This sheet is only
// for confirming the texture actually *looks* right composited over real
// theme colors. See tests/VISUAL_CHECKS.md.
#import "/lib.typ": board, color-theme
#import "/tests/board/_fixture.typ": test-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Marble / wood material patterns

`pattern: "marble"` over a deep-green/cream theme -- both squares should show
soft, fuzzy marble veining (dark squares green with light veins, light squares
quiet cream stone with faint grey veins), varying per square (not an obvious
repeating tile):
#board(test-fen, size: 6cm,
  color-theme: color-theme(light: rgb("#eeeed2"), dark: rgb("#3f6b4a"), pattern: "marble"))

`pattern: "wood"` over a walnut/maple theme -- dark squares should show
linear, slightly-bendy horizontal wood grain (both darker lines and lighter
streaks), while light (maple) squares stay a flat fill:
#board(test-fen, size: 6cm,
  color-theme: color-theme(light: rgb("#d9b98a"), dark: rgb("#6b4a2f"), pattern: "wood"))
