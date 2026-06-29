// Style options - using styles "directly": build an override dict with
// `chess-style(..)` and spread it into a board, and assert the style contract
// (default-style keys, flip is NOT a style key). Mixed test: assertions (fail
// on regression) plus a visual render of the directly-built style.
#import "/lib.typ": board, chess-style, default-style, style-keys
#import "/tests/board/_fixture.typ": test-fen

// --- contract assertions ---------------------------------------------------
#assert(default-style.label-mode == "on-square", message: "default label-mode changed")
#assert(style-keys.contains("piece-set"), message: "piece-set must be a style key")
#assert(not style-keys.contains("flip"), message: "flip must NOT be a style key (per-diagram only)")
#assert(chess-style(size: 3cm, label-mode: "border") == (size: 3cm, label-mode: "border"),
  message: "chess-style should just collect named overrides")

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Using a style dict directly

#let my-style = chess-style(
  light: rgb("#f2e9d0"),
  dark: rgb("#8a6d4f"),
  label-mode: "outside",
  piece-set: "merida",
)

A board rendered by spreading a `chess-style(..)` dict:

#board(test-fen, size: 5cm, ..my-style)
