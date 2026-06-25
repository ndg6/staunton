// §2.4 - the Unicode glyph fallback (piece-set: "unicode" or none). The solid
// glyphs are used for both colours, distinguished by fill + a contrasting
// stroke; the white-fill / black-fill style fields apply ONLY to this fallback.
#import "/lib.typ": board
#import "/tests/board/_fixture.typ": test-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Unicode glyph fallback

#grid(
  columns: 2,
  gutter: 16pt,
  stack(dir: ttb, spacing: 6pt, align(center, strong[piece-set: "unicode"]),
    board(test-fen, piece-set: "unicode", size: 5cm, labels: false)),
  stack(dir: ttb, spacing: 6pt, align(center, strong[recoloured white-fill/black-fill]),
    board(test-fen, piece-set: "unicode", size: 5cm, labels: false,
      white-fill: rgb("#f5e6c8"), black-fill: rgb("#5a3a1a"))),
)
