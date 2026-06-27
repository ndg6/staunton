// EXPECT: supports only standard chess
// §prompt 13 - move analysis is standard-chess only for now; the engine rejects
// a non-standard position, so play-moves on one errors (no `variant` parameter).
#import "/lib.typ": play-moves, position
#let pos = position((e1: "K", e8: "k"), variant: "standard")
// force a non-standard variant on the position dict to hit the engine guard
#let variant-pos = pos + (variant: "xiangqi")
#let _ = play-moves(variant-pos, "Ke2")
