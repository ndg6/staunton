// Source for README Quick-Start example 2 (start position with PGN-style
// metadata for the caption / info line). Keep in sync with its code block in
// README.md. Regenerate with:
//   typst compile --root . --format png --ppi 160 docs/img/quickstart-2.typ docs/img/quickstart-2.png
#import "/lib.typ": chess-diagram, starting-fen

#set page(width: auto, height: auto, margin: 12pt, fill: white)
#set text(font: "Libertinus Serif", size: 10pt)

// The starting position, with PGN-style metadata for the caption:
#chess-diagram(starting-fen, white: [Carlsen], black: [Nepo], event: [Dubai], year: 2021, size: 3.4cm)
