// EXPECT: past the end of its line
// with-line `at` addressing a move past the end of its line is a hard error.
#import "/lib.typ": game, with-line
#let g = game("[White \"A\"][Black \"B\"] 1. e4 e5 *")
#let _ = with-line(g, at: "9w", moves: "d4 d5")
