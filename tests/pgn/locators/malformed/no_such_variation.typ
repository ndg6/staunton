// EXPECT: no variation #
// `into:` an index past the variations recorded at that move is a hard error.
#import "/lib.typ": parse-pgn, board-after
#let game = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 (1. d4 d5) e5 *").first()
// only variation #0 exists at 1w; #1 was never recorded
#let _ = board-after(game, (line: ((at: "1w", into: 1),), at: "1b"))
