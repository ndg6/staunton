// EXPECT: out of range
// A garbage move token ("Zz9") whose trailing chars are not a valid board square
// ("z9" is off an 8x8 board). Geometry-aware parse-square reports it as out of
// range.
#import "/src/pgn.typ": game
#import "/src/game.typ": position-after
#let g = game("1. Zz9 e5 *")
#let _ = position-after(g, "1w")
