// The convenient, DRY path: build a loader with `svg-piece-set` (staunton owns
// the wK.svg naming; you supply only a one-line file reader, authored here so it
// resolves against your project root), set it ONCE as the document-wide default,
// then draw many boards with no per-board piece-set. Typst memoizes the reads, so
// the shared loader does not re-read art per board.
//
// Asserting test: two boards, 2 + 1 pieces -> exactly 3 rendered images, all via
// the default loader.
#import "/lib.typ": board, set-piece-set, svg-piece-set

#set page(width: auto, height: auto, margin: 1cm)

#set-piece-set(svg-piece-set(f => read("/src/assets/piece_sets/cburnett/" + f, encoding: none)))

Two boards, both using the document-wide loader default:

#board("4k3/8/8/8/8/8/8/4K3 w - - 0 1", size: 3cm, labels: false)
#board("8/8/8/8/4N3/8/8/8 w - - 0 1", size: 3cm, labels: false)

#context assert(
  query(image).len() == 3,
  message: "settable-default loader should render 3 images, got " + str(query(image).len()),
)
