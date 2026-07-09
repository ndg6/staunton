// EXPECT: cannot be a document default
// `arrows` is position-specific, so it is a per-CALL board argument only -- the
// umbrella setter (like set-board-defaults) rejects it.
#import "/lib.typ": set-chess-defaults
#set-chess-defaults(arrows: (("e2", "e4"),))
