// EXPECT: border-theme must be one of ("square", "brown", "creme", "dark", "light")
// board() - an invalid `border-theme` name must be rejected with a message
// naming all five valid values, not silently ignored or misrendered.
#import "/lib.typ": board
#board((:), label-mode: "border", border-theme: "purple")
