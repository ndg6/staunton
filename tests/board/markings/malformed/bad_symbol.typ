// EXPECT: move-quality symbol must be one of
// A move-quality-mark with an unrecognised symbol is a hard error (only the six
// assessment glyphs ! ? !! ?? !? ?! are valid).
#import "/lib.typ": board

#board(
  "4k3/8/8/8/8/8/8/4K3 w - - 0 1",
  move-quality: true,
  move-quality-mark: (square: "e4", symbol: "?!?"),
)
