// HTML-export demo: each staunton output primitive on its own, to show what the
// package produces under Typst's HTML export (notation, tables, figures, refs and
// outlines become native HTML; boards/diagrams embed as inline SVG via html.frame).
// Build:  typst compile --root . --features html --format html docs/examples/html_export.typ html_export.html
// (It also compiles to PDF normally: typst compile --root . docs/examples/html_export.typ out.pdf)
#import "/lib.typ": *

= staunton HTML export

== 1. Pure board
#board("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR", size: 4cm)

== 2. Chess diagram (figure + caption + ref)
#diagram(
  "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R",
  caption: [The Ruy Lopez, three moves in.],
  size: 4cm,
) <ruy>

See @ruy for the position.

== 3. Notation
#let g = game("1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 *")
#notation(g)

== 4. Diagram at a locator
#diagram-after(g, "3w", size: 4cm)

== 5. Standings table
#let rr = games(```
[White "A"][Black "B"][Result "1-0"] 1-0
[White "A"][Black "C"][Result "1-0"] 1-0
[White "B"][Black "C"][Result "1-0"] 1-0
```)
#standings-table(rr)

== 6. Outlines
#diagram-outline()
