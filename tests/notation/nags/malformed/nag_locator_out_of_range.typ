// EXPECT: with-nags: locator out of range
// A locator past the last mainline move is rejected.
#import "/lib.typ": parse-pgn, with-nags
#let g = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 *").first()
// only two plies exist; "9w" is far past the end
#let _ = with-nags(g, ("9w": "!"))
