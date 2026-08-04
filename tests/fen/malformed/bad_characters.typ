// EXPECT: invalid FEN piece letter
// 4.2 - placement characters must come from the set b/p/n/k/q/r (either case)
// or the digits 1-8. Here an "x" appears in the back rank, which is rejected.
#import "/lib.typ": position
#let _ = position("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBxR w KQkq - 0 1")
