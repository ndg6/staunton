// (board flipping) - flip is a per-diagram argument (never a document
// default; see failed_options/flip_as_default.typ). White at the bottom by
// default; flip: true puts Black at the bottom, and labels/pieces/marks move with
// it.
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

= Highlights & arrows flip with the board

The SAME highlights and arrows, drawn on the default and the flipped board. Check:
- each highlight stays on its NAMED square (filled `e4`, circle `e5`, cross `d5`) —
  it just moves to the mirrored screen position;
- each arrow still connects the same two squares with its TIP at the destination,
  so its on-screen direction flips. In particular the vertical `e2→e4` arrow points
  *up* the screen by default and *down* when flipped, while still running e2→e4;
- the knight `f3→e5` and bishop `c4→f7` arrows keep pointing at e5 / f7 either way.

#let marks = (
  highlight: (
    (square: "e4", shape: "filled"),
    (square: "e5", shape: "circle"),
    (square: "d5", shape: "cross"),   // empty square
  ),
  arrows: (
    ("e2", "e4", rgb(30, 90, 200)),   // vertical (blue) — direction reverses on flip
    ("f3", "e5"),                      // knight, asymmetric
    ("c4", "f7"),                      // bishop diagonal
  ),
)

#grid(
  columns: 2,
  column-gutter: 18pt,
  stack(dir: ttb, spacing: 6pt, align(center, strong[default]),
    board(test-fen, size: 5cm, ..marks)),
  stack(dir: ttb, spacing: 6pt, align(center, strong[flip: true]),
    board(test-fen, size: 5cm, flip: true, ..marks)),
)
