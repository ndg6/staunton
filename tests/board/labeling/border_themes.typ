// "border" mode band themes. `border-theme` picks the band
// fill / label color: "square" (default) = dark-square band + light-square
// labels; "brown" = espresso-brown band + creme-white labels; "creme" = creme
// band + saddle-brown labels; "dark" = charcoal band + light-grey labels (a
// neutral dark-mode look); "light" = light-grey band + charcoal labels (the
// mirror of "dark"). Settable as a document default and a per-call override.
#import "/lib.typ": board, default-board-style, set-board-defaults
#import "/tests/board/_fixture.typ": test-fen

#assert(default-board-style.border-theme == "square", message: "square theme is the border default")

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Border-mode themes

#grid(columns: 5, column-gutter: 16pt,
  stack(dir: ttb, spacing: 5pt, align(center, emph("square (default)")),
    board(test-fen, size: 4.4cm, label-mode: "border", border-theme: "square")),
  stack(dir: ttb, spacing: 5pt, align(center, emph("brown")),
    board(test-fen, size: 4.4cm, label-mode: "border", border-theme: "brown")),
  stack(dir: ttb, spacing: 5pt, align(center, emph("creme")),
    board(test-fen, size: 4.4cm, label-mode: "border", border-theme: "creme")),
  stack(dir: ttb, spacing: 5pt, align(center, emph("dark")),
    board(test-fen, size: 4.4cm, label-mode: "border", border-theme: "dark")),
  stack(dir: ttb, spacing: 5pt, align(center, emph("light")),
    board(test-fen, size: 4.4cm, label-mode: "border", border-theme: "light")),
)

The theme is also a document default; the per-call override still wins:

#set-board-defaults(border-theme: "brown")

#board(test-fen, size: 4.4cm, label-mode: "border")
