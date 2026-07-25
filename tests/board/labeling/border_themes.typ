// "border" mode band themes. `border-theme` picks the band
// fill / label color: "square" (default) = dark-square band + light-square
// labels; "brown" = espresso-brown band + creme-white labels; "creme" = creme
// band + saddle-brown labels; "dark" = charcoal band + light-grey labels (a
// neutral dark-mode look); "light" = light-grey band + charcoal labels (the
// mirror of "dark"); "wood" = the same espresso-brown backdrop as "brown" but
// with a wood-grain texture composited over the band; "marble" = a
// bottle-green backdrop with a marble-veining texture, creme labels
// (provisional -- see tests/VISUAL_CHECKS.md). Settable as a document default
// and a per-call override.
#import "/lib.typ": board, board-theme, default-board-style, set-board-defaults
#import "/tests/board/_fixture.typ": test-fen

#assert(default-board-style.border-theme == "square", message: "square theme is the border default")

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Border-mode themes

#grid(columns: 5, column-gutter: 16pt, row-gutter: 16pt,
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
  stack(dir: ttb, spacing: 5pt, align(center, emph("wood")),
    board(test-fen, size: 4.4cm, label-mode: "border", border-theme: "wood")),
  stack(dir: ttb, spacing: 5pt, align(center, emph("marble")),
    board(test-fen, size: 4.4cm, label-mode: "border", border-theme: "marble")),
)

The theme is also a document default; the per-call override still wins:

#set-board-defaults(border-theme: "brown")

#board(test-fen, size: 4.4cm, label-mode: "border")

The new "wood" value also travels the defaults route on its own (no per-call
override this time), reaching `render-board`'s enum check via
`set-board-defaults` rather than as a direct argument:

#set-board-defaults(border-theme: "wood")

#board(test-fen, size: 4.4cm, label-mode: "border")

And "marble" via the other plumbing path, a whole `board-theme(..)` value
passed to `set-board-defaults`:

#set-board-defaults(board-theme: board-theme(border-theme: "marble"))

#board(test-fen, size: 4.4cm, label-mode: "border")
