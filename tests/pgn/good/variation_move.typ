// PGN (good) - a board for a position inside a VARIATION (RAV), addressed by
// a path locator. The inline game records one variation at White's 1st move.
#import "/lib.typ": parse-pgn, diagram-after

#set page(width: 13cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)

// Mainline: 1.e4 e5 2.Nf3. Variation 0 at White's move 1: 1.d4 d5.
#let game = parse-pgn(```
[White "Var"] [Black "Test"]
1. e4 (1. d4 d5 2. c4) 1... e5 2. Nf3 *
```).first()

= Variation position

Descend into variation 0 at White's move 1 (the 1.d4 line), position after 1...d5:

#diagram-after(game, (line: ((at: "1w", into: 0),), at: "1b"), size: 5cm)
