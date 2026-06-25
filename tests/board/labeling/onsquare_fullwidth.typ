// §item 1 / labeling - on-square labels ACTUALLY rendered. The on-square ->
// border auto-fallback triggers when corner labels would drop to <= 4pt, which
// (at label fraction 0.22) happens below a board size of ~5.2cm. The other
// labeling tests use small boards, so they all fall back to "border"; this test
// uses a near-page-width board so the on-square corner labels render on the
// board itself. Look here to judge the on-square label size and corner offset.
#import "/lib.typ": board
#import "/tests/board/_fixture.typ": test-fen

#set page(width: 18cm, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

= On-square labeling at (almost) full page width

File letters bottom-left, rank digits top-right, each in the opposite color of
its square -- drawn directly on the board (no fallback at this size):

#board(test-fen, size: 16cm, label-mode: "on-square")

#pagebreak()

= Same, flipped (Black's view)

Labels move with the flip and stay on the outer display edges:

#board(test-fen, size: 16cm, label-mode: "on-square", flip: true)
