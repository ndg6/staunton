// the optional grid line between squares. `grid: false` by default;
// when true, a fixed 1pt black line sits on every internal square boundary, at
// any board size. Compare on/off, and check the default is off.
#import "/lib.typ": board, default-board-style
#import "/tests/board/_fixture.typ": test-fen

#assert(default-board-style.grid == false, message: "grid must default to false")

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Grid lines

#grid(
  columns: 2,
  column-gutter: 16pt,
  stack(dir: ttb, spacing: 6pt, align(center, strong[grid: false (default)]),
    board(test-fen, size: 5cm, grid: false, labels: false)),
  stack(dir: ttb, spacing: 6pt, align(center, strong[grid: true]),
    board(test-fen, size: 5cm, grid: true, labels: false)),
)

#v(8pt)
Grid stays 1pt at small and large sizes:

#grid(columns: 3, column-gutter: 10pt, align: bottom + center,
  board(test-fen, size: 2cm, grid: true, labels: false),
  board(test-fen, size: 3.5cm, grid: true, labels: false),
  board(test-fen, size: 6cm, grid: true, labels: false),
)
