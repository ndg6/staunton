// EXPECT: past the end of its line
// with-variation `at` addressing a move past the end of its line is a hard error.
#import "/lib.typ": parse-pgn, with-variation
#let g = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 *").first()
#let _ = with-variation(g, at: "9w", moves: "d4 d5")
