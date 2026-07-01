// EXPECT: no variation #
// A path locator into a variation index that doesn't exist is a hard error.
#import "/lib.typ": parse-pgn, with-comments
#let g = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 (1. d4) e5 *").first()
// only variation #0 exists at 1w
#let _ = with-comments(g, (((line: ((at: "1w", into: 5),), at: "1w"), "x"),))
