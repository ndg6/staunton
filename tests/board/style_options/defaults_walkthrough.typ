// RENDER-ONLY sheet: a systematic walk through the settable *board* style options
// from manual chapter 11.2 (@board-options), driven ENTIRELY through the
// DOCUMENT-WIDE setter `set-board-defaults(..)` — never per-call. Each demo resets
// to a common baseline, sets ONE option (group) as a document default, prints the
// exact call, then renders a bare `board(<fen>)` that reads that default.
//
// NOT every board option is a legal default: the position-specific ones
// (`board-non-default-keys`) are rejected by the setters — `highlight` / `arrows`
// are per-CALL only (different squares per diagram), and `move-quality-mark` is
// derived from a game move by `diagram(.., at: ..)`. So this sheet:
//   * sets the highlight/arrow *styling* (colors, shapes, widths) as defaults, but
//     passes the `highlight` / `arrows` LIST per call (as it must be);
//   * shows `move-quality` + `move-quality-colors` as defaults, but lets
//     `diagram(.., at: ..)` supply the badge's mark from a NAG-annotated game.
// The erroring of `set-board-defaults(highlight:/arrows:/move-quality-mark: ..)` is
// covered by failed_options/.
//
// Claude owns the asserts (the settable / rejected key contract + the derived
// mark); the user eyeballs the rendered options — see tests/VISUAL_CHECKS.md.
#import "/lib.typ": (
  board, diagram, game, to-fen, with-nags,
  set-board-defaults, default-board-style, board-style-keys, board-non-default-keys,
)
#import "/src/game.typ": move-quality-mark

// --- the NAG-annotated game (literal quality suffixes) ---------------------
// 1.e4! e5? 2.Nf3!! Nc6?? ...  — a badge sits on each graded move's destination.
#let g = game("1. e4! e5? 2. Nf3!! Nc6?? 3. Bb5!? a6?!")
// A separate line whose mate leaves the Black king in check (for `check:`), with a
// programmatic `!` on the mating move so it also carries a good-move badge.
#let mate = with-nags(
  game("1. e4 e5 2. Qh5 Nc6 3. Bc4 Nf6?? 4. Qxf7# 1-0"),
  ("4w": "!"),
)

#let main-fen  = to-fen(g, locator: "2b")   // open position after 2...Nc6??
#let mate-fen  = to-fen(mate, locator: "4w")    // 4.Qxf7#  — Black king in check

// --- machine-checkable contract --------------------------------------------
// The three position-specific keys are rejected by the setters (see the guard in
// src/style.typ and the failed_options/ expected-fail tests).
#assert.eq(board-non-default-keys, ("highlight", "arrows", "move-quality-mark"))
// They ARE still real per-call board keys (only the setters refuse them).
#for k in board-non-default-keys {
  assert(board-style-keys.contains(k), message: k + " is still a board key")
}
// Every option this sheet drives through `set-board-defaults` IS a settable board
// default — i.e. a real board key that is NOT position-specific.
#let demoed-keys = (
  "size", "light", "dark", "pattern", "brightness", "contrast", "color-theme",
  "board-theme", "labels", "label-font", "label-mode", "label-color",
  "label-border-ratio", "file-side", "rank-side", "file-label-corner",
  "rank-label-corner", "border-theme", "border", "grid", "piece-set",
  "piece-scale", "highlight-shape", "highlight-fill", "highlight-transparency",
  "cross-color", "cross-width", "circle-color", "circle-width",
  "frame-color", "frame-width", "arrow-color",
  "arrow-transparency", "arrow-width", "check", "check-color", "check-square",
  "move-quality", "move-quality-colors", "annotation-colors", "white-fill",
  "black-fill", "piece-font", "baseline-inset",
)
#for k in demoed-keys {
  assert(board-style-keys.contains(k), message: "not a board option: " + k)
  assert(not board-non-default-keys.contains(k), message: "should be per-call: " + k)
}
// The badge marks are derived from the game, not hand-fed.
#assert.eq(move-quality-mark(g, "2b"), (square: "c6", symbol: "??"))
#assert.eq(move-quality-mark(mate, "4w"), (square: "f7", symbol: "!"))

#set page(width: 15cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 9.5pt)
#set raw(lang: "typ")

// A common baseline so every board differs from it in exactly ONE option group.
// Drop the position-specific keys — the setters reject them (that is the point of
// this change), so a reset dict must not carry them.
#let base = {
  let b = (:)
  for (k, v) in default-board-style {
    if not board-non-default-keys.contains(k) { b.insert(k, v) }
  }
  b + (size: 3cm)
}

// demo(code, ..opts): reset to `base`, apply `opts` as document defaults, then show
// the printed `code` snippet next to the resulting board. `fen:` overrides the
// source; `call:` are per-CALL args passed to `board` (for `highlight` /
// `arrows`, which cannot be defaults).
#let demo(code, fen: main-fen, call: (:), ..opts) = {
  set-board-defaults(..base)
  set-board-defaults(..opts.named())
  block(above: 1em, breakable: false, grid(
    columns: (1fr, auto), gutter: 0.7cm, align: (left + horizon, right),
    raw(code),
    board(fen, ..call),
  ))
}

#align(center, text(14pt, weight: "bold")[
  `set-board-defaults(..)` — every *settable* board default, document-wide
])

Baseline (`size: 3cm`, all else factory default), for comparison:
#block(above: 0.8em, board(main-fen))

= Sizing
#demo("set-board-defaults(size: 4cm)", size: 4cm)

= Colors  (`light` / `dark`)
#demo("set-board-defaults(\n  light: rgb(\"#eeeed2\"), dark: rgb(\"#769656\"),\n)",
  light: rgb("#eeeed2"), dark: rgb("#769656"))

= Square patterns  (`pattern`, normally set via `color-theme(.., pattern: ..)`)
`"marble"`/`"wood"` are transparent material overlays -- pick a `light`/`dark`
pair that suits the material (shown here; the manual has the same pairings).
#demo("set-board-defaults(pattern: \"stripes\")", pattern: "stripes")
#demo(
  "set-board-defaults(\n  pattern: \"marble\",\n  light: rgb(\"#eeeed2\"), dark: rgb(\"#3f6b4a\"),\n)",
  pattern: "marble", light: rgb("#eeeed2"), dark: rgb("#3f6b4a"))
#demo(
  "set-board-defaults(\n  pattern: \"wood\",\n  light: rgb(\"#d9b98a\"), dark: rgb(\"#6b4a2f\"),\n)",
  pattern: "wood", light: rgb("#d9b98a"), dark: rgb("#6b4a2f"))

= Brightness / contrast  (nudge a pair's lightness without picking new colors)
#demo("set-board-defaults(brightness: -20%)", brightness: -20%)
#demo("set-board-defaults(contrast: 40%)", contrast: 40%)

= Labels
#demo("set-board-defaults(labels: false)", labels: false)
#demo("set-board-defaults(\n  label-mode: \"outside\", label-color: rgb(\"#b58863\"),\n)",
  label-mode: "outside", label-color: rgb("#b58863"))
#demo("set-board-defaults(\n  label-mode: \"border\", border-theme: \"brown\",\n  label-border-ratio: 0.12,\n)",
  label-mode: "border", border-theme: "brown", label-border-ratio: 0.12)
#demo("set-board-defaults(label-font: \"Libertinus Serif\")", label-font: "Libertinus Serif")
#demo("set-board-defaults(file-side: top, rank-side: left)", file-side: top, rank-side: left)
#demo("set-board-defaults(\n  file-label-corner: right, rank-label-corner: left,\n)",
  file-label-corner: right, rank-label-corner: left)

= Border  (`border-theme` band / `border` outline)
The band only shows under `label-mode: "border"`; `border` (the outline
stroke, below) is independent and shows under any label mode.
#demo("set-board-defaults(\n  label-mode: \"border\", border-theme: \"dark\",\n)",
  label-mode: "border", border-theme: "dark")
#demo("set-board-defaults(\n  label-mode: \"border\", border-theme: \"creme\",\n)",
  label-mode: "border", border-theme: "creme")
#demo("set-board-defaults(\n  label-mode: \"border\", border-theme: \"light\",\n)",
  label-mode: "border", border-theme: "light")
#demo(
  "set-board-defaults(\n  label-mode: \"border\", border-theme: \"wood\",\n  pattern: \"wood\", light: rgb(\"#d9b98a\"), dark: rgb(\"#6b4a2f\"),\n)",
  label-mode: "border", border-theme: "wood",
  pattern: "wood", light: rgb("#d9b98a"), dark: rgb("#6b4a2f"))
#demo(
  "set-board-defaults(\n  label-mode: \"border\", border-theme: \"marble\",\n  color-theme: \"emerald\",\n)",
  label-mode: "border", border-theme: "marble", color-theme: "emerald")
#demo("set-board-defaults(border: 2.5pt + rgb(\"#8b0000\"))", border: 2.5pt + rgb("#8b0000"))
#demo("set-board-defaults(border: none)", border: none)

= Reusable `color-theme` / `board-theme` values  (shorthand for the fields above)
`color-theme` bundles `light`/`dark`/`pattern`/`brightness`/`contrast`;
`board-theme` bundles a full board look (any board style field, plus a nested
color theme). Both accept a built-in name or a constructor value; setting
either as a document default expands it into the individual fields above.
#demo("set-board-defaults(color-theme: \"marine\")", color-theme: "marine")
#demo("set-board-defaults(board-theme: \"dutch-gray\")  // also sets labels: false, border: none",
  board-theme: "dutch-gray")

= Grid
#demo("set-board-defaults(grid: true)", grid: true)

= Piece set / scale
#demo("set-board-defaults(piece-set: \"merida\")", piece-set: "merida")
#demo("set-board-defaults(piece-scale: 0.7)", piece-scale: 0.7)

= Highlight *styling* (the `highlight` LIST stays per-call)
Colors, shapes and widths are document defaults; the squares are not, so the
`highlight:` list is passed to `board` per call.
#demo(
  "set-board-defaults(\n  highlight-fill: blue, highlight-transparency: 45%,\n)\nboard(fen, highlight: (\"e4\", \"c6\", \"d5\"))",
  call: (highlight: ("e4", "c6", "d5")),
  highlight-fill: blue, highlight-transparency: 45%)
#demo(
  "set-board-defaults(\n  highlight-shape: \"circle\",\n  circle-color: orange, circle-width: 3.5pt,\n)\nboard(fen, highlight: (\"e5\",))",
  call: (highlight: ("e5",)),
  highlight-shape: "circle", circle-color: orange, circle-width: 3.5pt)
#demo(
  "set-board-defaults(\n  highlight-shape: \"cross\",\n  cross-color: purple, cross-width: 4pt,\n)\nboard(fen, highlight: (\"f3\",))",
  call: (highlight: ("f3",)),
  highlight-shape: "cross", cross-color: purple, cross-width: 4pt)
#demo(
  "set-board-defaults(\n  highlight-shape: \"frame\",\n  frame-color: maroon, frame-width: 3pt,\n)\nboard(fen, highlight: (\"c6\",))",
  call: (highlight: ("c6",)),
  highlight-shape: "frame", frame-color: maroon, frame-width: 3pt)

= Arrow *styling* (the `arrows` LIST stays per-call)
#demo(
  "set-board-defaults(\n  arrow-color: teal,\n  arrow-transparency: 20%, arrow-width: 10pt,\n)\nboard(fen, arrows: ((\"f1\", \"b5\"),))",
  call: (arrows: (("f1", "b5"),)),
  arrow-color: teal, arrow-transparency: 20%, arrow-width: 10pt)

= Check glow  (fen = the mate `4.Qxf7#`, Black king in check)
#demo("set-board-defaults(\n  check: true, check-color: rgb(\"#2b6cff\"),\n)",
  fen: mate-fen, check: true, check-color: rgb("#2b6cff"))
#demo("set-board-defaults(check: true, check-square: \"e1\")  // force a square",
  fen: mate-fen, check: true, check-square: "e1")

= Move-quality badge  (switch + colors are defaults; the MARK comes from the game)
`move-quality: true` and `move-quality-colors` are legitimate document defaults, but
the badge's *mark* is move-specific, so `move-quality-mark` is *not* a default —
`diagram(.., at: ..)` derives it from the graded move. (`highlight` / `arrows` /
`move-quality-mark` all error in the setters; see failed_options/.)

#set-board-defaults(..base)
#set-board-defaults(move-quality: true)
Default badge colors, from the game — red `??` on c6 (`2...Nc6??`):
#diagram(g, at: "2b", caption: none, game-info: none, size: 3cm)

#set-board-defaults(move-quality-colors: (good: navy, bad: fuchsia, interesting: olive))
After `set-board-defaults(move-quality-colors: (bad: fuchsia, ..))` — same board, fuchsia disc:
#diagram(g, at: "2b", caption: none, game-info: none, size: 3cm)

Combined with the glow, on the mate — a `!` badge on f7 and the auto-located king glow:
#set-board-defaults(..base)
#set-board-defaults(check: true, move-quality: true)
#diagram(mate, at: "4w", caption: none, game-info: none, size: 3cm)

= Unicode glyph fallback  (`piece-set: "unicode"` + its fallback-only options)
#demo("set-board-defaults(\n  piece-set: \"unicode\", baseline-inset: 0.12,\n  white-fill: rgb(\"#f7f7f7\"), black-fill: black,\n)",
  piece-set: "unicode", baseline-inset: 0.12,
  white-fill: rgb("#f7f7f7"), black-fill: black)

// `annotation-colors` (PGN %cal/%csl color-letter -> color) only takes effect when a
// GAME's drawn annotations are rendered (diagram(.., at: ..) / notation), not on a bare
// `board`, so it has no isolated board to show here — it is asserted settable
// above and eyeballed in tests/pgn/annotations/.

// --- document-order inheritance (machine-checkable) ------------------------
// A default set through the bucket IS what a later bare board reads; `board()`
// resolves exactly `default-board-style + board-style-state.get()`, so asserting
// that expression is faithful. A per-call arg overrides only for its own call and
// never writes to this state (by construction: the setters update state, `board()`
// merges per-call args on top at call time). This is the semantics the retired
// render-only `inheritance.typ` used to show visually.
#import "/src/style.typ": board-style-state
#set-board-defaults(..base)
#set-board-defaults(piece-set: "merida", light: rgb("#eeeed2"))
#context {
  let resolved = default-board-style + board-style-state.get()
  assert(resolved.piece-set == "merida", message: "document default piece-set is inherited")
  assert(resolved.light == rgb("#eeeed2"), message: "document default light is inherited")
}
