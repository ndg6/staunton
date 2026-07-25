// EXPECT: color-theme must be a built-in name (string) or a dict from `color-theme(..)`; got int
// board() - a `color-theme:` value that is neither a built-in name (string) nor
// a `color-theme(..)` dict must be rejected with a clear type error.
#import "/lib.typ": board
#board((:), color-theme: 42)
