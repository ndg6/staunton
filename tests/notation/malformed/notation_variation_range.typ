// EXPECT: variation-line ranges are not supported
// §prompt 14 - v1 ranges are mainline-only; a path locator is rejected.
#import "/lib.typ": notation, parse-pgn
#let g = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 *").first()
#let _ = notation(g, from: (line: ((at: "1w", into: 0),), at: "1b"))
