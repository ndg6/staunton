// Move notation exports as ordinary inline text; the mainline moves are bold, so
// they become <strong> elements in HTML (no SVG, no image).
// HTML-HAS: <strong>
// HTML-LACKS: <svg
#import "/lib.typ": parse-pgn, notation
#let g = parse-pgn("1. e4 e5 2. Nf3 Nc6 *").first()
#notation(g)
