// RENDER-ONLY sheet: the move-quality badge as actually drawn. The data half is
// asserted in move_quality.typ; colours and placement cannot be queried out of a
// rendered board, so they are eyeballed here (see VISUAL_CHECKS).
//
// Covers, in order: all six symbols and their three colour categories; the same
// badge through `board` and through `diagram`; and the `move-quality` switch off.
#import "/lib.typ": game, with-nags, board, diagram

#set page(width: 17cm, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

#let head = "[White \"a\"][Black \"b\"] "
// One move, annotated six ways. e4 is the destination in every case, so the badge
// must land on the SAME square each time and only the glyph/colour changes. The
// badge is now reachable ONLY by handing the game itself, plus `at:`, to `board`/
// `diagram` — a plain `position-after` position has no move to badge.
#let game-e4(sym) = with-nags(game(head + "1. e4 e5 *"), ("1w": sym))

= All six symbols (`board`, `move-quality: true`)

Good = `!` `!!`, bad = `?` `??`, interesting = `!?` `?!` — three colours, six glyphs,
all on *e4*.

#grid(columns: 6, gutter: 6pt,
  ..("!", "!!", "?", "??", "!?", "?!").map(s => [
    #align(center)[#raw(s)]
    #board(game-e4(s), at: "1w", move-quality: true, size: 2.4cm)
  ])
)

= The same badge through `diagram`

Same game move, both entry points. The *board area* must be identical — same `!!`
disc, same square, same colour. Everything around it is what `diagram` adds and
`board` does not: the roster line above, and a numbered, captioned figure below.

The right-hand side must be visibly a *figure*. If it is not — if both columns
look like bare boards — then this section is comparing `board` with `board` and
proves nothing, which is exactly how it was first written (`caption: none,
game-info: none` suppressed every visible sign of the diagram path).

#grid(columns: 2, gutter: 14pt, align: top + center,
  [
    `board(..)` — no wrapper
    #v(4pt)
    #board(game-e4("!!"), at: "1w", move-quality: true, size: 3cm)
  ],
  [
    `diagram(..)` — roster line + caption
    #v(4pt)
    #diagram(game-e4("!!"), at: "1w", move-quality: true, size: 3cm)
  ],
)

= The switch, off

Default is off: this board carries the same annotated move and must show *no*
badge at all.

#board(game-e4("??"), at: "1w", size: 3cm)

// (Recolouring via `move-quality-colors` is already eyeballed in markings.typ's
// move-quality section — not repeated here. Every render-only sheet costs human
// attention, so a second recolour would be a real cost for no new information.)
