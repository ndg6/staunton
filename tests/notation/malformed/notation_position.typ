// EXPECT: a position has no move history
// §prompt 14 - notation needs a game or a SAN source; a position has no moves.
#import "/lib.typ": notation, parse-fen, starting-fen
#let _ = notation(parse-fen(starting-fen))
