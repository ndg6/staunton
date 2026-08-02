// EXPECT: no variation #
// `line:` into a variation index that doesn't exist at that move is a hard error.
#import "/lib.typ": game, notation
#let g = game("[White \"A\"][Black \"B\"] 1. e4 (1. d4) e5 *")
// only variation #0 exists at 1w
#notation(g, line: ((at: "1w", into: 5),))
