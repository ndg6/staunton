// EXPECT: expected standard chess
// chess-notation is the standard-variant sugar; a non-standard
// source is rejected before formatting.
#import "/lib.typ": chess-notation, position
#let pos = position((e1: "K", e8: "k")) + (variant: "xiangqi")
#let _ = chess-notation(pos)
