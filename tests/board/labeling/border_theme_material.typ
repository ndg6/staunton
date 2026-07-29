// "border" mode band THEMES: pin the theme -> texture-asset mapping exposed
// by `_band-material`, since the rendered band is a plain `rect`/`image`
// stack that Typst cannot `query()` (same precedent as `_material-asset` /
// `_square-fill` in `board/style_options/color_theme_pattern.typ`). This
// complements, and does not replace, the render sheet `border_themes.typ`.
// Companion to `border_theme_colors.typ`, which covers the `_band-colors`
// (fill/label) side of the same two themes.
//
// `_band-material` deliberately does NOT delegate to `_material-asset`: the
// band is drawn as a SINGLE image spanning the whole band rect, and its
// VISIBLE ring is only ~6% of that image (the rest sits behind the board), so
// it needs artwork composed at band scale rather than a square's artwork
// stretched. So the two functions must return DIFFERENT paths for the same
// pattern -- pin that divergence directly, so a future "simplification" that
// restores the delegation fails loudly here.
#import "/src/board.typ": _band-material, _material-asset

// The concrete band-scale paths, pinned as documented. Note the asymmetry:
// wood is vector, marble is raster. That is deliberate and follows from the
// materials themselves -- wood's figure is a few coherent describable curves
// (which vector authoring does well), marble's is stochastic, multi-scale and
// dendritic (which it does not). Do not "unify" these to one format.
#assert.eq(_band-material("wood"), "assets/patterns/wood_band.svg",
  message: "_band-material(\"wood\") must point at the band-scale wood-grain SVG")
#assert.eq(_band-material("marble"), "assets/patterns/marble_band.png",
  message: "_band-material(\"marble\") must point at the band-scale marble PNG")

// Every other border-theme (the five pre-existing flat ones) must have no
// band texture -- a stray overlay on a "flat" theme would be a silent visual
// regression, since it never fails the render.
#for t in ("square", "brown", "creme", "dark", "light") {
  assert.eq(_band-material(t), none,
    message: "_band-material(\"" + t + "\") must be none -- only \"wood\"/\"marble\" have a band texture")
}

// The band and square assets must NOT agree: the band uses its own
// band-scale asset by design (a square's artwork stretched over the band
// loses its material character). If someone "restores" `_band-material` to
// call `_material-asset` directly, these must fail.
#assert.ne(_band-material("wood"), _material-asset("wood", true),
  message: "_band-material(\"wood\") must NOT agree with _material-asset(\"wood\", true) -- " +
    "the band deliberately uses its own band-scale asset (wood_band.svg), not the square one; " +
    "restoring the old delegation reintroduces the degraded-texture regression")
#assert.ne(_band-material("marble"), _material-asset("marble", true),
  message: "_band-material(\"marble\") must NOT agree with _material-asset(\"marble\", true) -- " +
    "the band deliberately uses its own band-scale asset (marble_band.png), not the square one; " +
    "restoring the old delegation reintroduces the degraded-texture regression")

// Cheap structural checks that the band assets actually exist and are the
// right KIND of file -- a wrong path would otherwise only surface as a compile
// error inside a render sheet, and a silently missing texture is this repo's
// documented failure mode.
//
// Wood: an SVG whose grain is CONCENTRIC to the frame (nested `<rect>`s), so
// it follows the perimeter on all four sides and survives any
// `label-border-ratio`. A mitred frame would only line up at one ratio, and
// grain running one direction reads as end-grain across the top and bottom.
#let _wood-band = read("/src/" + _band-material("wood"))
#assert(_wood-band.len() > 0, message: "wood_band.svg must not be empty")
#assert(_wood-band.contains("<rect"),
  message: "wood_band.svg must draw concentric rects -- that construction is what makes the " +
    "grain follow the frame perimeter and stay correct at any label-border-ratio")
#assert(_wood-band.contains("feDisplacementMap"),
  message: "wood_band.svg must warp its rings; perfectly concentric rings read as machined ripple, not timber")
// The alpha-forcing color matrix before the displacement map is load-bearing:
// without it Typst's renderer collapses the premultiplied turbulence RGB to 0
// where alpha is 0 and displaces the whole image off-canvas (a blank band).
#assert(_wood-band.contains("feColorMatrix"),
  message: "wood_band.svg must force turbulence alpha to 1 before feDisplacementMap -- " +
    "without it resvg displaces the artwork off-canvas and the band renders blank")

// Marble: a PNG. Check the magic bytes rather than trusting the extension.
#let _marble-band = read("/src/" + _band-material("marble"), encoding: none)
#assert(_marble-band.len() > 0, message: "marble_band.png must not be empty")
#assert(array(_marble-band).slice(0, 4) == (0x89, 0x50, 0x4E, 0x47),
  message: "marble_band.png must really be a PNG (magic bytes 89 50 4E 47)")
