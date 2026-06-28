// §3 Diagrams - REFERENCING chess diagrams. A chess-diagram is a #figure with
// kind "chess", so a label attaches to it and @label resolves. A dangling
// reference is a hard error in Typst, so a clean compile already proves the
// references work; the query asserts the diagram counter is independent (only
// chess figures are counted here).
#import "/lib.typ": chess-diagram, chess-diagram-outline, starting-fen

#set page(width: 14cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)
#set heading(numbering: "1.")

#chess-diagram-outline()

= Positions
#chess-diagram(starting-fen, size: 2.5cm, caption: [The starting position]) <start>
#chess-diagram(starting-fen, size: 2.5cm, caption: [From Black's side], flip: true) <flipped>

The opening is @start; the flipped view is @flipped.

#context {
  assert(query(figure.where(kind: "chess")).len() == 2, message: "two chess diagrams present")
}
