// EXPECT: marker dimension must be `auto`, a ratio
// A marker stroke width / margin must be `auto`, a ratio, or a length. A bare
// string is rejected by `_resolve-square-dim` when the cross is drawn.
#import "/lib.typ": board

#board(
  "8/8/8/3p4/8/8/8/8 w - - 0 1",
  size: 3cm,
  highlight: ((square: "d5", shape: "cross"),),
  cross-width: "thick",
)
