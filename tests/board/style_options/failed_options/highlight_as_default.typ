// EXPECT: cannot be a document default
// `highlight` is position-specific (different squares for every diagram), so it is
// a per-CALL board argument only -- the defaults setters reject it.
#import "/lib.typ": set-board-defaults
#set-board-defaults(highlight: ("e4",))
