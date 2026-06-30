// EXPECT: a NAG must be
// with-nags rejects a value that is neither "$n" nor one of the six glyphs.
#import "/lib.typ": parse-pgn, with-nags
#let g = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 *").first()
#let _ = with-nags(g, ("1w": "?!?"))
