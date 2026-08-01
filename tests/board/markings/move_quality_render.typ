// RENDER-ONLY sheet: the move-quality badge as actually drawn. The data half is
// asserted in move_quality.typ; colours and placement cannot be queried out of a
// rendered board, so they are eyeballed here (see VISUAL_CHECKS).
//
// Covers, in order: all six symbols and their three colour categories; the same
// badge through `board` and through `diagram`; and the `move-quality` switch off.
#import "/lib.typ": parse-pgn, with-nags, board, diagram, position-after

#set page(width: 17cm, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

#let head = "[White \"a\"][Black \"b\"] "
// One move, annotated six ways. e4 is the destination in every case, so the badge
// must land on the SAME square each time and only the glyph/colour changes.
#let at-e4(sym) = position-after(with-nags(parse-pgn(head + "1. e4 e5 *").first(), ("1w": sym)), "1w")

= All six symbols (`board`, `move-quality: true`)

Good = `!` `!!`, bad = `?` `??`, interesting = `!?` `?!` — three colours, six glyphs,
all on *e4*.

#grid(columns: 6, gutter: 6pt,
  ..("!", "!!", "?", "??", "!?", "?!").map(s => [
    #align(center)[#raw(s)]
    #board(at-e4(s), move-quality: true, size: 2.4cm)
  ])
)

= The same badge through `diagram`

`diagram` adds only the figure wrapper — the badge must be identical to the
`board` above it, not merely similar.

#grid(columns: 2, gutter: 10pt,
  board(at-e4("!!"), move-quality: true, size: 3cm),
  diagram(at-e4("!!"), move-quality: true, size: 3cm, caption: none, game-info: none),
)

= The switch, off

Default is off: this board carries the same annotated move and must show *no*
badge at all.

#board(at-e4("??"), size: 3cm)

// (Recolouring via `move-quality-colors` is already eyeballed in markings.typ's
// move-quality section — not repeated here. Every render-only sheet costs human
// attention, so a second recolour would be a real cost for no new information.)
