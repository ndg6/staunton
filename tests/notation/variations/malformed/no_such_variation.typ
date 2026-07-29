// EXPECT: no variation #
// `line:` into a variation index that doesn't exist at that move is a hard error.
#import "/lib.typ": parse-pgn, notation
#let g = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 (1. d4) e5 *").first()
// only variation #0 exists at 1w
#notation(g, line: ((at: "1w", into: 5),))
