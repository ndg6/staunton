// "border" mode band themes: pin the theme -> (band-fill, band-label) color
// mapping exposed by `_band-colors`, so a swap of the two arms of a theme
// (or a theme silently collapsing both slots to the same color) fails the
// suite instead of needing an eyeball. This complements, and does not
// replace, the render sheet `border_themes.typ`.
#import "/src/board.typ": _band-colors
#import "/src/style.typ": border-brown, border-creme, border-saddle, border-dark, border-dark-label, border-marble

// The constants themselves, pinned as documented (a retune should be a
// deliberate, visible diff here).
#assert(border-brown == rgb("#4a3319"), message: "border-brown drifted from its documented hex")
#assert(border-creme == rgb("#f3ecd8"), message: "border-creme drifted from its documented hex")
#assert(border-saddle == rgb("#6b4423"), message: "border-saddle drifted from its documented hex")
#assert(border-dark == rgb("#2b2b2b"), message: "border-dark drifted from its documented hex")
#assert(border-dark-label == rgb("#e8e8e8"), message: "border-dark-label drifted from its documented hex")
#assert(border-marble == rgb("#2d4a3e"), message: "border-marble drifted from its documented hex")

// The two material themes must not collapse to one look.
#assert(border-marble != border-brown, message: "border-marble and border-brown must be distinct colors -- \"wood\" and \"marble\" must not look identical")

// "brown" and "creme" must NOT be a mirrored pair -- they use two different
// browns (the exact trap the design doc warns against).
#assert(border-brown != border-saddle, message: "\"brown\" and \"creme\" must not share a brown; they are not a mirrored pair")

// Distinctive stand-ins for the board's own light/dark square colors, so a
// wrong wiring for "square" cannot coincidentally match a border-* constant.
#let stand-in-light = rgb("#040506")
#let stand-in-dark = rgb("#010203")

// Full theme -> (band-fill, band-label) mapping.
#assert(_band-colors("brown", stand-in-light, stand-in-dark) == (border-brown, border-creme),
  message: "\"brown\" must map to (border-brown, border-creme)")
#assert(_band-colors("creme", stand-in-light, stand-in-dark) == (border-creme, border-saddle),
  message: "\"creme\" must map to (border-creme, border-saddle)")
#assert(_band-colors("dark", stand-in-light, stand-in-dark) == (border-dark, border-dark-label),
  message: "\"dark\" must map to (border-dark, border-dark-label)")
#assert(_band-colors("light", stand-in-light, stand-in-dark) == (border-dark-label, border-dark),
  message: "\"light\" must be the exact mirror of \"dark\": (border-dark-label, border-dark)")
#assert(_band-colors("square", stand-in-light, stand-in-dark) == (stand-in-dark, stand-in-light),
  message: "\"square\" must pass through the board's own (dark, light) square colors, not any border-* constant")
#assert(_band-colors("wood", stand-in-light, stand-in-dark) == (border-brown, border-creme),
  message: "\"wood\" must map to (border-brown, border-creme)")
#assert(_band-colors("marble", stand-in-light, stand-in-dark) == (border-marble, border-creme),
  message: "\"marble\" must map to (border-marble, border-creme)")

// "wood" and "brown" deliberately SHARE the same (fill, label) color pair --
// wood reuses the brown backdrop as its material's base color, with the wood
// grain texture composited on top (see `_band-material`). This is intentional,
// not a copy-paste bug: flag it explicitly so a future editor does not "fix"
// it into a distinct pair.
#assert(_band-colors("wood", stand-in-light, stand-in-dark) == _band-colors("brown", stand-in-light, stand-in-dark),
  message: "\"wood\" and \"brown\" are intentionally the same color pair (wood reuses the brown backdrop as its material base) -- this must NOT be a copy-paste bug fixed away")
