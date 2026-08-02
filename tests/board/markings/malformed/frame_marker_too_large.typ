// EXPECT: frame-width + frame-margin exceed the square
// A frame whose stroke plus margin leave no room for a positive inner side is a
// hard error (rather than silently drawing nothing / an inverted shape).
#import "/lib.typ": board

#board(
  "8/8/8/3p4/8/8/8/8 w - - 0 1",
  size: 3cm,
  highlight: ((square: "d5", shape: "frame"),),
  frame-width: 80%,
  frame-margin: 20%,
)
