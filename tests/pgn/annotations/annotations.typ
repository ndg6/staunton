// §item 8 / prompt 15 - PGN drawing annotations. `{[%cal ...]}` becomes arrows
// and `{[%csl ...]}` becomes highlights on the diagram for that move; the color
// letters (G/R/Y/B/O) resolve through the board's stylable `annotation-colors`.
// Processing is OFF by default (prompt 15): opt in with `annotations: true` per
// call or `set-pgn-defaults(annotations: true)` document-wide.
#import "/lib.typ": parse-pgn, board-after, move-node, set-board-defaults, set-pgn-defaults

#set page(width: 13cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let game = parse-pgn(```
[White "Arrows"] [Black "Highlights"]
1. e4 e5 2. Nf3 {[%cal Gf3e5,Bf1c4] [%csl Re5,Yc6]} Nc6 *
```).first()

// The annotation survives parsing in the move's trailing comment.
#let node = move-node(game, "2w")
#assert(node.comment-after != none, message: "comment-after should hold the annotation")
#assert(node.comment-after.contains("%cal"), message: "comment should contain %cal")

= PGN annotations

Default (annotations OFF): no arrows/highlights even though the comment has them:
#board-after(game, "2w", size: 6cm) <plain>

Opt in per call with `annotations: true` — green f3→e5, blue f1→c4; red e5,
yellow c6:
#board-after(game, "2w", size: 6cm, annotations: true)

Document-wide via `set-pgn-defaults(annotations: true)`; re-themed via
`set-board-defaults(annotation-colors: ...)` so "G" renders purple:
#set-pgn-defaults(annotations: true)
#set-board-defaults(annotation-colors: (G: purple, R: red, Y: olive, B: blue, O: orange))
#board-after(game, "2w", size: 6cm)

// board-after figures stay referenceable (the pgn gate lives in the figure body):
See @plain.
