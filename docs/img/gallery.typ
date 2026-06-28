// Source for README's gallery image. Regenerate with:
//   typst compile --root . --format png --ppi 160 docs/img/gallery.typ docs/img/gallery.png
#import "/lib.typ": board, starting-fen

#set page(width: auto, height: auto, margin: 10pt, fill: white)

#let cap(body) = align(center, text(size: 9pt, font: "Libertinus Serif", body))

#grid(
  columns: 3,
  column-gutter: 16pt,
  align: bottom,

  // 1) starting position, default cburnett set, on-square labels
  stack(spacing: 6pt,
    board(starting-fen, size: 3.4cm),
    cap[Starting position]),

  // 2) a tactic with arrows + highlights, merida set, green theme
  stack(spacing: 6pt,
    board(
      "r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4",
      size: 3.4cm,
      piece-set: "merida",
      light: rgb("#eeeed2"), dark: rgb("#769656"),
      highlight: ("f7",),
      arrows: (("c4", "f7"), ("f3", "e5", rgb(0, 70, 160, 200))),
    ),
    cap[Highlights & arrows]),

  // 3) flipped, border label theme
  stack(spacing: 6pt,
    board(
      "8/5k2/8/8/3Q4/8/4K3/8 w - - 0 1",
      size: 3.4cm,
      flip: true,
      label-mode: "border",
      border-theme: "brown",
    ),
    cap[Flipped · border labels]),
)
