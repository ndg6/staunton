// Two-layer board theming (`color-theme(..)` / `board-theme(..)`, the built-in
// registries, and the pure `_expand-themes` resolver). Asserting test only —
// `_expand-themes` is pure and importable so the whole resolution surface is
// machine-checkable; no rendered pixels are asserted here (see CLAUDE.md /
// the task brief: rendered colors are NOT assertable).
#import "/lib.typ": (
  board, color-theme, board-theme, set-board-defaults, default-board-style,
)
#import "/src/style.typ": (
  _expand-themes, board-style-state, builtin-color-themes, builtin-board-themes,
)

// --- 1. constructors ---------------------------------------------------------
#assert.eq(color-theme(light: red, dark: blue), (light: red, dark: blue),
  message: "color-theme should just collect light/dark")
#assert.eq(board-theme(labels: false, border: none),
  (labels: false, border: none),
  message: "board-theme should just collect named board-style overrides")
#assert.eq(board-theme(color-theme: "dutch-gray", labels: false),
  (color-theme: "dutch-gray", labels: false),
  message: "board-theme should pass a nested color-theme through unresolved")

// --- 2. built-in registries ---------------------------------------------------
// "staunton-default" must be DERIVED from the factory colors, never retyped, so
// this stays in sync if the factory palette is ever retuned.
#assert.eq(builtin-color-themes.at("staunton-default"),
  (light: default-board-style.light, dark: default-board-style.dark),
  message: "staunton-default color theme must equal the factory board colors")
#assert.eq(builtin-color-themes.keys().sorted(), ("dutch-gray", "staunton-default"),
  message: "exactly two built-in color themes are expected")
#assert.eq(builtin-board-themes.keys().sorted(), ("dutch-gray", "staunton-default"),
  message: "exactly two built-in board themes are expected")
#assert.eq(builtin-color-themes.at("dutch-gray"), (light: rgb("#ffffff"), dark: rgb("#d1d2d4")),
  message: "dutch-gray color theme values changed")
#assert.eq(builtin-board-themes.at("dutch-gray"),
  (color-theme: "dutch-gray", labels: false, border: none),
  message: "dutch-gray board theme contribution changed")

// --- 3. `_expand-themes` unit tests -------------------------------------------

// 3a. only `color-theme`, given by built-in NAME.
#assert.eq(
  _expand-themes((color-theme: "dutch-gray", size: 3cm)),
  (size: 3cm, light: rgb("#ffffff"), dark: rgb("#d1d2d4")),
  message: "color-theme by name should expand to its light/dark fields",
)
// 3a'. only `color-theme`, given as a `#let`-bound VALUE (user theme, not registered).
#let my-colors = color-theme(light: rgb("#eeeed2"), dark: rgb("#769656"))
#assert.eq(
  _expand-themes((color-theme: my-colors)),
  (light: rgb("#eeeed2"), dark: rgb("#769656")),
  message: "a color-theme VALUE should expand the same way as a built-in name",
)

// 3b. only `board-theme`, nested color-theme as a NAME.
// The theme keys must not survive expansion.
#assert(not "color-theme" in _expand-themes((board-theme: "dutch-gray")),
  message: "color-theme key must not survive expansion")
#assert(not "board-theme" in _expand-themes((board-theme: "dutch-gray")),
  message: "board-theme key must not survive expansion")
// board-theme's actual expected contribution: light/dark from dutch-gray plus its
// own labels/border overrides.
#assert.eq(
  _expand-themes((board-theme: "dutch-gray")),
  (light: rgb("#ffffff"), dark: rgb("#d1d2d4"), labels: false, border: none),
  message: "dutch-gray board-theme should expand to color fields + labels + border",
)

// 3b'. only `board-theme`, nested color-theme as a VALUE (a `board-theme(..)` call
// holding an inline `color-theme(..)` value, not a built-in name).
#let my-board-theme = board-theme(color-theme: my-colors, grid: true)
#assert.eq(
  _expand-themes((board-theme: my-board-theme)),
  (light: rgb("#eeeed2"), dark: rgb("#769656"), grid: true),
  message: "board-theme with a nested color-theme VALUE should expand the same way",
)

// 3c. the full precedence worked example:
//   board-theme(color-theme: A, labels: false)  <  explicit color-theme: B
//     <  explicit individual field `light: red`   -- all in the SAME layer.
#let theme-a = color-theme(light: rgb("#111111"), dark: rgb("#222222"))
#let theme-b = color-theme(light: rgb("#333333"), dark: rgb("#444444"))
#let bt-a = board-theme(color-theme: theme-a, labels: false)
#let precedence-layer = (
  board-theme: bt-a,
  color-theme: theme-b,
  light: red,
)
#let resolved = _expand-themes(precedence-layer)
#assert.eq(resolved.labels, false,
  message: "labels should come from the board-theme (nothing overrides it)")
#assert.eq(resolved.dark, rgb("#444444"),
  message: "dark should come from the explicit color-theme B, which beats the board-theme's nested color-theme A")
#assert.eq(resolved.light, red,
  message: "light should come from the explicit individual field, which beats everything else")
#assert(not "board-theme" in resolved, message: "board-theme key must not survive expansion")
#assert(not "color-theme" in resolved, message: "color-theme key must not survive expansion")

// 3d. a layer with neither key is returned unchanged (identity fast path).
#assert.eq(_expand-themes((size: 3cm, grid: true)), (size: 3cm, grid: true),
  message: "a layer without theme keys must pass through unchanged")

// --- 4. document-order behavior (both directions) -----------------------------
// `set-board-defaults` expands themes EAGERLY at call time, so two calls that set
// overlapping fields must resolve in DOCUMENT order (later call wins), exactly as
// plain fields already do -- this is the whole reason expansion is eager instead
// of lazy (see the module comment in src/style.typ). Pin both directions.

// 4a. explicit field first, THEME second -> the later theme call wins.
#set-board-defaults(light: red)
#set-board-defaults(color-theme: "dutch-gray")
#context {
  let resolved = board-style-state.get()
  assert.eq(resolved.light, rgb("#ffffff"),
    message: "BROKEN DIRECTION A: a later set-board-defaults(color-theme: ..) must win over an earlier explicit `light:`, but light was " + repr(resolved.light))
}

// 4b. the reverse: THEME first, explicit field second -> the later explicit field wins.
#set-board-defaults(color-theme: "dutch-gray")
#set-board-defaults(light: red)
#context {
  let resolved = board-style-state.get()
  assert.eq(resolved.light, red,
    message: "BROKEN DIRECTION B: a later explicit set-board-defaults(light: ..) must win over an earlier color-theme, but light was " + repr(resolved.light))
}

// --- 5. per-call layer ---------------------------------------------------------
// `board()` resolves `default-style + style-state.get() + _expand-themes(overrides)`
// (see render-board in src/board.typ) -- i.e. the SAME `_expand-themes` call this
// file already unit-tests above, applied to the per-call overrides dict. We cannot
// observe the resolved style from outside `render-board` (it never escapes the
// `context` block), so this only proves (a) the call compiles with a per-call
// theme + an explicit field mixed, and (b) `_expand-themes` on an identical dict
// gives the expected explicit-wins result -- it does NOT independently confirm
// `render-board` really uses that expression (that part is a source-reading fact,
// not something this test re-derives).
#board((:), color-theme: "dutch-gray", light: red, size: 2cm)
#assert.eq(
  _expand-themes((color-theme: "dutch-gray", light: red)).light,
  red,
  message: "per-call explicit `light:` must win over a per-call color-theme",
)

// --- 6. round-trip to house style (guards against the spec violation where
// "staunton-default" only restored colors, leaving `labels`/`border` stale from
// whatever theme was applied before it). Assert against the FACTORY defaults,
// never literals, so this stays correct if the factory palette/labels/border
// default is ever retuned.
#assert.eq(
  _expand-themes((board-theme: "staunton-default")).labels,
  default-board-style.labels,
  message: "staunton-default board-theme must restore the factory `labels` default",
)
#assert.eq(
  _expand-themes((board-theme: "staunton-default")).border,
  default-board-style.border,
  message: "staunton-default board-theme must restore the factory `border` default",
)
// Round-trip: dutch-gray (labels: false, border: none) then back to
// staunton-default must NOT leave dutch-gray's overrides stuck in the state.
#set-board-defaults(board-theme: "dutch-gray")
#set-board-defaults(board-theme: "staunton-default")
#context {
  let resolved = board-style-state.get()
  assert.eq(resolved.labels, default-board-style.labels,
    message: "round-trip to staunton-default must restore factory `labels`, not leave dutch-gray's `false` behind")
  assert.eq(resolved.border, default-board-style.border,
    message: "round-trip to staunton-default must restore factory `border`, not leave dutch-gray's `none` behind")
}

// --- 7. built-in symmetry invariant: every `builtin-board-themes` entry sets the
// SAME key set. Written as a loop over the registry (not hardcoded per-theme
// assertions) so it automatically covers future built-ins too -- the guard that
// matters when more themes land: a theme that forgets a key would otherwise
// leave a stale field behind when switching away from it.
#{
  let names = builtin-board-themes.keys().sorted()
  let key-sets = names.map(n => builtin-board-themes.at(n).keys().sorted())
  for (n, ks) in names.zip(key-sets) {
    assert.eq(ks, key-sets.first(),
      message: "builtin-board-themes." + n + " sets a different key set than " + names.first() + " -- every built-in must set the same keys")
  }
}

// --- 8. a nested `color-theme: none` inside a board-theme must not leak into
// the expanded output (a no-op nested theme, distinct from "absent").
#assert.eq(
  _expand-themes((board-theme: board-theme(color-theme: none, grid: true))),
  (grid: true),
  message: "a nested color-theme: none must not leak `color-theme` into the expansion",
)

// --- 9. universal no-leak property: `_expand-themes` output must contain
// neither `board-theme` nor `color-theme`, for every input shape exercised in
// this file (name, value, nested-by-name, nested-by-value, none, absent).
#let no-leak-cases = (
  (color-theme: "dutch-gray"),
  (color-theme: my-colors),
  (board-theme: "dutch-gray"),
  (board-theme: my-board-theme),
  (board-theme: board-theme(color-theme: none, grid: true)),
  (board-theme: none, color-theme: none),
  (size: 3cm), // absent
)
#for case in no-leak-cases {
  let out = _expand-themes(case)
  assert(not "board-theme" in out, message: "board-theme key leaked for input " + repr(case))
  assert(not "color-theme" in out, message: "color-theme key leaked for input " + repr(case))
}

// (the derivation guard for `builtin-color-themes."staunton-default"` is
// already covered in section 2 above -- not repeated here.)
