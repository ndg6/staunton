// EXPECT: move-quality badges are derived from a game move
// A move-quality badge is tied to a MOVE, so it may only come from a game.
// Setting `move-quality-mark` on a bare board — which could otherwise badge an
// arbitrary or empty square — is a hard error. The only legitimate way in is
// `board(game, at: locator)` / `diagram(game, at: locator)`, which derives the
// mark itself — a caller-supplied mark is always refused, on a bare board or not.
#import "/lib.typ": board

#board(
  "4k3/8/8/8/8/8/8/4K3 w - - 0 1",
  move-quality: true,
  move-quality-mark: (square: "e4", symbol: "!"),
)
