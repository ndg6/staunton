// EXPECT: an arrow entry's `fade:` must be `none` or a ratio in (0%, 100%]; got 150%
// board() -- an invalid per-entry `fade:` override must be blamed on the
// ENTRY's `fade:`, not the board-level `arrow-fade`, same reasoning as the
// `tip:` case in arrow_entry_tip_invalid.typ.
#import "/lib.typ": board
#board((:), arrows: ((from: "e2", to: "e4", fade: 150%),))
