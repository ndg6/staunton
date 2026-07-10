// Source for README Quick-Start example 3 (manual placement from a squares
// dict). Keep in sync with its code block in README.md. Regenerate with:
//   typst compile --root . --format png --ppi 160 docs/img/quickstart-3.typ docs/img/quickstart-3.png
#import "/lib.typ": chess-diagram, position

#set page(width: auto, height: auto, margin: 12pt, fill: white)
#set text(font: "Libertinus Serif", size: 10pt)

// Manual placement: a squares dict (square -> piece). Square-name case is
// ignored; pieces may be long names, abbreviations, or bare letters.
#chess-diagram(position((
  e1: (kind: "king", color: "white"),
  e8: (kind: "king", color: "black"),
  e4: "P",                                // bare letter: upper = white pawn
)), labels: false, size: 3.4cm)
