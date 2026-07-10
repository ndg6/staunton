// Source for README Quick-Start example 4 (a diagram from a game). Keep in sync
// with its code block in README.md. Regenerate with:
//   typst compile --root . --format png --ppi 160 docs/img/quickstart-4.typ docs/img/quickstart-4.png
#import "/lib.typ": parse-pgn, diagram-after

#set page(width: auto, height: auto, margin: 12pt, fill: white)
#set text(font: "Libertinus Serif", size: 10pt)

#let game = parse-pgn(```
[White "Morphy"] [Black "NN"] [Result "1-0"]
1. e4 e5 2. Nf3 d6 3. d4 *
```).first()

#diagram-after(game, "3w", size: 3.4cm)   // position after White's 3rd move
