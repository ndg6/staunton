// EXPECT: a NAG must be
// with-nags rejects a value that is neither "$n" nor one of the six glyphs.
#import "/lib.typ": game, with-nags
#let g = game("[White \"A\"][Black \"B\"] 1. e4 e5 *")
#let _ = with-nags(g, nags: ("1w": "?!?"))
