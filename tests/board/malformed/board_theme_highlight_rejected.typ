// EXPECT: `highlight` is position-specific and cannot be a document default
// board-theme() - the position-specific keys (`highlight`, `arrows`,
// `move-quality-mark`) make no sense baked into a reusable "look", so they must
// be rejected the same way `set-board-defaults(highlight: ..)` already is.
#import "/lib.typ": board-theme
#board-theme(highlight: ("e4",))
