// EXPECT: cross-margin (plus stroke) too large for the square
// A cross margin of >= 50% of the square leaves no span for the diagonals; hard
// error rather than a degenerate / inverted cross.
#import "/lib.typ": board

#board(
  "8/8/8/3p4/8/8/8/8 w - - 0 1",
  size: 3cm,
  highlight: ((square: "d5", shape: "cross"),),
  cross-margin: 60%,
)
