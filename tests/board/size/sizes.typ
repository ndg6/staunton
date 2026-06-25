// §2.1 Sizes - the same position at a range of sizes, NO labeling (per the
// prompt). Eyeball that pieces stay centred and proportional as the board grows.
#import "/lib.typ": board
#import "/tests/board/_fixture.typ": test-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

#let sizes = (1.5cm, 2.5cm, 3.5cm, 5cm, 7cm)

= Board sizes (no labels)

#grid(
  columns: sizes.len(),
  column-gutter: 10pt,
  align: bottom + center,
  ..sizes.map(s => board(test-fen, size: s, labels: false)),
  ..sizes.map(s => align(center, repr(s))),
)
