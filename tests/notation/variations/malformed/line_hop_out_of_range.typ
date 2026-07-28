// EXPECT: `line:` hop out of range
// A `line:` hop addressing a move past the end of its line is a hard error.
#import "/lib.typ": parse-pgn, notation
#let g = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 (1. d4) e5 *").first()
// the mainline has only two plies; "9w" is far past the end
#notation(g, line: ((at: "9w", into: 0),))
