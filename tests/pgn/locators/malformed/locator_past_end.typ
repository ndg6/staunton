// EXPECT: locator out of range: addressed move past end of line
// Addressing a move beyond the end of the (sub-)line is a hard error.
#import "/lib.typ": game, position-after
#let g = game("[White \"A\"][Black \"B\"] 1. e4 (1. d4 d5) e5 *")
// the 1.d4 variation has only 1...d5; asking for 3w runs past its end
#let _ = position-after(g, (line: ((at: "1w", into: 0),), at: "3w"))
