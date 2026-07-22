// EXPECT: unknown built-in board theme: "nonexistent" (expected one of ("staunton-default", "dutch-gray"))
// board() - an unknown built-in `board-theme:` NAME must be rejected with a
// message listing the exact valid names, not silently ignored or misrendered.
#import "/lib.typ": board
#board((:), board-theme: "nonexistent")
