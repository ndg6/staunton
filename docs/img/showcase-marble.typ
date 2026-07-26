// Source for the README showcase #5 (material border theme). Keep in sync with
// its README code block. Regenerate with:
//   typst compile --root . --format png --ppi 160 docs/img/showcase-marble.typ docs/img/showcase-marble.png
#import "/lib.typ": board, color-theme

// A marble-veined band frames the board, with matching marbled squares --
// built-in "coral" colors, darkened and sharpened so the veining reads
// clearly against the pieces.
#set page(width: auto, height: auto, margin: 12pt, fill: white)

#board(
  "r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3",
  label-mode: "border",
  border-theme: "marble",
  color-theme: color-theme(base: "coral", pattern: "marble", brightness: -15%, contrast: 30%),
  size: 4.8cm,
)
