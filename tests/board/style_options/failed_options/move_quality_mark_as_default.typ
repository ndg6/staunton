// EXPECT: cannot be a document default
// `move-quality-mark` is tied to one specific move; it is derived from the drawn
// position's own game provenance (prompt 49), never a document default (and never
// per-call on a bare board).
#import "/lib.typ": set-board-defaults
#set-board-defaults(move-quality-mark: (square: "e4", symbol: "!"))
