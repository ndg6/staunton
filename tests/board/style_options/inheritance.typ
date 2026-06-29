// Style options - set defaults once and confirm SUBSEQUENT diagrams inherit
// them, while a per-call argument still overrides. Reading order matters here
// (set-chess-defaults is document-order state, like Typst's own #set).
#import "/lib.typ": board, set-chess-defaults, set-piece-set
#import "/tests/board/_fixture.typ": test-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Document-wide style inheritance

*Before* any defaults are set — the factory tan theme, cburnett pieces:

#board(test-fen, size: 3.6cm, labels: false)

#set-chess-defaults(light: rgb("#eeeed2"), dark: rgb("#769656"), label-mode: "border")
#set-piece-set("merida")

*After* `set-chess-defaults(green, border)` + `set-piece-set("merida")` — every
later diagram inherits, with no per-call style:

#grid(columns: 2, column-gutter: 14pt,
  board(test-fen, size: 3.6cm),
  board(test-fen, size: 3.6cm, flip: true),
)

A per-call override still wins over the document default (here: back to cburnett
pieces and on-square labels for this one diagram only):

#board(test-fen, size: 3.6cm, piece-set: "cburnett", label-mode: "on-square")

…and the diagram after it falls back to the inherited defaults again:

#board(test-fen, size: 3.6cm)
