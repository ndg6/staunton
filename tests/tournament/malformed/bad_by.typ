// EXPECT: must be "player" or "team"
// standings validates the `by` entity mode.
#import "/lib.typ": games, standings
#let g = games("[White \"A\"][Black \"B\"][Result \"1-0\"] 1-0")
#let _ = standings(g, by: "country")
