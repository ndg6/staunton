// EXPECT: has no file for custom kind
// A bundled-set NAME can only serve the standard six (its files are named by the
// fixed six-kind letter map). Drawing a fairy kind through a set name must fail
// and point the user at a loader / with-fallback.
#import "/lib.typ": board, position

#let fairy = (extends: "standard", kinds: ("alfil",), abbr: (a: "alfil"))
#board(position((a1: "A"), variant: fairy), piece-set: "cburnett")
