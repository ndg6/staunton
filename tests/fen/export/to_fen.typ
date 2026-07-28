// to-fen: export a position OR a game-at-locator back to a FEN
// string (inverse of parse-fen). Standard positions round-trip exactly.
#import "/lib.typ": to-fen, parse-fen, position, play, parse-pgn, starting-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

// round-trip: parse-fen -> to-fen is the identity for standard FENs
#let fens = (
  starting-fen,
  "r1bqkb1r/1ppp1ppp/p1n2n2/4p3/B3P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 2 5",
  "8/8/8/3k4/3K4/8/8/8 b - - 10 42",
  // en-passant target d6 that IS capturable (White pawn on e5): round-trips.
  "rnbqkbnr/pp2pppp/8/2ppP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 3",
)
#for f in fens {
  assert(to-fen(parse-fen(f)) == f, message: "round-trip failed: " + to-fen(parse-fen(f)) + " != " + f)
}

// Strict X-FEN e.p.: an e.p. target with no pawn able to capture it is dropped to
// "-" on output (here c6 has no white pawn on b5/d5), even though parse-fen keeps
// it leniently on input.
#assert(
  to-fen(parse-fen("rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2"))
    == "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2",
  message: "strict e.p. should drop a non-capturable target",
)

// a position built with position() (castling empty, en-passant none) serialises
#assert(to-fen(position((e1: "K", e8: "k"))) == "4k3/8/8/8/8/8/8/4K3 w - - 0 1", message: "manual position -> fen")

// from a play result
#assert(
  to-fen(play(none, "1. e4 e5 2. Nf3 Nc6"))
    == "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3",
  message: "play -> fen",
)

// from a game + locator (diagram-after locator syntax); "2w" = AFTER White's 2nd
#let g = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 *").first()
#assert(to-fen(g, locator: "2w") == "rnbqkbnr/pppp1ppp/8/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2", message: "game@2w -> fen")
#assert(to-fen(g, locator: "2b") == "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3", message: "game@2b -> fen")

= to-fen

Starting position: #raw(to-fen(parse-fen(starting-fen))) \
Game after 2...Nc6: #raw(to-fen(g, locator: "2b"))
