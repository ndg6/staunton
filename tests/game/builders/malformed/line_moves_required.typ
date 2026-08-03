// EXPECT: with-line: `moves` (a movetext fragment) is required
// `moves:` is required in BOTH modes (branch and continue); this checks the
// continue path (`at:` omitted).
#import "/lib.typ": game, with-line
#let g = game("1. e4 e5 *")
#let _ = with-line(g)
