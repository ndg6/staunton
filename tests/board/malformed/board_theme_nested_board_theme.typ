// EXPECT: a board-theme cannot contain another board-theme; compose with `color-theme` instead
// board-theme() - a board-theme is flat by contract: it may reference a
// `color-theme`, but nesting another `board-theme` inside it (recursion) must
// be rejected.
#import "/lib.typ": board-theme
#board-theme(board-theme: "dutch-gray", size: 3cm)
