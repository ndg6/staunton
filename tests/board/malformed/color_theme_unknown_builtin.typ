// EXPECT: unknown built-in color theme: "nonexistent" (expected one of ("staunton-default", "dutch-gray"))
// board() - an unknown built-in `color-theme:` NAME must be rejected with a
// message listing the exact valid names, not silently ignored or misrendered.
#import "/lib.typ": board
#board((:), color-theme: "nonexistent")
