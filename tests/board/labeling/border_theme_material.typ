// "border" mode band THEMES: pin the theme -> texture-asset mapping exposed
// by `_band-material`, since the rendered band is a plain `rect`/`image`
// stack that Typst cannot `query()` (same precedent as `_material-asset` /
// `_square-fill` in `board/style_options/color_theme_pattern.typ`). This
// complements, and does not replace, the render sheet `border_themes.typ`.
// Companion to `border_theme_colors.typ`, which covers the `_band-colors`
// (fill/label) side of the same two themes.
#import "/src/board.typ": _band-material, _material-asset

// `_band-material` delegates to `_material-asset` so the asset paths stay
// single-sourced -- pin the agreement directly, not just the literal path,
// so a future change to `_material-asset` cannot silently drift the border
// band's texture out of sync with the square overlay's.
#assert.eq(_band-material("wood"), _material-asset("wood", true),
  message: "_band-material(\"wood\") must agree with _material-asset(\"wood\", true) -- single-sourced asset path")
#assert.eq(_band-material("marble"), _material-asset("marble", true),
  message: "_band-material(\"marble\") must agree with _material-asset(\"marble\", true) -- single-sourced asset path")

// The concrete paths themselves, pinned as documented.
#assert.eq(_band-material("wood"), "assets/patterns/wood.svg",
  message: "_band-material(\"wood\") must point at the wood-grain SVG")
#assert.eq(_band-material("marble"), "assets/patterns/marble_dark.svg",
  message: "_band-material(\"marble\") must point at the dark-square marble SVG")

// Every other border-theme (the five pre-existing flat ones) must have no
// band texture -- a stray overlay on a "flat" theme would be a silent visual
// regression, since it never fails the render.
#for t in ("square", "brown", "creme", "dark", "light") {
  assert.eq(_band-material(t), none,
    message: "_band-material(\"" + t + "\") must be none -- only \"wood\"/\"marble\" have a band texture")
}
