// Render-only sheet (no asserts): `color-theme(pattern: "marble")` and
// `color-theme(pattern: "wood")` at real board size, for the human eyeball
// pass. Both patterns draw a transparent per-square overlay on top of the
// theme's flat fill (the pattern -> overlay mapping itself is pinned
// machine-checkably by `board/style_options/color_theme_pattern.typ` and
// `board/style_options/pattern_light_variant.typ`, via the pure
// `_material-asset` / `_material-orientation` / `_material-variant` helpers).
// This sheet is only for confirming the texture actually *looks* right
// composited over real theme colors. See tests/VISUAL_CHECKS.md.
//
// The overlays are MONOCHROME by design -- they carry shading only, so the hue
// always comes from the theme. That is what makes them work over any
// `color-theme`; a tinted overlay bakes in a hue that fights every theme not
// of that hue.
#import "/lib.typ": board, color-theme
#import "/tests/board/_fixture.typ": test-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Marble / wood material patterns

`pattern: "marble"` over a deep-green/cream theme -- both squares should show
branching, multi-scale veining that fades in and out along its length (dark
squares green with light veins, light squares quiet cream stone with faint
grey veins). Veins must look irregular: no rectangular lattice, no uniform
speckle, and no obviously repeating tile (two artworks alternate per square):
#board(test-fen, size: 6cm,
  color-theme: color-theme(light: rgb("#eeeed2"), dark: rgb("#3f6b4a"), pattern: "marble"))

`pattern: "wood"` over a walnut/maple theme -- BOTH square colors are now
grained, so the board should read as *inlaid* timber (alternating dark and
light wood), not as texture applied to half the squares. Grain runs vertically
with a nested-arch "cathedral" cluster; light squares carry the same grain more
faintly:
#board(test-fen, size: 6cm,
  color-theme: color-theme(light: rgb("#d9b98a"), dark: rgb("#6b4a2f"), pattern: "wood"))

`pattern-light: false` -- the opt-out, and the pre-1.0 look: dark squares
grained, light squares flat. Compare against the board above:
#board(test-fen, size: 6cm, pattern-light: false,
  color-theme: color-theme(light: rgb("#d9b98a"), dark: rgb("#6b4a2f"), pattern: "wood"))
