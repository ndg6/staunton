// every bundled piece set, same position, side by side, so the sets can
// be compared and a broken/missing piece in any of them would show up.
#import "/lib.typ": board, known-piece-sets
#import "/tests/board/_fixture.typ": test-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Bundled piece sets (#known-piece-sets.len())

#grid(
  columns: 3,
  gutter: 12pt,
  ..known-piece-sets.map(name => stack(
    dir: ttb,
    spacing: 6pt,
    align(center, strong(name)),
    board(test-fen, piece-set: name, size: 4cm, labels: false),
  )),
)
