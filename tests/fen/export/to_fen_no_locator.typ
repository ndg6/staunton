// EXPECT: a game needs a locator
// §prompt 14 - to-fen on a game requires a locator to pick the position.
#import "/lib.typ": to-fen, parse-pgn
#let g = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 *").first()
#let _ = to-fen(g)
