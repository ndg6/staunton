// EXPECT: `from` locator out of range
// A `from` locator past the last move of the line is rejected.
#import "/lib.typ": notation, game
#let g = game("[White \"A\"][Black \"B\"] 1. e4 e5 *")
// only two plies exist; "9w" is far past the end. The range check lives in a
// `context` (lang: auto), so the call must be REALIZED in the body to fire it.
#notation(g, from: "9w")
