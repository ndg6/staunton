// EXPECT: 8 ranks
// 4.1 - the placement field must have exactly 8 ranks separated by "/".
// This FEN has only 7, which is a hard, user-facing error.
#import "/lib.typ": parse-fen
#let _ = parse-fen("rnbqkbnr/pppppppp/8/8/8/8/RNBQKBNR w KQkq - 0 1")
