// EXPECT: unknown color theme option: "base"
// board() - `base:` is a deliberate SCOPE LIMIT (prompt 38 section 15): it is
// only handled inside the `color-theme(..)` constructor function. A raw
// hand-rolled dict passed directly as `color-theme: (..)` (bypassing the
// constructor) must still be rejected for `base` -- do NOT "fix" this to
// resolve the base, that would defeat the whole point of this test.
#import "/lib.typ": board
#board((:), color-theme: (base: "dutch-gray"))
