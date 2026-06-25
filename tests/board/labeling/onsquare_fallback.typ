// §2.3 Labeling - vary the size of an "on-square" board to watch the automatic
// fallback to "border" labeling kick in. On-square corner labels shrink with the
// board; at or below ~4pt they would be illegible, so those diagrams switch to
// "border" labeling. Compare the rows: at small sizes the on-square row should
// visually match the border row.
#import "/lib.typ": board
#import "/tests/board/_fixture.typ": test-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 8pt)

// Span the fallback threshold (~5.2cm at label fraction 0.22): the small sizes
// fall back to "border", the large ones (6cm, 8cm) stay on-square. Compare the
// two rows -- below the threshold the on-square row matches the border row;
// above it, the on-square row shows corner labels on the board itself.
#let sizes = (1.6cm, 3cm, 4.4cm, 6cm, 8cm)

= On-square -> border auto fallback

#table(
  columns: sizes.len(),
  align: bottom + center,
  inset: 4pt,
  stroke: none,
  table.cell(colspan: sizes.len(), align: left)[*requested label-mode: on-square (tiny sizes fall back to border)*],
  ..sizes.map(s => board(test-fen, size: s, label-mode: "on-square")),
  table.cell(colspan: sizes.len(), align: left)[*label-mode: border (reference)*],
  ..sizes.map(s => board(test-fen, size: s, label-mode: "border")),
  ..sizes.map(s => align(center, repr(s))),
)
