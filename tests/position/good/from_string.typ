// the new "string" constructor: build a position from row strings
// (first line = top rank, "." = empty, upper = white, lower = black). Both the
// raw-block form and the several-row-strings form must agree, derive geometry by
// counting, and render.
#import "/lib.typ": board, position

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

// Raw-block form.
#let p1 = position(```
  ....r...
  ........
  ..p..PPk
  .p.r....
  pP..p.R.
  P.B.....
  ..P..K..
  ........
```)

#assert(p1.variant == "standard", message: "default variant")
#assert(p1.cols == 8 and p1.rows == 8, message: "8x8 geometry counted from the string")
// first line is the top rank (rank 8): "....r..." -> e8 black rook
#assert(p1.squares.at("e8") == (kind: "rook", color: "black"), message: "e8 should be a black rook")
// line "..P..K.." is the 2nd rank from the bottom: c2 white pawn, f2 white king
#assert(p1.squares.at("c2") == (kind: "pawn", color: "white"), message: "c2 white pawn")
#assert(p1.squares.at("f2") == (kind: "king", color: "white"), message: "f2 white king")

// Several-row-strings form must produce the identical squares.
#let p2 = position(
  "....r...", "........", "..p..PPk", ".p.r....",
  "pP..p.R.", "P.B.....", "..P..K..", "........",
)
#assert(p2.squares == p1.squares, message: "raw-block and row-string forms must agree")

= Position from a string

#board(p1, size: 6cm)
