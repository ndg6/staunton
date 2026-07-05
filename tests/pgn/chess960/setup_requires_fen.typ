// EXPECT: SetUp
// PGN [SetUp "1"] declares a custom start position, so a [FEN] tag is required.
// A SetUp-without-FEN game is malformed and must error when its start is resolved.
#import "/lib.typ": parse-pgn, game-start

#let g = parse-pgn("[Variant \"Chess960\"][SetUp \"1\"] 1. e4 e5 *").first()
#let _ = game-start(g)
