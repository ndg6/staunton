// FEN (good) - a complete, valid six-field FEN parses and renders.
#import "/lib.typ": board, parse-fen

#set page(width: auto, height: auto, margin: 1cm)

// Sanity-check the parse before drawing.
#let pos = parse-fen("r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQK2R w KQkq - 0 5")
#assert(pos.turn == "w", message: "turn should be white")
#assert(pos.fullmove == 5, message: "fullmove should be 5")
// castling is now the rook-file model: white king-side rook stands on the h-file (col 7)
#assert(pos.castling.white-king == 7, message: "white may castle kingside (h-file rook)")

#board("r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQK2R w KQkq - 0 5", size: 5cm)
