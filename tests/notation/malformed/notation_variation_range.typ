// EXPECT: variation-line ranges are not supported
// v1 ranges are mainline-only; a path locator is rejected.
#import "/lib.typ": notation, game
#let g = game("[White \"A\"][Black \"B\"] 1. e4 e5 *")
#let _ = notation(g, from: (line: ((at: "1w", into: 0),), at: "1b"))
