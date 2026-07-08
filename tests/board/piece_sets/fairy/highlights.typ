// Fairy chess -- highlights (fill / cross / circle) must work with custom pieces
// exactly as with standard ones. Highlights are drawn by SQUARE, under the pieces,
// with no dependence on piece kind, so a fairy piece takes a filled/circled
// highlight and an empty square takes a cross just like standard chess.
//
// Asserting test: the board renders all 4 pieces (2 standard + 2 fairy) with the
// four highlights present -- a piece dropped by a highlight interaction would
// change the count. Visual correctness (fill under the piece, cross on the empty
// square, circle around the piece) is a VISUAL_CHECKS item.
#import "/lib.typ": board, position, named-piece-set, with-fallback

#set page(width: auto, height: auto, margin: 1cm)

#let fairy = (
  extends: "standard",
  kinds: ("alfil", "dabbaba", "ferz"),
  abbr: (a: "alfil", d: "dabbaba", f: "ferz"),
)
#let art = with-fallback(named-piece-set(
  f => read("/tests/board/piece_sets/_fairy_assets/" + f, encoding: none),
))

#board(
  position((e1: "K", e8: "k", a1: "A", d4: "d"), variant: fairy),
  piece-set: art,
  highlight: (
    "a1",                               // filled, under the alfil
    "e1",                               // filled, under the standard king
    (square: "d4", shape: "circle"),    // circle around the dabbaba
    (square: "f5", shape: "cross"),     // cross on an empty square
  ),
  size: 5cm,
)

#context assert(
  query(image).len() == 4,
  message: "expected 4 rendered pieces under highlights, got " + str(query(image).len()),
)
