// EXPECT: rectangular
// position - the string form supports rectangular boards only: every row must
// have the same number of columns.
#import "/lib.typ": position
#let _ = position("....", "...")   // 4 vs 3 columns
