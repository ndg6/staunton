// EXPECT: an arrow entry's `tip:` must be "triangle" or "hook"; got "hoock"
// board() -- an invalid per-entry `tip:` override must be blamed on the
// ENTRY's `tip:`, not on the board-level `arrow-tip` (a key this caller never
// wrote). That distinction is the whole point of validating per-entry
// overrides separately from `st.arrow-tip`.
#import "/lib.typ": board
#board((:), arrows: ((from: "e2", to: "e4", tip: "hoock"),))
