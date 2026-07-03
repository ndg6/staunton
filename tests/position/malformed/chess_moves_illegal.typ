// EXPECT: illegal or unresolvable move
// chess-moves resolves each token against the position's legal
// moves, so an illegal move is a hard error naming the offending SAN token.
#import "/lib.typ": chess-moves
#let _ = chess-moves(none, "1. e4 e5 2. Qh6")
