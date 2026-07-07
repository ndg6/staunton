// EXPECT: no built-in glyph for piece kind
// The Unicode glyph fallback only covers the standard six. Asking to draw a fairy
// kind with `piece-set: "unicode"` must fail with a message pointing at a loader.
#import "/lib.typ": board, position

#let fairy = (extends: "standard", kinds: ("alfil",), abbr: (a: "alfil"))
#board(position((a1: "A"), variant: fairy), piece-set: "unicode")
