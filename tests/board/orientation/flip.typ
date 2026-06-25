// §2 (board flipping) - flip is a per-diagram argument (never a document
// default; see failed_options/flip_as_default.typ). White at the bottom by
// default; flip: true puts Black at the bottom, and labels/pieces move with it.
#import "/lib.typ": board
#import "/tests/board/_fixture.typ": test-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Orientation (flip)

#grid(
  columns: 2,
  column-gutter: 18pt,
  stack(dir: ttb, spacing: 6pt, align(center, strong[default (White at bottom)]),
    board(test-fen, size: 5cm)),
  stack(dir: ttb, spacing: 6pt, align(center, strong[flip: true (Black at bottom)]),
    board(test-fen, size: 5cm, flip: true)),
)
