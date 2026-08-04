// EXPECT: a position has no move history
// notation needs a game or a SAN source; a position has no moves.
#import "/lib.typ": notation, position, starting-fen
#let _ = notation(position(starting-fen))
