// Source for the README showcase #2 (move notation). Keep in sync with its README
// code block. Regenerate with:
//   typst compile --root . --format png --ppi 160 docs/img/showcase-notation.typ docs/img/showcase-notation.png
#import "/lib.typ": parse-pgn, notation

#set page(width: 11cm, height: auto, margin: 12pt, fill: white)
#set text(font: "Libertinus Serif", size: 12pt)

// A Ruy Lopez with a side line and an annotated move.
#let game = parse-pgn(```
1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O Be7 (5... Nxe4!? 6. d4 b5) 6. Re1 b5 7. Bb3 d6 *
```).first()

// Figurine glyphs, the variation inline, and the NAG on 5...Nxe4.
#notation(game, figurine: true, variations: true, nags: true)
