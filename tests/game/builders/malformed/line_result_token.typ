// EXPECT: must not contain a result token
// `moves:` must not carry its own result token: the result is a game-level
// field carried from the source game, never part of the movetext fragment.
// (Bug fix: it previously made the parser stop and silently discard the
// token and every move after it, instead of erroring.)
#import "/lib.typ": game, with-line
#let g = game("1. e4 e5 1-0")
#with-line(g, moves: "2. Nf3 0-1 2... Nc6 3. Bb5")
