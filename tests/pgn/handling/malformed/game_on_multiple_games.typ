// EXPECT: input contains 2 games; use games()
// `game()` returns ONE game and must REFUSE input holding more than one --
// silently taking the first is the surprise 2.0.0 exists to remove, and it
// would hand back a different game than the caller is looking at. The message
// must name `games()` as the remedy.
#import "/lib.typ": game
#let _ = game("[White \"A\"][Black \"B\"] 1. e4 *

[White \"C\"][Black \"D\"] 1. d4 *")
