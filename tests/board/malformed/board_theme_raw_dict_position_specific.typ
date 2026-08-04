// EXPECT: `arrows` is position-specific and cannot be a document default; pass `highlight` / `arrows` per call, and let `board`/`diagram`'s `at:` supply the move-quality badge
// set-board-defaults() - the RAW-DICT bypass: a hand-rolled dict passed directly
// as `board-theme: (..)` (NOT built via the `board-theme(..)` constructor, which
// would have caught this before it ever reached here) must still be validated at
// RESOLVE time. Before this guard existed, this silently injected a document-wide
// `arrows` entry that stamped the same arrow on every subsequent board. Do not
// "simplify" this to a `board-theme(..)` call -- that would defeat the whole
// point of this test, which is to catch a raw dict slipping past the
// constructor entirely.
#import "/lib.typ": set-board-defaults
#set-board-defaults(board-theme: (arrows: (("e2", "e4"),), light: red))
