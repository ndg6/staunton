// EXPECT: unknown color theme option: "bogus" (expected one of ("light", "dark"))
// board() - the RAW-DICT bypass: a hand-rolled dict passed directly as
// `color-theme: (..)` (NOT built via the `color-theme(..)` constructor, which
// would have caught this before it ever reached here) must still be validated at
// RESOLVE time. Before this guard existed, an unknown key like `bogus` landed
// straight in the style state. Do not "simplify" this to a `color-theme(..)`
// call -- that would defeat the whole point of this test.
#import "/lib.typ": board
#board((:), color-theme: (bogus: 1))
