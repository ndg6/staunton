// EXPECT: illegal or unresolvable move
// Movetext that parses structurally but is chess-illegal: a pawn cannot reach
// e5 on move 1. This is caught when the position is navigated (Phase B), where
// the engine resolves SAN against the legal moves.
#import "/src/pgn.typ": game
#import "/src/game.typ": position-after
#let g = game("1. e5 e5 *")
#let _ = position-after(g, "1w")
