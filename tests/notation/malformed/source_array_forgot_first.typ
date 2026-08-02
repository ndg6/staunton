// EXPECT: did you forget `.first()`
// games() returns an ARRAY of games; passing it (instead of `.first()` or
// `game()`) as the notation source must give a clear, targeted error -- not
// crash deep inside the SAN localizer with "dictionary has no method `clusters`".
#import "/lib.typ": games, notation
#let gs = games("[White \"A\"][Black \"B\"] 1. e4 e5 *")
#notation(gs, variations: true)
