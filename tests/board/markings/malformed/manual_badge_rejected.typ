// EXPECT: move-quality badges are derived from a game move
// Prompt 28: a move-quality badge is tied to a MOVE, so it may only come from a
// game (via `diagram-after`). Setting `move-quality-mark` on a bare board — which
// could otherwise badge an arbitrary or empty square — is a hard error.
#import "/lib.typ": board

#board(
  "4k3/8/8/8/8/8/8/4K3 w - - 0 1",
  move-quality: true,
  move-quality-mark: (square: "e4", symbol: "!"),
)
