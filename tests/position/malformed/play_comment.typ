// EXPECT: comments, NAGs and variations are not supported
// play takes flat move text (SAN + move numbers + result).
// Comments / NAGs / variations are rejected here; use game()/games() for full PGN.
#import "/lib.typ": play
#let _ = play(none, "1. e4 e5 {a comment} 2. Nf3")
