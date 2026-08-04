// EXPECT: arrow-fade must be `none` or a ratio in (0%, 100%]; got 150%
// board() -- a board-level `arrow-fade` outside (0%, 100%] must be rejected.
// Before this guard, `100% - fade` fed straight into `.transparentize(..)`,
// which OPACIFIES on a negative argument -- `arrow-fade: 150%` silently
// INVERTED the fade (more opaque at the tail than the head) instead of
// erroring. `0%` is rejected too (the range is open at the bottom: this key's
// doc comment promises the shaft "never fully disappears"), but that is the
// same branch of the same assert, so it is not a separate fixture.
#import "/lib.typ": board
#board((:), arrow-fade: 150%)
