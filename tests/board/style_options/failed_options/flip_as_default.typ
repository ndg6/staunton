// EXPECT: per-diagram only
// Board flipping cannot be a document default -- it must be set per diagram.
#import "/lib.typ": set-chess-defaults

#set-chess-defaults(flip: true)
