// EXPECT: last-move must be one of (none, "arrow", "squares")
// board() -- an invalid `last-move` value must be rejected with a message
// naming all three accepted values, not silently ignored or misrendered.
#import "/lib.typ": board
#board((:), last-move: "circle")
