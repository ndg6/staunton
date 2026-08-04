// EXPECT: overflows 8 files
// 4.3 - within one "/" section, pieces + empty counts must add up to 8. Here the
// first rank lists 9 pieces, overflowing the 8 files.
#import "/lib.typ": position
#let _ = position("rnbqkbnrr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
