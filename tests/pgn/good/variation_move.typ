// PGN (good) - boards for positions INSIDE variations, addressed by path locators:
// a one-step variation (RAV) and a two-step NESTED variation. Locator correctness
// is asserted in variation_locators.typ (cross-checked against play); this
// sheet is the visual confirmation that the drawn board matches.
#import "/lib.typ": parse-pgn, diagram-after

#set page(width: 13cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)

// Mainline 1.e4 e5 2.Nf3; variation 0 at White's move 1 is the 1.d4 d5 line.
#let vgame = parse-pgn(```
[White "Var"] [Black "Test"]
1. e4 (1. d4 d5 2. c4) 1... e5 2. Nf3 *
```).first()

// The 1.d4 d5 line carries a NESTED variation 0 at Black's 1st move: 1...Nf6 2.c4.
#let ngame = parse-pgn(```
[White "Nested"] [Black "Test"]
1. e4 (1. d4 d5 (1... Nf6 2. c4) ) 1... e5 *
```).first()

= Variation and nested-variation positions

*Left* — descend into variation 0 at White's move 1 (the 1.d4 line), position
after 1...d5. *Right* — into that same line, then its nested variation 0 at
Black's move 1 (1...Nf6), position after 2.c4.

#grid(columns: 2, column-gutter: 1cm, align: top,
  diagram-after(vgame, (line: ((at: "1w", into: 0),), at: "1b"), size: 5cm),
  diagram-after(ngame, (line: ((at: "1w", into: 0), (at: "1b", into: 0)), at: "2w"), size: 5cm),
)
