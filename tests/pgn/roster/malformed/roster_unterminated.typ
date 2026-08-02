// EXPECT: unterminated tag
// A tag bracket that is never closed.
#import "/src/pgn.typ": game
#let _ = game("[Event \"Paris\"
1. e4 e5 *")
