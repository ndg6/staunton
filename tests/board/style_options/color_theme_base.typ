// The `base:` field on `color-theme(..)` (prompt 38 §15): derives a new
// color-theme from a built-in name OR another color-theme value. Base's
// fields are merged in first, then this call's own explicit fields win.
// `base` itself is consumed and must never appear in the returned dict.
#import "/lib.typ": color-theme

// 1. `base: "<built-in name>"` merges in that built-in's light/dark, plus
// this call's own explicit field (contrast), with no leftover `base` key.
#assert.eq(
  color-theme(base: "dutch-gray", contrast: 10%),
  (light: rgb("#ffffff"), dark: rgb("#d1d2d4"), contrast: 10%),
  message: "color-theme(base: \"dutch-gray\", contrast: 10%) must merge in dutch-gray's light/dark plus its own contrast, with no `base` key left over",
)

// 2. `base: <color-theme value>` derives from another color-theme's dict
// (not a built-in name): the outer call's explicit `light` wins/appears,
// while the base's `dark` (not overridden by the outer call) is preserved.
#assert.eq(
  color-theme(base: color-theme(dark: rgb("#111111")), light: rgb("#eeeeee")),
  (dark: rgb("#111111"), light: rgb("#eeeeee")),
  message: "color-theme(base: color-theme(dark: ..), light: ..) must preserve the base's dark and use the outer call's own light",
)

// 3. Chaining: a base of a base. Both `contrast` (inherited transitively)
// and `brightness` (this call's own) must be present, dutch-gray's colors
// carried all the way through, and no `base` key anywhere in the result.
#assert.eq(
  color-theme(base: color-theme(base: "dutch-gray", contrast: 10%), brightness: -5%),
  (light: rgb("#ffffff"), dark: rgb("#d1d2d4"), contrast: 10%, brightness: -5%),
  message: "chaining base: color-theme(base: color-theme(base: .., contrast: ..), brightness: ..) must inherit contrast, keep dutch-gray's colors, add brightness, and drop `base`",
)
