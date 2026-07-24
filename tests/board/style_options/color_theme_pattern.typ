// The `pattern` field on `color-theme(..)` (prompt 38 §3a, renamed/extended by
// prompt 40 §1): pins the pure `_square-fill` helper's mapping (fill kind by
// is-dark/pattern) and the pure `_pattern-warning` helper (in-document notice
// for not-yet-implemented patterns), since the rendered square is a plain
// `rect` that Typst cannot `query()` -- this is the ONLY machine-checkable
// form of the pattern -> fill mapping (see the module comment above
// `_square-fill` in src/board.typ). This complements, and does not replace,
// the render sheets `board/colors/pattern_stripes.typ` and
// `board/colors/pattern_marble_wood.typ`.
#import "/lib.typ": color-theme
#import "/src/board.typ": _square-fill, _pattern-warning

#let stand-in-light = rgb("#040506")
#let stand-in-dark = rgb("#010203")

// 1. dark square + "stripes" -> a tiling fill, not a plain color.
#assert.eq(str(type(_square-fill(true, stand-in-light, stand-in-dark, "stripes"))), "tiling",
  message: "a dark square with pattern: \"stripes\" must produce a tiling fill")

// 2. dark square + pattern: none -> the plain dark color, unchanged.
#assert.eq(_square-fill(true, stand-in-light, stand-in-dark, none), stand-in-dark,
  message: "a dark square with pattern: none must return the plain `dark` color unchanged")

// 3. light square + "stripes" -> the plain light color, unchanged --
// stripes never apply to light squares regardless of pattern.
#assert.eq(_square-fill(false, stand-in-light, stand-in-dark, "stripes"), stand-in-light,
  message: "a light square must stay a flat fill even when pattern: \"stripes\" is set")

// 4. `color-theme(..)` accepts `pattern: "stripes"` and just collects it,
// same as light/dark (the constructor does not resolve to a fill; that only
// happens inside `_square-fill` at render time).
#assert.eq(
  color-theme(light: stand-in-light, dark: stand-in-dark, pattern: "stripes"),
  (light: stand-in-light, dark: stand-in-dark, pattern: "stripes"),
  message: "color-theme(..) must accept and collect a valid `pattern` value",
)

// 5. "marble" and "wood" are no-ops for the dark-square fill -- same flat-color
// behavior as pattern: none, not a tiling.
#assert.eq(_square-fill(true, stand-in-light, stand-in-dark, "marble"), stand-in-dark,
  message: "a dark square with pattern: \"marble\" must return the plain `dark` color unchanged (no-op)")
#assert.eq(_square-fill(true, stand-in-light, stand-in-dark, "wood"), stand-in-dark,
  message: "a dark square with pattern: \"wood\" must return the plain `dark` color unchanged (no-op)")

// 6. `_pattern-warning` returns none for the implemented patterns (none/stripes).
#assert.eq(_pattern-warning(none), none,
  message: "_pattern-warning(none) must return none")
#assert.eq(_pattern-warning("stripes"), none,
  message: "_pattern-warning(\"stripes\") must return none")

// 7. `_pattern-warning` returns visible content for the not-yet-implemented
// patterns (marble/wood), so a warning notice is shown on the rendered board.
#assert(str(type(_pattern-warning("marble"))) == "content",
  message: "_pattern-warning(\"marble\") must return content, not none")
#assert(str(type(_pattern-warning("wood"))) == "content",
  message: "_pattern-warning(\"wood\") must return content, not none")

// 8. `color-theme(..)` accepts "marble" / "wood" and collects them unchanged,
// same as "stripes" -- the constructor does not reject not-yet-implemented
// pattern names, only truly unknown ones (see
// `board/malformed/color_theme_unknown_pattern.typ`).
#assert.eq(
  color-theme(light: stand-in-light, dark: stand-in-dark, pattern: "marble"),
  (light: stand-in-light, dark: stand-in-dark, pattern: "marble"),
  message: "color-theme(..) must accept and collect pattern: \"marble\"",
)
#assert.eq(
  color-theme(light: stand-in-light, dark: stand-in-dark, pattern: "wood"),
  (light: stand-in-light, dark: stand-in-dark, pattern: "wood"),
  message: "color-theme(..) must accept and collect pattern: \"wood\"",
)
