// Fairy chess -- render a MIXED board: standard king/pawn drawn from a bundled
// set, alfil/dabbaba/ferz drawn from a user-supplied custom set, through ONE
// `piece-set`. `with-fallback` routes the standard six to `base` (default
// cburnett) and every other kind to the custom loader; `named-piece-set` maps
// (color, kind) onto the fairy files' "{kind}_{color}.svg" layout.
//
// Asserting test: every one of the 6 placed pieces must render as an image (the
// standard ones as bundled-SVG bytes, the fairy ones from the fixture set), so a
// dropped/unresolved piece is caught. (Visual eyeballing of the glyphs is a
// VISUAL_CHECKS item.)
#import "/lib.typ": board, position, named-piece-set, with-fallback

#set page(width: auto, height: auto, margin: 1cm)

#let fairy = (
  extends: "standard",
  kinds: ("alfil", "dabbaba", "ferz"),
  abbr: (a: "alfil", d: "dabbaba", f: "ferz"),
)

// Fairy set follows "{kind}_{color}.svg"; standard kinds fall back to cburnett.
#let art = with-fallback(named-piece-set(
  f => read("/tests/board/piece_sets/_fairy_assets/" + f, encoding: none),
))

// 3 standard (K, P, k) + 3 fairy (A, d, F) = 6 pieces.
#board(
  position(
    (e1: "K", e2: "P", e8: "k", a1: "A", d4: "d", f6: "F"),
    variant: fairy,
  ),
  piece-set: art,
  size: 6cm,
)

#context assert(
  query(image).len() == 6,
  message: "expected 6 rendered piece images (3 standard + 3 fairy), got " + str(query(image).len()),
)
