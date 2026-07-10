// highlights. Three shapes: "filled" (default), "cross",
// "circle". Entry forms: a square name (uses highlight-shape + highlight-fill);
// a (square, color) pair (filled, explicit color, e.g. PGN %csl); a dict
// (square:, shape:, color:) for full control. Settable options: highlight-fill +
// highlight-transparency (filled), cross-color / circle-color, cross-width /
// circle-width.
#import "/lib.typ": board, default-board-style, set-board-defaults
#import "/tests/board/_fixture.typ": test-fen

#assert(default-board-style.keys().contains("highlight-fill"), message: "highlight-fill is settable")
#assert(default-board-style.highlight-shape == "filled", message: "filled is the default shape")
#assert(default-board-style.highlight-transparency == 75%, message: "default transparency 75%")
// 0.2.2: strokes + margins default to `auto` (proportional to the square).
#assert(default-board-style.cross-width == auto and default-board-style.circle-width == auto, message: "default stroke is auto (proportional)")
#assert(default-board-style.cross-margin == auto and default-board-style.circle-margin == auto, message: "default margins are auto (proportional)")

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Highlight shapes

Filled (default, green @ 75% transparency), cross (red), circle (green). By
convention a cross marks an EMPTY square, so the cross row uses empty squares
(d4, f4, e3) while filled/circle sit on occupied ones (e4, e5, c4).

// VISUAL REGRESSION CHECK: each cross must be a complete X CONFINED to its own
// square (both diagonals overlap on d4/f4/e3), inset ~7% from the corners; each
// circle sits just inside its square border (a small ~3% margin — it no longer
// touches the border) without spilling over. Strokes are ~15% of the square.

#grid(columns: 3, column-gutter: 12pt,
  stack(dir: ttb, spacing: 4pt, align(center, emph("filled")),
    board(test-fen, size: 4cm, labels: false, highlight: ("e4", "e5", "c4"))),
  stack(dir: ttb, spacing: 4pt, align(center, emph("cross (empty squares)")),
    board(test-fen, size: 4cm, labels: false, highlight: ("d4", "f4", "e3"), highlight-shape: "cross")),
  stack(dir: ttb, spacing: 4pt, align(center, emph("circle")),
    board(test-fen, size: 4cm, labels: false, highlight: ("e4", "e5", "c4"), highlight-shape: "circle")),
)

= Per-entry shapes and colors (dict form)

A single board mixing all three shapes (crosses on empty squares), with per-entry
color overrides:

#board(test-fen, size: 5cm, labels: false, highlight: (
  (square: "e4", shape: "filled"),
  (square: "e5", shape: "circle"),
  (square: "f4", shape: "cross"),                           // empty square
  (square: "c5", shape: "circle", color: rgb(0, 70, 160)),  // blue circle
  (square: "d4", shape: "cross",  color: rgb(120, 0, 140)), // purple cross, empty
))

= Settable widths, colors, and transparency

#set-board-defaults(
  cross-color: rgb(20, 90, 200),   // blue crosses
  circle-color: rgb(220, 120, 0),  // orange circles
  cross-width: 6pt, circle-width: 2pt,
  highlight-fill: rgb(220, 60, 60), highlight-transparency: 40%,
)

After `set-board-defaults` (thicker blue cross, thin orange circle, redder/more
opaque fill); a per-call override still wins on the right:

#grid(columns: 2, column-gutter: 14pt,
  board(test-fen, size: 4cm, labels: false, highlight: (
    "e4", (square: "e3", shape: "cross"), (square: "c4", shape: "circle"),
  )),
  board(test-fen, size: 4cm, labels: false, highlight: ("e4", "e5", "c4"),
    highlight-fill: rgb(60, 90, 220), highlight-transparency: 80%),
)

#set-board-defaults(cross-color: red, circle-color: green,
  cross-width: auto, circle-width: auto, highlight-fill: green, highlight-transparency: 75%)

= Proportional strokes (0.2.2)

Same cross + circle + arrow at three square sizes. Strokes (~15%) and margins
(cross ~7%, circle ~3%) scale with the square, so the marks read the same at every
size — small boards no longer look heavy, large boards no longer look thin.

#grid(columns: 3, column-gutter: 12pt, align: bottom + center,
  ..(2cm, 4cm, 6cm).map(s => board(test-fen, size: s, labels: false,
    highlight: ((square: "e5", shape: "circle"), (square: "d4", shape: "cross")),
    arrows: (("c4", "f7"),))),
)

Overrides — a fat `20%` cross and a fixed `1pt` circle (ratio and absolute length
both accepted):

#grid(columns: 2, column-gutter: 14pt,
  board(test-fen, size: 4cm, labels: false,
    highlight: ((square: "d4", shape: "cross"),), cross-width: 20%),
  board(test-fen, size: 4cm, labels: false,
    highlight: ((square: "e5", shape: "circle"),), circle-width: 1pt, circle-margin: 0%),
)
