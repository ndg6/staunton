// EXPECT: a game needs a locator
// to-fen on a game requires a locator to pick the position.
#import "/lib.typ": to-fen, game
#let g = game("[White \"A\"][Black \"B\"] 1. e4 e5 *")
#let _ = to-fen(g)
