// EXPECT: move-quality badges are derived from a game move
// Prompt 28: a move-quality badge is tied to a MOVE, so it may only come from a
// game. Setting `move-quality-mark` on a bare board — which could otherwise badge
// an arbitrary or empty square — is a hard error.
//
// Prompt 49 made this guard STRONGER rather than redundant. There is now a
// legitimate way in (draw a `position-after` position and its provenance supplies
// the mark), but the qualification is carried by the POSITION, not by which
// function was called — so a caller-supplied mark on a bare board stays refused.
#import "/lib.typ": board

#board(
  "4k3/8/8/8/8/8/8/4K3 w - - 0 1",
  move-quality: true,
  move-quality-mark: (square: "e4", symbol: "!"),
)
