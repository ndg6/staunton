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
#import "/src/board.typ": _square-fill, _material-asset, _material-orientation

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

// 4. "marble" and "wood" still return the plain flat color from
// `_square-fill` -- the material texture is now a SEPARATE image overlay
// (via `_material-asset` / `_material-orientation`), not part of the base
// square fill.
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

// 6. `_material-asset` maps (pattern, is-dark) -> asset path / none, exactly.
#assert.eq(_material-asset("marble", true), "assets/patterns/marble_dark.svg",
  message: "_material-asset(\"marble\", true) must point at the dark-square marble SVG")
#assert.eq(_material-asset("marble", false), "assets/patterns/marble_light.svg",
  message: "_material-asset(\"marble\", false) must point at the light-square marble SVG")
#assert.eq(_material-asset("wood", true), "assets/patterns/wood.svg",
  message: "_material-asset(\"wood\", true) must point at the wood-grain SVG")
#assert.eq(_material-asset("wood", false), none,
  message: "_material-asset(\"wood\", false) must be none -- wood has no light-square overlay")
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
