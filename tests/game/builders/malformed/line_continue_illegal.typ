// EXPECT: illegal or unresolvable move
// with-line's continue mode never plays out the position, so it accepts an
// illegal continuation without erroring; the error only surfaces when
// something later navigates into it (here, the internal `_position-after`).
#import "/lib.typ": game, with-line
#import "/src/game.typ": _position-after
#let g = game("1. e4 e5 *")
#let gc = with-line(g, moves: "2. Bxc6") // no White bishop can reach c6 in one move
#_position-after(gc, at: "2w")
