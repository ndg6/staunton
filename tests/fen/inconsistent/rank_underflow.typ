// EXPECT: does not fill 8 files
// 4.3 - the dual of overflow: a "/" section whose pieces + empties add up to
// fewer than 8. Here the first rank has only 7 pieces and no empties.
#import "/lib.typ": position
#let _ = position("rnbqkbn/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
