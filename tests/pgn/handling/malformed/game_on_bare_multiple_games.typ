// EXPECT: input contains 2 games; use games()
// Companion to game_on_multiple_games.typ (which uses rosters to separate the
// two games): bare movetext, separated only by the two result tokens, must
// ALSO trip game()'s multi-game guard. Before the split-on-result change this
// silently returned one truncated game instead of erroring.
#import "/lib.typ": game
#let _ = game("1. e4 e5 *\n\n1. d4 d5 *")
