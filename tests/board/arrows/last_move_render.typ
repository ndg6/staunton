// RENDER-ONLY sheet: `last-move` as actually drawn. The data half (which
// arrows/highlights it adds, and to which squares) is asserted in
// last_move.typ; color/placement/shape cannot be queried out of a rendered
// board, so they are eyeballed here (see VISUAL_CHECKS).
//
// Covers, in order: "arrow" form, "squares" form, a custom `last-move-color`,
// and the off-by-default case (a plain FEN carries no move, so no mark at all
// even with `last-move: "arrow"` set).
#import "/lib.typ": game, board, diagram

#set page(width: 15cm, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

#let g = game(```
[White "A"][Black "B"]
1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 *
```)

= `last-move: "arrow"`

An arrow from e5 to a6, drawn on top of the position after `3... a6`:

#board(g, at: "3b", last-move: "arrow", size: 4cm)

= `last-move: "squares"`

Both endpoints (e5, a6) highlighted instead of an arrow — no `shape` forced, so
the document's `highlight-shape` default (a filled square) applies:

#board(g, at: "3b", last-move: "squares", size: 4cm)

= Custom `last-move-color`

Same move, `last-move-color: green`:

#board(g, at: "3b", last-move: "arrow", last-move-color: green, size: 4cm)

= Through `diagram`

Same move, wrapped in a figure — the last-move arrow must appear identically
inside the board area:

#diagram(g, at: "3b", last-move: "arrow", size: 4cm)

= Off by default

Same game move, no `last-move` set: no arrow, no highlight.

#board(g, at: "3b", size: 4cm)
