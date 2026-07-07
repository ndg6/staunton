// EXPECT: no glyph for piece kind
// The glyph fallback covers only the standard six unless the variant supplies a
// glyph. This fairy variant supplies NONE, so drawing it with `piece-set:
// "unicode"` must fail with a message pointing at `glyphs:` / an SVG piece-set.
#import "/lib.typ": board, position

#let fairy = (extends: "standard", kinds: ("alfil",), abbr: (a: "alfil"))
#board(position((a1: "A"), variant: fairy), piece-set: "unicode")
