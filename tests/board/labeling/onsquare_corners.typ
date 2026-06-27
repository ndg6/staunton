// §prompt 12, item 2 - on-square label CORNER placement. Vertical edge is fixed
// (files on the bottom edge, ranks on the top edge); `file-label-corner` and
// `rank-label-corner` pick the horizontal corner. Defaults: file lower-left,
// rank upper-right.
#import "/lib.typ": board, default-board-style
#import "/tests/board/_fixture.typ": test-fen

#assert(default-board-style.file-label-corner == left, message: "file label defaults lower-left")
#assert(default-board-style.rank-label-corner == right, message: "rank label defaults upper-right")

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

#let combos = (
  ("file LL / rank UR (default)", (file-label-corner: left,  rank-label-corner: right)),
  ("file LR / rank UR",           (file-label-corner: right, rank-label-corner: right)),
  ("file LL / rank UL",           (file-label-corner: left,  rank-label-corner: left)),
  ("file LR / rank UL",           (file-label-corner: right, rank-label-corner: left)),
)

= On-square label corners

#grid(
  columns: combos.len(),
  column-gutter: 12pt,
  ..combos.map(((name, ov)) => stack(dir: ttb, spacing: 5pt,
    align(center, emph(name)),
    board(test-fen, size: 4.4cm, label-mode: "on-square", ..ov))),
)

= Corners on swapped edges

File labels on the TOP rank (`file-side: top`) and rank labels on the LEFT-most
file (`rank-side: left`); the corner options still pick which corner within those
edges:

#grid(
  columns: combos.len(),
  column-gutter: 12pt,
  ..combos.map(((name, ov)) => stack(dir: ttb, spacing: 5pt,
    align(center, emph(name)),
    board(test-fen, size: 4.4cm, label-mode: "on-square",
      file-side: top, rank-side: left, ..ov))),
)
