// §5 PGN (good) - a board for a position inside a NESTED variation (a variation
// within a variation), addressed by a two-step path locator.
#import "/lib.typ": parse-pgn, board-after

#set page(width: 13cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)

// Mainline: 1.e4 e5. Variation 0 at 1w: 1.d4 d5, with a NESTED variation 0 at
// Black's 1st move of that line: 1...Nf6 2.c4.
#let game = parse-pgn(```
[White "Nested"] [Black "Test"]
1. e4 (1. d4 d5 (1... Nf6 2. c4) ) 1... e5 *
```).first()

= Nested variation position

Into variation 0 at 1w (1.d4), then into variation 0 at 1b (1...Nf6), position
after 2.c4:

#board-after(game, (line: ((at: "1w", into: 0), (at: "1b", into: 0)), at: "2w"), size: 5cm)
