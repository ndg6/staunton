// §prompt 12, item 3 - highlights. Three shapes: "filled" (default), "cross",
// "circle". Entry forms: a square name (uses highlight-shape + highlight-fill);
// a (square, color) pair (filled, explicit colour, e.g. PGN %csl); a dict
// (square:, shape:, color:) for full control. Settable options: highlight-fill +
// highlight-transparency (filled), cross-color / circle-color, cross-width /
// circle-width.
#import "/lib.typ": board, default-board-style, set-board-defaults
#import "/tests/board/_fixture.typ": test-fen

#assert(default-board-style.keys().contains("highlight-fill"), message: "highlight-fill is settable")
#assert(default-board-style.highlight-shape == "filled", message: "filled is the default shape")
#assert(default-board-style.highlight-transparency == 75%, message: "default transparency 75%")
#assert(default-board-style.cross-width == 4pt and default-board-style.circle-width == 4pt, message: "default stroke 4pt")

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Highlight shapes

Filled (default, green @ 75% transparency), cross (red), circle (green). By
convention a cross marks an EMPTY square, so the cross row uses empty squares
(d4, f4, e3) while filled/circle sit on occupied ones (e4, e5, c4):

#grid(columns: 3, column-gutter: 12pt,
  stack(dir: ttb, spacing: 4pt, align(center, emph("filled")),
    board(test-fen, size: 4cm, labels: false, highlight: ("e4", "e5", "c4"))),
  stack(dir: ttb, spacing: 4pt, align(center, emph("cross (empty squares)")),
    board(test-fen, size: 4cm, labels: false, highlight: ("d4", "f4", "e3"), highlight-shape: "cross")),
  stack(dir: ttb, spacing: 4pt, align(center, emph("circle")),
    board(test-fen, size: 4cm, labels: false, highlight: ("e4", "e5", "c4"), highlight-shape: "circle")),
)

= Per-entry shapes and colours (dict form)

A single board mixing all three shapes (crosses on empty squares), with per-entry
colour overrides:

#board(test-fen, size: 5cm, labels: false, highlight: (
  (square: "e4", shape: "filled"),
  (square: "e5", shape: "circle"),
  (square: "f4", shape: "cross"),                           // empty square
  (square: "c5", shape: "circle", color: rgb(0, 70, 160)),  // blue circle
  (square: "d4", shape: "cross",  color: rgb(120, 0, 140)), // purple cross, empty
))

= Settable widths, colours, and transparency

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
