// EXPECT: unknown option
// A typo'd named option (here `show-variations` for `variations`) must be
// rejected, not silently ignored -- otherwise the intended effect never happens.
#import "/lib.typ": game, notation
#let g = game("[White \"A\"][Black \"B\"] 1. e4 e5 *")
#notation(g, show-variations: true)
