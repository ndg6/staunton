// "border" mode band THEMES: pin the theme -> texture-asset mapping exposed
// by `_band-material`, since the rendered band is a plain `rect`/`image`
// stack that Typst cannot `query()` (same precedent as `_material-asset` /
// `_square-fill` in `board/style_options/color_theme_pattern.typ`). This
// complements, and does not replace, the render sheet `border_themes.typ`.
// Companion to `border_theme_colors.typ`, which covers the `_band-colors`
// (fill/label) side of the same two themes.
//
// `_band-material` deliberately does NOT delegate to `_material-asset`: the
// band is drawn as a SINGLE image spanning the whole band rect, not a tiled
// grid of squares, so it needs its own band-scale assets
// (`wood_band.svg`/`marble_band.svg`) authored at a different noise
// frequency than the square assets. So the two functions must now return
// DIFFERENT paths for the same pattern -- pin that divergence directly, so a
// future "simplification" that restores the delegation fails loudly here.
#import "/src/board.typ": _band-material, _material-asset

// The concrete band-scale paths, pinned as documented.
#assert.eq(_band-material("wood"), "assets/patterns/wood_band.svg",
  message: "_band-material(\"wood\") must point at the band-scale wood-grain SVG")
#assert.eq(_band-material("marble"), "assets/patterns/marble_band.svg",
  message: "_band-material(\"marble\") must point at the band-scale marble SVG")

// Every other border-theme (the five pre-existing flat ones) must have no
// band texture -- a stray overlay on a "flat" theme would be a silent visual
// regression, since it never fails the render.
#for t in ("square", "brown", "creme", "dark", "light") {
  assert.eq(_band-material(t), none,
    message: "_band-material(\"" + t + "\") must be none -- only \"wood\"/\"marble\" have a band texture")
}

// The band and square assets must NOT agree: the band uses its own
// band-scale asset by design (the old single-sourced delegation degraded
// the texture at band scale -- wood into blobs, marble into a near-flat
// wash). If someone "restores" `_band-material` to call `_material-asset`
// directly, these must fail.
#assert.ne(_band-material("wood"), _material-asset("wood", true),
  message: "_band-material(\"wood\") must NOT agree with _material-asset(\"wood\", true) -- " +
    "the band deliberately uses its own band-scale asset (wood_band.svg), not the square one; " +
    "restoring the old delegation reintroduces the degraded-texture regression")
#assert.ne(_band-material("marble"), _material-asset("marble", true),
  message: "_band-material(\"marble\") must NOT agree with _material-asset(\"marble\", true) -- " +
    "the band deliberately uses its own band-scale asset (marble_band.svg), not the square one; " +
    "restoring the old delegation reintroduces the degraded-texture regression")

// Cheap structural check that the band-scale assets actually exist and are
// readable SVGs with a `baseFrequency` (they are turbulence noise filters
// scaled 10x from their square siblings) -- a wrong path in `_band-material`
// would otherwise only surface as a compile error inside a render sheet,
// and a silently missing texture is this repo's documented failure mode.
#let _wood-band-svg = read("/src/" + _band-material("wood"))
#let _marble-band-svg = read("/src/" + _band-material("marble"))
#assert(_wood-band-svg.len() > 0,
  message: "wood_band.svg must not be empty")
#assert(_wood-band-svg.contains("baseFrequency"),
  message: "wood_band.svg must contain a baseFrequency turbulence filter")
#assert(_marble-band-svg.len() > 0,
  message: "marble_band.svg must not be empty")
#assert(_marble-band-svg.contains("baseFrequency"),
  message: "marble_band.svg must contain a baseFrequency turbulence filter")
