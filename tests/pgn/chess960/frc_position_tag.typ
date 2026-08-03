// Chess960 games may declare their start by NUMBER instead of a FEN, via a
// [FRCPosition N] or [Chess960Position N] tag. game-start resolves it through the
// Scharnagl numbering; an explicit [FEN] still wins when both are present.
#import "/lib.typ": game, game-start, game-variant, to-fen, position-after, chess960-start-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

// FRCPosition 518 is the standard start.
#let g518 = game("[Variant \"Fischerrandom\"][SetUp \"1\"][FRCPosition \"518\"] 1. e4 e5 *")
#assert(game-variant(g518) == "chess960")
#assert(to-fen(game-start(g518)) == chess960-start-fen(518), message: "FRCPosition 518 start")
// and it replays like standard chess from that start
#assert(
  to-fen(position-after(g518, at: "1b")) == "rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2",
  message: "replay: " + to-fen(position-after(g518, at: "1b")),
)

// Chess960Position (alternative spelling) with a genuinely non-standard start.
#let g356 = game("[Variant \"Chess960\"][Chess960Position \"356\"] *")
#assert(to-fen(game-start(g356)) == chess960-start-fen(356), message: "Chess960Position 356 start")

// Both number-tag spellings are fine as long as they agree.
#let gagree = game("[Variant \"Chess960\"][FRCPosition \"356\"][Chess960Position \"356\"] *")
#assert(to-fen(game-start(gagree)) == chess960-start-fen(356), message: "agreeing number tags")

= Start-by-number

`[FRCPosition 518]` and `[Chess960Position 356]` resolve to their Scharnagl start
positions. The start must be given exactly one way — a `[FEN]` and a position
number together are rejected (see `fen_and_number_conflict`).
