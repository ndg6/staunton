// EXPECT: not a legal move
// A move dict that is not among the position's legal moves (here: a rook
// slide from a1 to a4, blocked by White's own pawn on a2) is a hard assertion
// error, not a silent no-op or best-effort encoding.
#import "/lib.typ": position, starting-fen, move-to-san

#let bogus = (
  from: (0, 0), to: (0, 3), piece: "rook", color: "white",
  capture: none, kind: "normal", promotion: none,
)
#let _ = move-to-san(position(starting-fen), bogus)
