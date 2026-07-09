// the Unicode glyph fallback (piece-set: "unicode" or none). The solid
// glyphs are used for both colors, distinguished by fill + a contrasting
// stroke; the white-fill / black-fill style fields apply ONLY to this fallback.
#import "/lib.typ": board, default-board-style
#import "/tests/board/_fixture.typ": test-fen

// The glyph-fallback font default names only Typst's always-embedded
// "DejaVu Sans Mono" so a stock install never warns "unknown font family"; the
// piece renderer sets `fallback: true`, so the chess glyphs still resolve from a
// system symbol font. Override with the `piece-font` board option.
#assert(default-board-style.piece-font == ("DejaVu Sans Mono",), message: "default piece-font is the embedded mono only")

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Unicode glyph fallback

#grid(
  columns: 2,
  gutter: 16pt,
  stack(dir: ttb, spacing: 6pt, align(center, strong[piece-set: "unicode"]),
    board(test-fen, piece-set: "unicode", size: 5cm, labels: false)),
  stack(dir: ttb, spacing: 6pt, align(center, strong[recolored white-fill/black-fill]),
    board(test-fen, piece-set: "unicode", size: 5cm, labels: false,
      white-fill: rgb("#f5e6c8"), black-fill: rgb("#5a3a1a"))),
)
