// The `brightness` / `contrast` fields on `color-theme(..)` (prompt 38 §2/§12/
// §13): pins the pure `_adjust-color-pair` helper's math, since the rendered
// square is a plain `rect` that Typst cannot `query()` -- this is the ONLY
// machine-checkable form of the brightness/contrast -> lightness mapping (see
// the module comment above `_adjust-color-pair` in src/style.typ). This
// complements, and does not replace, the render sheet
// `board/colors/brightness_contrast.typ`.
#import "/lib.typ": color-theme
#import "/src/style.typ": _adjust-color-pair, _rgb-to-hsl

// Small tolerance for float round-trips through the RGB <-> HSL <-> RGB
// conversion (8-bit channel quantization inside `rgb()` can nudge the last
// bit or two of a re-derived hue/saturation/lightness).
#let eps = 0.001
#let close(a, b, tol: eps) = calc.abs(a - b) < tol

// A theme pair already >= 5% apart in lightness (true of every built-in
// theme), used throughout below.
#let light = rgb("#f0d9b5")
#let dark = rgb("#b58863")

// 1. Identity when unused: `auto`/`auto` and `0%`/`0%` must return the EXACT
// input colors unchanged -- this guarantees the feature is invisible to every
// existing board unless explicitly used.
#let r-auto = _adjust-color-pair(light, dark, auto, auto)
#assert.eq(r-auto.light, light, message: "brightness/contrast auto/auto must not touch `light`")
#assert.eq(r-auto.dark, dark, message: "brightness/contrast auto/auto must not touch `dark`")

#let r-zero = _adjust-color-pair(light, dark, 0%, 0%)
#assert.eq(r-zero.light, light, message: "brightness/contrast 0%/0% must not touch `light`")
#assert.eq(r-zero.dark, dark, message: "brightness/contrast 0%/0% must not touch `dark`")

// 2. Guard 1 (input clamp): out-of-range brightness behaves identically to
// the clamped-in-range value -- no error, silently clamped.
#let r-500 = _adjust-color-pair(light, dark, 500%, auto)
#let r-100 = _adjust-color-pair(light, dark, 100%, auto)
#assert.eq(r-500, r-100, message: "brightness: 500% must clamp to the same result as 100%")

#let r-neg500 = _adjust-color-pair(light, dark, -500%, auto)
#let r-neg100 = _adjust-color-pair(light, dark, -100%, auto)
#assert.eq(r-neg500, r-neg100, message: "brightness: -500% must clamp to the same result as -100%")

// 3. Guard 2 (separation floor) + field identity, swept across contrast
// (including the exact-collapse case at -100% and values beyond the clamp
// range) and brightness (also beyond the clamp range, to exercise guard 1
// simultaneously). Every sampled combination must: (a) keep light/dark
// lightness >= 5% apart, (b) keep `light` at least as light as `dark`
// (field identity, not magnitude), (c) stay within [0, 1].
#let contrasts = (-200%, -100%, -50%, 0%, 50%, 100%, 200%)
#let brightnesses = (-200%, -150%, -100%, -50%, 0%, 50%, 100%, 150%, 200%)
#for cc in contrasts {
  for bb in brightnesses {
    let r = _adjust-color-pair(light, dark, bb, cc)
    let hl = _rgb-to-hsl(r.light)
    let hd = _rgb-to-hsl(r.dark)
    let tag = "brightness: " + repr(bb) + ", contrast: " + repr(cc)
    assert(hl.l - hd.l > 0.05 - eps, message: tag + " must keep light/dark lightness >= 5% apart, got " + repr(hl.l - hd.l))
    assert(hl.l >= hd.l, message: tag + " must keep `light` at least as light as `dark`")
    assert(hl.l >= 0 and hl.l <= 1, message: tag + " must keep light's lightness within [0, 1]")
    assert(hd.l >= 0 and hd.l <= 1, message: tag + " must keep dark's lightness within [0, 1]")
  }
}

// 4. Hue/saturation preserved: pick a colorful (non-grayscale) pair with
// distinct hues and confirm a brightness-only nudge and a contrast-only nudge
// each leave H/S untouched -- only lightness moves.
#let hue-light = rgb("#3050c0")
#let hue-dark = rgb("#c05030")
#let hl0 = _rgb-to-hsl(hue-light)
#let hd0 = _rgb-to-hsl(hue-dark)

#let r-bright = _adjust-color-pair(hue-light, hue-dark, 15%, auto)
#let hl-b = _rgb-to-hsl(r-bright.light)
#let hd-b = _rgb-to-hsl(r-bright.dark)
#assert(close(hl0.h.deg(), hl-b.h.deg()), message: "a brightness-only nudge must not change `light`'s hue")
#assert(close(hl0.s / 1%, hl-b.s / 1%), message: "a brightness-only nudge must not change `light`'s saturation")
#assert(close(hd0.h.deg(), hd-b.h.deg()), message: "a brightness-only nudge must not change `dark`'s hue")
#assert(close(hd0.s / 1%, hd-b.s / 1%), message: "a brightness-only nudge must not change `dark`'s saturation")

#let r-contrast = _adjust-color-pair(hue-light, hue-dark, auto, 25%)
#let hl-c = _rgb-to-hsl(r-contrast.light)
#let hd-c = _rgb-to-hsl(r-contrast.dark)
#assert(close(hl0.h.deg(), hl-c.h.deg()), message: "a contrast-only nudge must not change `light`'s hue")
#assert(close(hl0.s / 1%, hl-c.s / 1%), message: "a contrast-only nudge must not change `light`'s saturation")
#assert(close(hd0.h.deg(), hd-c.h.deg()), message: "a contrast-only nudge must not change `dark`'s hue")
#assert(close(hd0.s / 1%, hd-c.s / 1%), message: "a contrast-only nudge must not change `dark`'s saturation")

// 5. `color-theme(..)` accepts `brightness`/`contrast` and just collects them,
// same as `light`/`dark`/`pattern` -- the constructor does not resolve the
// adjustment; that only happens inside `_adjust-color-pair` at render time.
#assert.eq(
  color-theme(light: light, dark: dark, brightness: 20%, contrast: -10%),
  (light: light, dark: dark, brightness: 20%, contrast: -10%),
  message: "color-theme(..) must accept and collect valid `brightness`/`contrast` values",
)
#assert.eq(
  color-theme(light: light, dark: dark, brightness: auto, contrast: auto),
  (light: light, dark: dark, brightness: auto, contrast: auto),
  message: "color-theme(..) must accept `auto` for `brightness`/`contrast`",
)
