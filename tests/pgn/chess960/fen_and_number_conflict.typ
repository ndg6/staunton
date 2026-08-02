// EXPECT: not both
// A Chess960 game must declare its start exactly one way: giving BOTH a [FEN] and
// a position-number tag ([FRCPosition]/[Chess960Position]) is rejected, since the
// two are redundant and could conflict.
#import "/lib.typ": game, game-start, chess960-start-fen

#let g = game(
  "[Variant \"Chess960\"][FRCPosition \"0\"][FEN \"" + chess960-start-fen(518) + "\"] *"
)
#let _ = game-start(g)
