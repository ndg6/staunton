// EXPECT: past the end of its line
// Annotating a move past the end of its line is a hard error.
#import "/lib.typ": game, with-nags
#let g = game("[White \"A\"][Black \"B\"] 1. e4 e5 *")
// only two mainline plies; "9w" is far past the end
#let _ = with-nags(g, ("9w": "!"))
