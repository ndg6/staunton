// The `pattern` field on `color-theme(..)` (prompt 38 §3a, renamed/extended by
// prompt 40 §1, materials implemented later): pins the pure `_square-fill`
// helper's mapping (fill kind by is-dark/pattern), the pure `_material-asset`
// helper (which SVG overlay path, if any, a given pattern/is-dark combination
// uses), and the pure `_material-orientation` helper (deterministic per-square
// rotation/mirror policy), since the rendered square+overlay is a plain
// `rect`/`image` that Typst cannot `query()` -- this is the ONLY
// machine-checkable form of the pattern -> fill/overlay mapping (see the
// module comments above `_square-fill` / `_material-asset` /
// `_material-orientation` in src/board.typ). This complements, and does not
// replace, the render sheets `board/colors/pattern_stripes.typ` and
// `board/colors/pattern_marble_wood.typ`.
#import "/lib.typ": color-theme
#import "/src/board.typ": _square-fill, _material-asset, _material-orientation, _stripes-overlay

#let stand-in-light = rgb("#040506")
#let stand-in-dark = rgb("#010203")

// 1. `_square-fill` is now ALWAYS the flat theme color -- every pattern
// (stripes / marble / wood) is drawn as a separate per-square overlay on top,
// so the base fill never depends on `pattern`. dark -> dark, regardless of
// pattern; light -> light.
#assert.eq(_square-fill(true, stand-in-light, stand-in-dark, "stripes"), stand-in-dark,
  message: "a dark square's base fill must be the plain `dark` color (stripes are a separate overlay now, not a tiling fill)")
#assert.eq(_square-fill(false, stand-in-light, stand-in-dark, "stripes"), stand-in-light,
  message: "a light square must stay a flat `light` fill (stripes never apply to light squares)")

// 1b. `_stripes-overlay(sq)` is the dark-square diagonal-stripe overlay --
// content (a box of continuous diagonal lines), not none. This replaced the
// old `tiling()` fill (which dashed the diagonals at cell boundaries).
#assert(str(type(_stripes-overlay(4pt))) == "content",
  message: "_stripes-overlay(sq) must return drawable content (the diagonal-line overlay)")

// 2. dark square + pattern: none -> the plain dark color, unchanged.
#assert.eq(_square-fill(true, stand-in-light, stand-in-dark, none), stand-in-dark,
  message: "a dark square with pattern: none must return the plain `dark` color unchanged")

// 4. "marble" and "wood" also return the plain flat color from `_square-fill`
// -- the material texture is a SEPARATE image overlay (via `_material-asset` /
// `_material-orientation`), not part of the base square fill.
#assert.eq(_square-fill(true, stand-in-light, stand-in-dark, "marble"), stand-in-dark,
  message: "a dark square with pattern: \"marble\" must still return the plain `dark` color from `_square-fill` (the texture is a separate overlay)")
#assert.eq(_square-fill(true, stand-in-light, stand-in-dark, "wood"), stand-in-dark,
  message: "a dark square with pattern: \"wood\" must still return the plain `dark` color from `_square-fill` (the texture is a separate overlay)")
#assert.eq(_square-fill(false, stand-in-light, stand-in-dark, "marble"), stand-in-light,
  message: "a light square with pattern: \"marble\" must still return the plain `light` color from `_square-fill` (the texture is a separate overlay)")

// 5. `color-theme(..)` accepts and collects `pattern: "stripes"/"marble"/"wood"`,
// same as light/dark (the constructor does not resolve to a fill; that only
// happens inside `_square-fill` / `_material-asset` at render time).
#assert.eq(
  color-theme(light: stand-in-light, dark: stand-in-dark, pattern: "stripes"),
  (light: stand-in-light, dark: stand-in-dark, pattern: "stripes"),
  message: "color-theme(..) must accept and collect a valid `pattern` value",
)
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

// 6. `_material-asset` maps (pattern, is-dark, variant) -> asset path / none.
// Marble is a RASTER (its figure is stochastic and multi-scale, which vector
// authoring cannot fake); wood stays vector (its figure is a few describable
// curves). Both now cover BOTH square colors -- wood's light-square overlay is
// new in 1.0.0, gated by the `pattern-light` style field.
#assert.eq(_material-asset("marble", true), "assets/patterns/marble_dark1.png",
  message: "_material-asset(\"marble\", true) must default to marble variant 1 (dark)")
#assert.eq(_material-asset("marble", false), "assets/patterns/marble_light1.png",
  message: "_material-asset(\"marble\", false) must default to marble variant 1 (light)")
#assert.eq(_material-asset("marble", true, variant: 2), "assets/patterns/marble_dark2.png",
  message: "_material-asset(\"marble\", true, variant: 2) must select the second dark variant")
#assert.eq(_material-asset("marble", false, variant: 2), "assets/patterns/marble_light2.png",
  message: "_material-asset(\"marble\", false, variant: 2) must select the second light variant")
#assert.eq(_material-asset("wood", true), "assets/patterns/wood.svg",
  message: "_material-asset(\"wood\", true) must point at the wood-grain SVG")
#assert.eq(_material-asset("wood", false), "assets/patterns/wood_light.svg",
  message: "_material-asset(\"wood\", false) must point at the light-square wood SVG -- " +
    "wood patterns BOTH square colors since 1.0.0; returning `none` here is the pre-1.0 behaviour")
// Wood ignores `variant`: it ships one artwork per square color. A real board is
// separately cut squares, so per-square grain variation is expected anyway, and
// its figure is far less distinctive than a vein network.
#assert.eq(_material-asset("wood", true, variant: 2), "assets/patterns/wood.svg",
  message: "wood has no variants -- `variant` must not change its asset")
#assert.eq(_material-asset("stripes", true), none,
  message: "_material-asset(\"stripes\", true) must be none -- stripes is drawn in `_square-fill`, not as an overlay")
#assert.eq(_material-asset("stripes", false), none,
  message: "_material-asset(\"stripes\", false) must be none")
#assert.eq(_material-asset(none, true), none,
  message: "_material-asset(none, true) must be none")
#assert.eq(_material-asset(none, false), none,
  message: "_material-asset(none, false) must be none")

// 7. `_material-orientation` pins concrete (rot, mirror) values for specific
// cells -- this guards the actual deterministic per-square hash mapping against
// regressions (a tautological self-equality check would pass no matter how the
// mapping were rewritten). Values follow from the documented hash
// h = (row*73 + col*179 + row*col*13 + 7) mod 1009.
#assert.eq(_material-orientation("marble", 3, 5), (rot: 270deg, mirror: false),
  message: "_material-orientation(\"marble\", 3, 5) mapping changed unexpectedly")
#assert.eq(_material-orientation("wood", 2, 6), (rot: 0deg, mirror: true),
  message: "_material-orientation(\"wood\", 2, 6) mapping changed unexpectedly")

// 8. Patterns other than "marble"/"wood" always resolve to the identity
// orientation (no rotation, no mirror) -- there is no overlay to orient.
#assert.eq(_material-orientation("stripes", 4, 4), (rot: 0deg, mirror: false),
  message: "_material-orientation(\"stripes\", ..) must be the identity orientation")
#assert.eq(_material-orientation(none, 0, 0), (rot: 0deg, mirror: false),
  message: "_material-orientation(none, ..) must be the identity orientation")

// 9. Over a full 8x8 grid: wood must stay axis-preserving (grain never turns
// vertical -- rot is only ever 0deg or 180deg), while marble is genuinely
// 8-way (some cell rotates by 90deg or 270deg, and both mirror values occur).
#let wood-rots = ()
#let wood-mirrors = ()
#let marble-rots = ()
#let marble-mirrors = ()
#for row in range(8) {
  for col in range(8) {
    let wo = _material-orientation("wood", row, col)
    assert(wo.rot == 0deg or wo.rot == 180deg,
      message: "wood orientation at row " + str(row) + ", col " + str(col) + " must be 0deg or 180deg (axis-preserving), got " + repr(wo.rot))
    wood-rots.push(wo.rot)
    wood-mirrors.push(wo.mirror)

    let mo = _material-orientation("marble", row, col)
    marble-rots.push(mo.rot)
    marble-mirrors.push(mo.mirror)
  }
}

#assert(wood-mirrors.contains(true) and wood-mirrors.contains(false),
  message: "wood mirroring must vary across the board (both true and false must occur)")
#assert(marble-rots.contains(90deg) or marble-rots.contains(270deg),
  message: "marble rotation must be genuinely 8-way somewhere on the board (a 90deg or 270deg rotation must occur, beyond wood's 0/180deg)")
#assert(marble-mirrors.contains(true) and marble-mirrors.contains(false),
  message: "marble mirroring must vary across the board (both true and false must occur)")
