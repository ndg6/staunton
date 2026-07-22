// EXPECT: board flipping is per-diagram only; pass `flip: true` to a diagram, not to a defaults setter
// board-theme() - `flip` is a per-diagram concern, not a reusable "look", so it
// must be rejected the same way `set-board-defaults(flip: ..)` already is.
#import "/lib.typ": board-theme
#board-theme(flip: true)
