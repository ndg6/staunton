// Boards and diagrams have no HTML-native form, so under an HTML target the board
// is wrapped in `html.frame` and embedded as inline SVG, with the pieces as
// <image> elements (see src/board.typ). Both a bare board and a diagram.
// HTML-HAS: <svg
// HTML-HAS: <image
#import "/lib.typ": board, diagram
#board("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR", size: 3cm)
#diagram("4k3/8/8/8/8/8/8/4K3", size: 3cm)
