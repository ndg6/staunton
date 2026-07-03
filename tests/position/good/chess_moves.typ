// chess-moves(source, moves): apply a run of moves to a position
// (or FEN, or none=start) and return the FINAL position, renderable. The variant
// is carried by the source; move text tolerates move numbers and a result token.
#import "/lib.typ": chess-moves, parse-fen, position, chess-diagram, starting-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

// --- a Ruy Lopez example: FEN + move text -> target FEN ---
#let start = "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3"
#let target = parse-fen("r1bqkb1r/1ppp1ppp/p1n2n2/4p3/B3P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 2 5")

#let final = chess-moves(start, "Bb5 a6 Ba4 Nf6")
#assert(final.squares == target.squares, message: "Ruy Lopez squares mismatch")
#assert(final.turn == target.turn, message: "turn mismatch")
#assert(final.fullmove == target.fullmove, message: "fullmove mismatch")
#assert(final.castling == target.castling, message: "castling mismatch")

// move numbers + a trailing result are tolerated and stripped (same position)
#let numbered = chess-moves(start, "3. Bb5 a6 4. Ba4 Nf6")
#assert(numbered.squares == final.squares, message: "move-number stripping")

// the array form is equivalent to the string form
#let arrayed = chess-moves(start, ("Bb5", "a6", "Ba4", "Nf6"))
#assert(arrayed.squares == final.squares, message: "array form")

// none -> standard start; parse-fen of the same line agrees with our Ruy start
#let from-start = chess-moves(none, "1. e4 e5 2. Nf3 Nc6")
#assert(from-start.squares == parse-fen(start).squares, message: "none = standard start")

// position() now auto-detects a FEN string (delegates to parse-fen)
#assert(position(start).squares == parse-fen(start).squares, message: "position() FEN auto-detect")

= chess-moves: the Ruy Lopez, built from move text

#chess-diagram(final, size: 5cm,
  caption: [After 3.Bb5 a6 4.Ba4 Nf6, from `chess-moves`.])
