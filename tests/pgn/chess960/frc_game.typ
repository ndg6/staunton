// Chess960 PGN end-to-end: a game tagged [Variant "Fischerrandom"][SetUp "1"]
// [FEN <X-FEN start>] is recognised as chess960, starts from the FEN tag, and
// replays through the shared engine (incl. Chess960 castling). The parsed-game
// replay must agree with play applied to the same start + SAN list.
#import "/lib.typ": parse-pgn, game-variant, game-start, position-after, to-fen, play, board, diagram

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

// Chess960 start: king on f, rooks on b/h (knights on a/g, bishops on c/d).
#let start960 = "nrbbqknr/pppppppp/8/8/8/8/PPPPPPPP/NRBBQKNR w KQkq - 0 1"
#let g = parse-pgn(
  "[Variant \"Fischerrandom\"][SetUp \"1\"][FEN \"" + start960 + "\"]\n" +
  "1. Nf3 Nf6 2. O-O O-O *"
).first()

// --- recognition + start position ---
#assert(game-variant(g) == "chess960", message: "variant: " + game-variant(g))
#assert(to-fen(game-start(g)) == start960, message: "start: " + to-fen(game-start(g)))

// --- replay: parsed game agrees with play from the same start ---
#let via-cm = play(start960, "Nf3 Nf6 O-O O-O")
#assert(position-after(g, "2b").squares == via-cm.squares, message: "pgn replay != play")

// After both sides castle king-side: kings on g, rooks on f, castling gone.
#assert(
  to-fen(position-after(g, "2b")) == "nrbbqrk1/pppppppp/5n2/8/8/5N2/PPPPPPPP/NRBBQRK1 w - - 4 3",
  message: "final: " + to-fen(position-after(g, "2b")),
)

= Chess960 game replay

#board(start960, size: 4cm)
#diagram(position-after(g, "2b"), size: 4cm,
  caption: [After 2.O-O O-O — both kings castled from the f-file start.])
