// Render-only sheet (no asserts): `color-theme(pattern: "marble")` and
// `color-theme(pattern: "wood")` at real board size, for the human eyeball
// pass. Both patterns are not-yet-implemented no-ops for the dark-square fill
// (same flat color as `pattern: none`) -- what this sheet exists to confirm is
// the in-document warning notice produced by `_pattern-warning` (prompt 40
// §1), pinned machine-checkably (non-none content, plain flat fill) by the
// asserting test `board/style_options/color_theme_pattern.typ`. Frank should
// check that the warning notice is visible, legible, names the correct
// pattern, and does not obscure the board. See tests/VISUAL_CHECKS.md.
#import "/lib.typ": board, color-theme
#import "/tests/board/_fixture.typ": test-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Marble / wood patterns (not yet implemented)

`pattern: "marble"` -- flat dark-square fill, plus a warning notice:
#board(test-fen, size: 5cm,
  color-theme: color-theme(light: rgb("#eeeed2"), dark: rgb("#769656"), pattern: "marble"))

`pattern: "wood"` -- flat dark-square fill, plus a warning notice:
#board(test-fen, size: 5cm,
  color-theme: color-theme(light: rgb("#eeeed2"), dark: rgb("#769656"), pattern: "wood"))
