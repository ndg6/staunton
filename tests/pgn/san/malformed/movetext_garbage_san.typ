// EXPECT: invalid file
// A garbage move token ("Zz9") whose trailing two chars are not a valid square.
#import "/src/pgn.typ": parse-pgn
#import "/src/game.typ": position-after
#let g = parse-pgn("1. Zz9 e5 *").first()
#let _ = position-after(g, "1w")
