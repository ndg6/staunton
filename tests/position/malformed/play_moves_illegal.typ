// EXPECT: illegal or unresolvable move
// play-moves resolves each token against the position's legal
// moves, so an illegal move is a hard error naming the offending SAN token.
#import "/lib.typ": play-moves
#let _ = play-moves(none, "1. e4 e5 2. Qh6")
