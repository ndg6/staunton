// EXPECT: arrow-tip must be one of ("triangle", "hook")
// board() -- an invalid `arrow-tip` name must be rejected with a message
// naming both accepted values, not silently ignored or misrendered.
#import "/lib.typ": board
#board((:), arrow-tip: "diamond")
