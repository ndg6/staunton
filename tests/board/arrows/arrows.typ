// arrows. `arrows` is a board-style key; each entry is a dict
// (from:, to:, color:) or a tuple ("from","to") / ("from","to", color). A
// missing color uses the settable `arrow-color` default. Arrows flip with the
// board and scale with the square.
#import "/lib.typ": board, default-board-style, set-board-defaults
#import "/tests/board/_fixture.typ": test-fen

#assert(default-board-style.keys().contains("arrows"), message: "arrows is a board key")
#assert(default-board-style.arrows == (), message: "no arrows by default")
// width settable (auto -> proportional), transparency 35% (thin lines stay
// clearly visible), and the default arrow color is the same base as the default
// highlight fill.
#assert(default-board-style.arrow-width == auto, message: "arrow-width auto by default")
#assert(default-board-style.arrow-transparency == 35%, message: "arrow transparency 35%")
#assert(default-board-style.arrow-color == default-board-style.highlight-fill, message: "arrow color defaults to the highlight base")

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Arrows

Tuple and dict forms, default and explicit colors:

#board(test-fen, size: 5cm, labels: false, arrows: (
  ("e2", "e4"),                                   // tuple, default color
  ("g1", "f3", rgb(0, 70, 160, 200)),             // tuple, explicit blue
  (from: "f1", to: "c4", color: rgb(136, 32, 32, 200)), // dict, red
))

#v(8pt)
Arrows follow a flip (same arrows, Black's view):

#grid(columns: 2, column-gutter: 16pt,
  board(test-fen, size: 4cm, labels: false, arrows: (("e2", "e4"), ("b8", "c6"))),
  board(test-fen, size: 4cm, labels: false, flip: true, arrows: (("e2", "e4"), ("b8", "c6"))),
)

#v(8pt)
Document-default arrow color via `set-board-defaults`:

#set-board-defaults(arrow-color: rgb(224, 110, 0, 220))
#board(test-fen, size: 4cm, labels: false, arrows: (("d2", "d4"), ("c1", "g5")))

#v(8pt)
Settable shaft width (`arrow-width`): auto (proportional) vs a fixed 8pt:

#grid(columns: 2, column-gutter: 16pt,
  board(test-fen, size: 4cm, labels: false, arrows: (("e2", "e4"), ("g1", "f3"))),
  board(test-fen, size: 4cm, labels: false, arrow-width: 8pt, arrows: (("e2", "e4"), ("g1", "f3"))),
)
