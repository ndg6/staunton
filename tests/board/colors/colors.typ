// Colors - different square / highlight colors. At least one LABELED board
// per mode so we can see how the label font colors are chosen against custom
// squares (on-square: opposite square color; border: light color on a darkened
// dark-square band).
#import "/lib.typ": board
#import "/tests/board/_fixture.typ": test-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

#let themes = (
  ("tan (default)", (:)),
  ("green", (light: rgb("#eeeed2"), dark: rgb("#769656"))),
  ("blue", (light: rgb("#dee3e6"), dark: rgb("#4b7399"))),
  ("high contrast", (light: rgb("#ffffff"), dark: rgb("#333333"))),
)

= Color themes

Each labeled (on-square) so label colors track the square colors; the last shows
a highlight fill.

#grid(
  columns: themes.len(),
  column-gutter: 10pt,
  ..themes.map(((name, ov)) => stack(dir: ttb, spacing: 6pt,
    align(center, strong(name)),
    board(test-fen, size: 3.6cm, ..ov))),
)

#v(10pt)

Border mode (band is a darkened dark-square color; labels stay light), plus a
highlight overlay:

#grid(
  columns: 2,
  column-gutter: 16pt,
  board(test-fen, size: 4.5cm, label-mode: "border",
    light: rgb("#eeeed2"), dark: rgb("#769656")),
  board(test-fen, size: 4.5cm, label-mode: "border",
    light: rgb("#dee3e6"), dark: rgb("#4b7399"),
    highlight: ("c4", "f3", "e5"), highlight-fill: rgb(220, 60, 60, 120)),
)
