// Style options - the style contract: which keys count as style keys
// (board-style-keys / diagram-style-keys), that flip is NOT a style key
// (it is per-diagram only), and that a user-built style dict literal can be
// spread into `board`. Mixed test: assertions (fail on regression) plus a
// visual render of the directly-built style.
#import "/lib.typ": board, default-board-style, board-style-keys, diagram-style-keys
#import "/tests/board/_fixture.typ": test-fen

// --- contract assertions ---------------------------------------------------
#assert(default-board-style.label-mode == "on-square", message: "default label-mode changed")
#assert(board-style-keys.contains("piece-set"), message: "piece-set must be a style key")
#assert(not board-style-keys.contains("flip"), message: "flip must NOT be a board style key (per-diagram only)")
#assert(not diagram-style-keys.contains("flip"), message: "flip must NOT be a diagram style key (per-diagram only)")

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Using a style dict directly

#let my-style = (
  light: rgb("#f2e9d0"),
  dark: rgb("#8a6d4f"),
  label-mode: "outside",
  piece-set: "merida",
)

A board rendered by spreading a plain style dict literal:

#board(test-fen, size: 5cm, ..my-style)
