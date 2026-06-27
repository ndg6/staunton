// EXPECT: comments, NAGs and variations are not supported
// §prompt 13 - play-moves takes flat move text (SAN + move numbers + result).
// Comments / NAGs / variations are rejected here; use parse-pgn for full PGN.
#import "/lib.typ": play-moves
#let _ = play-moves(none, "1. e4 e5 {a comment} 2. Nf3")
