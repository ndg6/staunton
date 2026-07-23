// The `pattern` field on `color-theme(..)` (prompt 38 §3a): pins the pure
// `_square-fill` helper's mapping (fill kind by is-dark/pattern), since the
// rendered square is a plain `rect` that Typst cannot `query()` -- this is the
// ONLY machine-checkable form of the pattern -> fill mapping (see the module
// comment above `_square-fill` in src/board.typ). This complements, and does
// not replace, the render sheet `board/colors/pattern_diagonal_stripes.typ`.
#import "/lib.typ": color-theme
#import "/src/board.typ": _square-fill

#let stand-in-light = rgb("#040506")
#let stand-in-dark = rgb("#010203")

// 1. dark square + "diagonal-stripes" -> a tiling fill, not a plain color.
#assert.eq(str(type(_square-fill(true, stand-in-light, stand-in-dark, "diagonal-stripes"))), "tiling",
  message: "a dark square with pattern: \"diagonal-stripes\" must produce a tiling fill")

// 2. dark square + pattern: none -> the plain dark color, unchanged.
#assert.eq(_square-fill(true, stand-in-light, stand-in-dark, none), stand-in-dark,
  message: "a dark square with pattern: none must return the plain `dark` color unchanged")

// 3. light square + "diagonal-stripes" -> the plain light color, unchanged --
// stripes never apply to light squares regardless of pattern.
#assert.eq(_square-fill(false, stand-in-light, stand-in-dark, "diagonal-stripes"), stand-in-light,
  message: "a light square must stay a flat fill even when pattern: \"diagonal-stripes\" is set")

// 4. `color-theme(..)` accepts `pattern: "diagonal-stripes"` and just collects it,
// same as light/dark (the constructor does not resolve to a fill; that only
// happens inside `_square-fill` at render time).
#assert.eq(
  color-theme(light: stand-in-light, dark: stand-in-dark, pattern: "diagonal-stripes"),
  (light: stand-in-light, dark: stand-in-dark, pattern: "diagonal-stripes"),
  message: "color-theme(..) must accept and collect a valid `pattern` value",
)
