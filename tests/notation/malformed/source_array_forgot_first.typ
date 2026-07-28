// EXPECT: did you forget `.first()`
// parse-pgn returns an ARRAY of games; passing it (instead of `.first()`) as the
// notation source must give a clear, targeted error -- not crash deep inside the
// SAN localizer with "dictionary has no method `clusters`".
#import "/lib.typ": parse-pgn, notation
#let games = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 *")
#notation(games, variations: true)
