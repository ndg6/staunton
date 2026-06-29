// FEN (good) - a FEN with NO whitespace is just the placement field; the
// missing metadata is filled in silently (w KQkq - 0 1). Placement-only input
// must therefore parse and render without error.
//
// NOTE ( / backlog): once "any whitespace present => must be a
// complete, valid FEN" lands, the silent-default castling for the no-whitespace
// case becomes KQkq (today the code defaults castling to "-"). This test only
// checks that a space-free FEN is accepted; it does not pin the castling value.
#import "/lib.typ": board, parse-fen, starting-fen

#set page(width: auto, height: auto, margin: 1cm)

// Starting placement only, no spaces.
#let placement = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
#let pos = parse-fen(placement)
#assert(pos.turn == "w", message: "side to move should default to white")
#assert(pos.fullmove == 1, message: "fullmove should default to 1")

#board(placement, size: 5cm)
