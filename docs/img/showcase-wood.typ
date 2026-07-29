// Source for the README showcase #6 (inlaid wood). Keep in sync with its README
// code block. Regenerate with:
//   typst compile --root . --format png --ppi 160 docs/img/showcase-wood.typ docs/img/showcase-wood.png
#import "/lib.typ": board, color-theme

// Grain runs across BOTH square colors (the 1.0.0 default), so the board reads
// as inlaid light and dark timber rather than texture on half the squares --
// built-in "wikipedia" tan/brown, with a matching wood band around it.
#set page(width: auto, height: auto, margin: 12pt, fill: white)

#board(
  "r1bqk1nr/pppp1ppp/2n5/2b1p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 4 4",
  label-mode: "border",
  border-theme: "wood",
  color-theme: color-theme(base: "wikipedia", pattern: "wood"),
  size: 4.8cm,
)
