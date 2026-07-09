// EXPECT: cannot be a document default
// `move-quality-mark` is tied to one specific move; it is derived and injected by
// `diagram-after`, never a document default (and never per-call on a bare board).
#import "/lib.typ": set-board-defaults
#set-board-defaults(move-quality-mark: (square: "e4", symbol: "!"))
