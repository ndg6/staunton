// Piece-odds ("rook odds"): White starts from the standard array minus the h1 rook.
// The odds start below is the exact FEN Lichess' board editor produces — note the
// castling field is `Qkq`, i.e. White's king-side right is already (correctly) gone
// because there is no h1 rook.
//
// Positions are built by PLAYING the moves through the engine, not by hand-writing a
// FEN: `chess-moves` validates every half-move, so if any move were impossible this
// test would error on that move rather than pass for the wrong reason. All lines use
// the Two Knights opening (1.e4 e5 2.Nf3 Nc6 3.Bc4 Nf6), which leaves White to move
// with f1/g1 empty and unattacked — the only difference between them is the h1 rook
// (and, in (c), a deliberately inconsistent castling field).
#import "/lib.typ": legal-moves, chess-moves

#let opening = "e4 e5 Nf3 Nc6 Bc4 Nf6"
#let kingcastles(p) = legal-moves(p).filter(m => m.kind == "castle-k")

// (a) Positive control: rook PRESENT (standard start) -> exactly one king-side castle
//     is offered. Proves the castle detector actually fires, so the 0s below matter.
#let withRook = chess-moves("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", opening)
#assert(kingcastles(withRook).len() == 1, message: "control: rook present but O-O not offered: " + repr(kingcastles(withRook)))

// (b) The Lichess odds FEN (rights correctly show no white `K`): O-O is not offered
//     because the right is absent.
#let odds = chess-moves("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBN1 w Qkq - 0 1", opening)
#assert(kingcastles(odds).len() == 0, message: "odds: O-O offered without the h1 rook: " + repr(kingcastles(odds)))

// (c) Stronger guard: SAME board, but a FEN that WRONGLY keeps `K` though h1 is empty.
//     The engine must ignore the stale right and re-derive legality from the board
//     (src/engine.typ `_castle-ok`), so O-O is still refused.
#let oddsStale = chess-moves("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBN1 w KQkq - 0 1", opening)
#assert(kingcastles(oddsStale).len() == 0, message: "odds: engine trusted a stale `K` right and offered O-O: " + repr(kingcastles(oddsStale)))

= Rook-odds: king-side castling requires the rook to actually be present
