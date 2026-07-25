// The `base:` field on `board-theme(..)` (prompt 38 §15): the board-theme
// analog of `color-theme(..)`'s `base:`, resolved via `_resolve-board-theme`.
// Composes with the existing nested `color-theme` field -- a board-theme can
// be derived from a base AND still carry its own `color-theme`/other
// overrides. `base` itself is consumed and must never appear in the result.
//
// Sections 3-5 are a regression suite for a precedence bug fix: `base:`
// combined with the call's OWN nested `color-theme` used to silently let
// `base`'s inherited color win over the call's own explicit override (see
// each assertion's message for the mechanism).
#import "/lib.typ": board-theme

// 1. `base: "<built-in name>"` merges in that built-in's fields, plus this
// call's own explicit field (labels), with no leftover `base` key.
// `_resolve-board-theme` (used to resolve `base`) eagerly expands a nested
// `color-theme` too, so dutch-gray's `color-theme: "dutch-gray"` shows up
// here already resolved to its light/dark colors, not as the theme name.
#assert.eq(
  board-theme(base: "dutch-gray", labels: false),
  (light: rgb("#ffffff"), dark: rgb("#d1d2d4"), labels: false, border: none),
  message: "board-theme(base: \"dutch-gray\", labels: false) must merge in dutch-gray's other fields (color-theme expanded to light/dark) plus its own labels, with no `base` key left over",
)

// 2. `base: <board-theme value>` derives from another board-theme's dict
// (not a built-in name): the outer call's explicit `border-theme` wins over
// the base's.
#assert.eq(
  board-theme(base: board-theme(border-theme: "creme"), border-theme: "dark"),
  (border-theme: "dark",),
  message: "board-theme(base: board-theme(border-theme: \"creme\"), border-theme: \"dark\") must use the outer call's own border-theme, not the base's",
)

// 3. Regression: `base:` combined with the call's OWN nested `color-theme`
// override. Precedence bug fixed in `board-theme(..)`: the call's own
// `color-theme` key used to be flattened together with `base`'s inherited
// fields before the merge, so by the time of the final merge both looked
// like plain direct fields and `base` (merged last) could win over the
// call's own explicit override. The fix expands the call's own
// `color-theme` FIRST, then merges `base` in underneath, so ordinary
// later-wins precedence applies: the explicit `light: red` here must win
// over dutch-gray's inherited `light: #ffffff`, while `dark`/`labels`/
// `border` still come through from dutch-gray untouched.
#assert.eq(
  board-theme(base: "dutch-gray", color-theme: (light: rgb("#ff0000"))),
  (light: rgb("#ff0000"), dark: rgb("#d1d2d4"), labels: false, border: none),
  message: "board-theme(base: \"dutch-gray\", color-theme: (light: red)) must let the call's own color-theme override win over dutch-gray's inherited light, while dark/labels/border still come from dutch-gray",
)

// 3'. Sibling case that must NOT have regressed: the call's own direct
// field (`light`) alongside its own nested `color-theme`, with no `base`
// at all -- the direct field must still win over the nested color-theme's
// same-named field, exactly as before the fix.
#assert.eq(
  board-theme(light: rgb("#ff0000"), color-theme: "dutch-gray"),
  (light: rgb("#ff0000"), dark: rgb("#d1d2d4")),
  message: "board-theme(light: red, color-theme: \"dutch-gray\") must keep the explicit light red and take dark from dutch-gray, with no base involved",
)

// 4. Two-level chaining through the fix: the outermost call's own explicit
// `light: red` must win over both the middle layer's own override (violet)
// and dutch-gray's original white, at every level of the chain.
#assert.eq(
  board-theme(
    base: board-theme(base: "dutch-gray", color-theme: (light: rgb("#8a2be2"))),
    color-theme: (light: rgb("#ff0000")),
  ),
  (light: rgb("#ff0000"), dark: rgb("#d1d2d4"), labels: false, border: none),
  message: "chaining base through two levels must let the outermost explicit light: red win over the middle layer's violet and dutch-gray's original white",
)

// 5. `color-theme: none` alongside `base:` is a no-op (guarded so it does
// not panic trying to resolve `none` as a theme) -- `base`'s fields pass
// through untouched, and the call's own other explicit field (`labels`)
// still overrides `base`'s.
#assert.eq(
  board-theme(base: "dutch-gray", color-theme: none, labels: true),
  (light: rgb("#ffffff"), dark: rgb("#d1d2d4"), labels: true, border: none),
  message: "board-theme(base: \"dutch-gray\", color-theme: none, labels: true) must not panic, must pass dutch-gray's light/dark/border through untouched, and must apply the explicit labels: true override",
)
