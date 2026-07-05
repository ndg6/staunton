// EXPECT: not both
// A Chess960 game must declare its start exactly one way: giving BOTH a [FEN] and
// a position-number tag ([FRCPosition]/[Chess960Position]) is rejected, since the
// two are redundant and could conflict.
#import "/lib.typ": parse-pgn, game-start, chess960-start-fen

#let g = parse-pgn(
  "[Variant \"Chess960\"][FRCPosition \"0\"][FEN \"" + chess960-start-fen(518) + "\"] *"
).first()
#let _ = game-start(g)
