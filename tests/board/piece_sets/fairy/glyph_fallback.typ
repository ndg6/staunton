// Fairy chess -- USER-SUPPLIED glyph fallback. Unicode cannot foresee every fairy
// piece, so a custom variant carries its own `glyphs: (kind -> glyph)` map. With
// `piece-set: "unicode"` (no SVG loader), a fairy kind draws from that map while
// the standard kinds keep the built-in glyphs. The `glyphs` map is auto-seeded
// from the variant by `board` (no separate argument needed).
//
// Asserting test, two layers:
//  1. unit: `_resolve-glyph` precedence -- custom wins, built-in is the fallback,
//     a custom entry overrides a built-in one, and a missing glyph yields `none`.
//  2. integration: the board render below must COMPILE -- if the variant glyphs
//     did not auto-seed, `board` would panic exactly like the no-glyph case
//     (see bad_fairy/custom_kind_unicode). Glyph identity is a VISUAL_CHECKS item.
#import "/lib.typ": board, position
#import "/src/pieces.typ": _resolve-glyph, piece-glyphs

// 1. precedence (pure)
#assert(_resolve-glyph("alfil", (alfil: "✶")) == "✶", message: "custom glyph should win")
#assert(_resolve-glyph("king", (:)) == piece-glyphs.king, message: "built-in should be the fallback")
#assert(_resolve-glyph("king", (king: "✶")) == "✶", message: "custom should override a built-in")
#assert(_resolve-glyph("alfil", (:)) == none, message: "missing glyph should be none")

// 2. integration render (compiles => variant glyphs auto-seeded through board)
#set page(width: auto, height: auto, margin: 1cm)

#let fairy = (
  extends: "standard",
  kinds: ("alfil",),
  abbr: (a: "alfil"),
  glyphs: (alfil: "✶"),
)

#board(position((a1: "A", e1: "K"), variant: fairy), piece-set: "unicode", size: 4cm, labels: false)
