// board vs diagram styling are split into two buckets, each with a
// factory default, a document-order default (setter), and a key set. This test
// covers the contract + the two explicit setters and the umbrella.
#import "/lib.typ": (
  board, diagram, starting-fen,
  default-board-style, default-diagram-style, board-style-keys, diagram-style-keys,
  set-board-defaults, set-diagram-defaults, set-chess-defaults,
)

// --- contract assertions ---------------------------------------------------
#assert(board-style-keys.contains("light"), message: "board keys include square colors")
#assert(board-style-keys.contains("arrows"), message: "arrows is a board key")
#assert(diagram-style-keys.contains("info-bold"), message: "info-bold is a diagram key")
#assert(not board-style-keys.contains("info-bold"), message: "info-bold is NOT a board key")
#assert(not diagram-style-keys.contains("light"), message: "light is NOT a diagram key")
#assert(default-diagram-style.info-bold == true, message: "auto game-info is bold by default")
#assert(default-board-style.piece-scale == 0.95, message: "pieces shrunk to 95%")

#set page(width: 13cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)

= Split board / diagram defaults

#set-board-defaults(light: rgb("#eeeed2"), dark: rgb("#769656"), label-mode: "border")
#set-diagram-defaults(info-bold: false, supplement: [Stellung])

After `set-board-defaults` (green/border) + `set-diagram-defaults` (info not
bold, supplement "Stellung"):

#diagram(starting-fen, size: 4cm, white: [A], black: [B], year: 2024)

The umbrella `set-chess-defaults` routes keys to both buckets at once:
#set-chess-defaults(dark: rgb("#4b7399"), info-gap: 1.2em)
#diagram(starting-fen, size: 4cm, white: [C], black: [D])
