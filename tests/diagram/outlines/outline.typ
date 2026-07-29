// Diagrams - the diagram outline. diagram emits figures with a
// distinct kind ("chess"), so diagram-outline lists ONLY those, separately
// from any other figures (here a non-chess figure is included to prove it is
// skipped).
#import "/lib.typ": diagram, diagram-outline, starting-fen

#set page(width: 13cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)

#diagram-outline()

= Diagrams
#diagram(starting-fen, size: 3cm, caption: [First diagram])
#diagram(starting-fen, size: 3cm, caption: [Second diagram], flip: true)

A regular (non-chess) figure that must NOT appear in the chess outline:
#figure(rect(width: 2cm, height: 1cm), caption: [An ordinary figure])

#diagram(starting-fen, size: 3cm, caption: [Third diagram])
