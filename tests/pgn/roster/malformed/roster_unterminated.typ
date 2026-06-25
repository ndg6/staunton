// EXPECT: unterminated tag
// A tag bracket that is never closed.
#import "/src/pgn.typ": parse-pgn
#let _ = parse-pgn("[Event \"Paris\"
1. e4 e5 *")
