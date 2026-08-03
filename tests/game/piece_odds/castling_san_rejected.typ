// EXPECT: illegal king-side castling
// Piece-odds companion to castling_needs_rook.typ, from the PGN/SAN side: `O-O` in a
// rook-odds position must HALT, not silently produce a wrong castle. The start is the
// exact FEN Lichess' board editor gives for "standard start minus the h1 rook"
// (castling field `Qkq`). The opening moves are legal and validated by the engine as
// it plays them (a wrong move would error with a DIFFERENT message and this test
// would then FAIL, surfacing the mistake) — so the only move that can raise "illegal
// king-side castling" is the final O-O.
#import "/lib.typ": play
#let _ = play("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBN1 w Qkq - 0 1", moves: "e4 e5 Nf3 Nc6 Bc4 Nf6 O-O")
