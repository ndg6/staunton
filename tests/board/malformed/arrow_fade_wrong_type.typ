// EXPECT: arrow-fade must be `none` or a ratio in (0%, 100%]; got 0.3
// board() -- a board-level `arrow-fade` of the wrong TYPE (a bare float, not a
// ratio) must be rejected with a message naming `arrow-fade`. Before this
// guard, a float here died deep inside `_arrow-shape` with "cannot subtract
// float from ratio" -- true but useless, since it never named the key the
// caller actually got wrong.
#import "/lib.typ": board
#board((:), arrow-fade: 0.3)
