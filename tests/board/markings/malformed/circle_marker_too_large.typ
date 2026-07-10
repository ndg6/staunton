// EXPECT: circle-width + circle-margin exceed the square
// A circle whose stroke plus margin leave no room for a positive radius is a hard
// error (rather than silently drawing nothing / an inverted ring).
#import "/lib.typ": board

#board(
  "8/8/8/3p4/8/8/8/8 w - - 0 1",
  size: 3cm,
  highlight: ((square: "d5", shape: "circle"),),
  circle-width: 80%,
  circle-margin: 20%,
)
