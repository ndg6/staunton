// PGN drawing annotations. `{[%cal ...]}` becomes arrows
// and `{[%csl ...]}` becomes highlights on the diagram for that move; the color
// letters (G/R/Y/B/O) resolve through the board's stylable `annotation-colors`.
// Processing is OFF by default: opt in with `annotations: true` per
// call or `set-pgn-defaults(annotations: true)` document-wide.
#import "/lib.typ": game, diagram, set-board-defaults, set-pgn-defaults
// `move-node` is the internal tree accessor (not public API since 2.0.0 -- the
// public one is `move-at`); tests may reach into src/ directly.
#import "/src/game.typ": move-node

#set page(width: 13cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let g = game(```
[White "Arrows"] [Black "Highlights"]
1. e4 e5 2. Nf3 {[%cal Gf3e5,Bf1c4] [%csl Re5,Yc6]} Nc6 *
```)

// The annotation survives parsing in the move's trailing comment.
#let node = move-node(g, at: "2w")
#assert(node.comment-after != none, message: "comment-after should hold the annotation")
#assert(node.comment-after.contains("%cal"), message: "comment should contain %cal")

= PGN annotations

Default (annotations OFF): no arrows/highlights even though the comment has them:
#diagram(g, at: "2w", size: 6cm) <plain>

Opt in per call with `annotations: true` — green f3→e5, blue f1→c4; red e5,
yellow c6:
#diagram(g, at: "2w", size: 6cm, annotations: true)

Document-wide via `set-pgn-defaults(annotations: true)`; re-themed via
`set-board-defaults(annotation-colors: ...)` so "G" renders purple:
#set-pgn-defaults(annotations: true)
#set-board-defaults(annotation-colors: (G: purple, R: red, Y: olive, B: blue, O: orange))
#diagram(g, at: "2w", size: 6cm)

// diagram(.., at: ..) figures stay referenceable (the pgn gate lives in the figure body):
See @plain.
