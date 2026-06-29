// Diagrams - the chess-diagram outline. chess-diagram emits figures with a
// distinct kind ("chess"), so chess-diagram-outline lists ONLY those, separately
// from any other figures (here a non-chess figure is included to prove it is
// skipped).
#import "/lib.typ": chess-diagram, chess-diagram-outline, starting-fen

#set page(width: 13cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)

#chess-diagram-outline()

= Diagrams
#chess-diagram(starting-fen, size: 3cm, caption: [First diagram])
#chess-diagram(starting-fen, size: 3cm, caption: [Second diagram], flip: true)

A regular (non-chess) figure that must NOT appear in the chess outline:
#figure(rect(width: 2cm, height: 1cm), caption: [An ordinary figure])

#chess-diagram(starting-fen, size: 3cm, caption: [Third diagram])
