// EXPECT: supports only standard chess
// move analysis is standard-chess only for now; the engine rejects
// a non-standard position, so play on one errors (no `variant` parameter).
#import "/lib.typ": play, position
#let pos = position((e1: "K", e8: "k"), variant: "standard")
// force a non-standard variant on the position dict to hit the engine guard
#let variant-pos = pos + (variant: "xiangqi")
#let _ = play(variant-pos, moves: "Ke2")
