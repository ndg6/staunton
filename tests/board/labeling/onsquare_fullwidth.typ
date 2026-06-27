// §item 1 / labeling - on-square labels at a near-page-width board, so the
// corner labels are large enough to judge their size, corner offset, and the
// opposite-colour contrast. On-square labels keep a fixed font fraction at every
// size (prompt 12, item 2: no automatic switch to "border" at small sizes).
#import "/lib.typ": board
#import "/tests/board/_fixture.typ": test-fen

#set page(width: 18cm, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

= On-square labeling at (almost) full page width

File letters bottom-left, rank digits top-right (the default corners), each in
the opposite color of its square -- drawn directly on the board:

#board(test-fen, size: 16cm, label-mode: "on-square")

#pagebreak()

= Same, flipped (Black's view)

Labels move with the flip and stay on the outer display edges:

#board(test-fen, size: 16cm, label-mode: "on-square", flip: true)
