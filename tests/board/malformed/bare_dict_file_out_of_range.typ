// EXPECT: file out of range in "i4" (board has 8 files)
// board() - a bare squares dict (the documented `source` form that skips
// `position()`) must still validate its user-supplied keys through
// `parse-square`, the same as every other source form. An out-of-file-range
// key must error, not silently misrender.
#import "/lib.typ": board
#board((i4: (kind: "king", color: "white")))
