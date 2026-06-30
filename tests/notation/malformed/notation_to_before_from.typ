// EXPECT: `to` locator out of range, or before `from`
// A `to` locator earlier than `from` is rejected (empty/inverted slice).
#import "/lib.typ": notation, parse-pgn
#let g = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 *").first()
// from 2w (ply 3) but to 1b (ply 2): the slice would run backwards. The range
// check is in a `context` (lang: auto), so realize the call in the body.
#notation(g, from: "2w", to: "1b")
