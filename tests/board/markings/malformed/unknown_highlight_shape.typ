// EXPECT: highlight shape must be
// An unrecognized `shape:` is a hard error, not a silent no-op or a fallback to
// "filled". The expected message is a truncated leading phrase -- it enumerates
// the four legal shapes, and per GOTCHAS.md that enum grows over time, so
// matching the full text here would silently stop matching whenever it does.
#import "/lib.typ": board

#board(
  "8/8/8/3p4/8/8/8/8 w - - 0 1",
  size: 3cm,
  highlight: ((square: "d5", shape: "triangle"),),
)
