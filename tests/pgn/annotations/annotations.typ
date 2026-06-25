// §item 8 - PGN drawing annotations. `{[%cal ...]}` becomes arrows and
// `{[%csl ...]}` becomes highlights on the diagram for that move; the color
// letters (G/R/Y/B/O) resolve through the board's stylable `annotation-colors`.
// board-after applies them automatically (pgn-annotations: true by default).
#import "/lib.typ": parse-pgn, board-after, move-node, set-board-defaults

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

Auto-applied `%cal` (green f3→e5, blue f1→c4) and `%csl` (red e5, yellow c6):
#board-after(game, "2w", size: 6cm)

Suppressed with `pgn-annotations: false`:
#board-after(game, "2w", size: 6cm, pgn-annotations: false)

Re-themed via `set-board-defaults(annotation-colors: ...)` — "G" now renders
purple, so the green arrow becomes purple:
#set-board-defaults(annotation-colors: (
  G: purple, R: red, Y: olive, B: blue, O: orange,
))
#board-after(game, "2w", size: 6cm)
