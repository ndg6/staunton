// play(source, moves): apply a run of moves to a position
// (or FEN, or none=start) and return the FINAL position, renderable. The variant
// is carried by the source; move text tolerates move numbers and a result token.
#import "/lib.typ": play, position, diagram, starting-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

// --- a Ruy Lopez example: FEN + move text -> target FEN ---
#let start = "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3"
#let target = position("r1bqkb1r/1ppp1ppp/p1n2n2/4p3/B3P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 2 5")

#let final = play(start, "Bb5 a6 Ba4 Nf6")
#assert(final.squares == target.squares, message: "Ruy Lopez squares mismatch")
#assert(final.turn == target.turn, message: "turn mismatch")
#assert(final.fullmove == target.fullmove, message: "fullmove mismatch")
#assert(final.castling == target.castling, message: "castling mismatch")

// move numbers + a trailing result are tolerated and stripped (same position)
#let numbered = play(start, "3. Bb5 a6 4. Ba4 Nf6")
#assert(numbered.squares == final.squares, message: "move-number stripping")

// the array form is equivalent to the string form
#let arrayed = play(start, ("Bb5", "a6", "Ba4", "Nf6"))
#assert(arrayed.squares == final.squares, message: "array form")

// none -> standard start; position() of the same line agrees with our Ruy start
#let from-start = play(none, "1. e4 e5 2. Nf3 Nc6")
#assert(from-start.squares == position(start).squares, message: "none = standard start")

// An assertion here used to compare position()'s FEN auto-detect against the
// separate FEN parser. That parser is no longer public in 2.0.0, so the
// assertion would have compared `position(start)` to itself -- a check that
// cannot fail -- and was retired rather than migrated. The auto-detect path is
// still exercised by every other position() call taking a FEN string in this
// sheet, e.g. `target` and `from-start` above.

= play: the Ruy Lopez, built from move text

#diagram(final, size: 5cm,
  caption: [After 3.Bb5 a6 4.Ba4 Nf6, from `play`.])
