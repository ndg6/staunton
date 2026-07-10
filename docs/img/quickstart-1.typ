// Source for README Quick-Start example 1 (a diagram from a FEN string). Keep in
// sync with its code block in README.md. Regenerate with:
//   typst compile --root . --format png --ppi 160 docs/img/quickstart-1.typ docs/img/quickstart-1.png
#import "/lib.typ": chess-diagram

#set page(width: auto, height: auto, margin: 12pt, fill: white)
#set text(font: "Libertinus Serif", size: 10pt)

// From a FEN string (1.e4 c5 2.Nf3):
#chess-diagram("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2", size: 3.4cm)
