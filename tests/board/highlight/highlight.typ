// §item 7 - highlight color is a settable board-style option (`highlight-fill`).
// Confirm the document default can be set and a per-call override still wins.
#import "/lib.typ": board, default-board-style, set-board-defaults
#import "/tests/board/_fixture.typ": test-fen

#assert(default-board-style.keys().contains("highlight-fill"), message: "highlight-fill is settable")

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Highlight color

Factory highlight color:

#board(test-fen, size: 4cm, labels: false, highlight: ("e4", "e5", "c4"))

#set-board-defaults(highlight-fill: rgb(220, 60, 60, 120))

After `set-board-defaults(highlight-fill: red-ish)` — subsequent boards inherit:

#grid(columns: 2, column-gutter: 14pt,
  board(test-fen, size: 4cm, labels: false, highlight: ("e4", "e5", "c4")),
  // per-call override still wins:
  board(test-fen, size: 4cm, labels: false, highlight: ("e4", "e5", "c4"),
    highlight-fill: rgb(60, 90, 220, 120)),
)
