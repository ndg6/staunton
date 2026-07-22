// EXPECT: rank out of range in "e9" (board has 8 ranks)
// board() - a bare squares dict (the documented `source` form that skips
// `position()`) must still validate its user-supplied keys through
// `parse-square`, the same as every other source form. An out-of-rank-range
// key must error, not silently misrender.
#import "/lib.typ": board
#board((e9: (kind: "king", color: "white")))
