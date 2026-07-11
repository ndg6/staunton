// Source for the README showcase #4 (annotated diagram). Keep in sync with its
// README code block. Regenerate with:
//   typst compile --root . --format png --ppi 160 docs/img/showcase-annotations.typ docs/img/showcase-annotations.png
#import "/lib.typ": parse-pgn, diagram-after

#set page(width: auto, height: auto, margin: 12pt, fill: white)
#set text(font: "Libertinus Serif", size: 10pt)

// `%cal` / `%csl` drawing commands in the comment become arrows / highlights, and
// the `!` on Nf3 becomes a move-quality badge on its destination square.
#let game = parse-pgn(```
[White "Study"] [Black "Reader"]
1. e4 e5 2. Nf3! {[%cal Gf3e5,Rf1c4][%csl Ge5]} Nc6 *
```).first()

#diagram-after(game, "2w", annotations: true, move-quality: true, size: 4.8cm)
