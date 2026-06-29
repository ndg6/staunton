// the position object shape after reshaping: it now carries
// `variant`, `cols`, `rows`, and a `squares` dict (renamed from `board`). All
// constructors (array, squares dict, FEN) yield the same shape; `chess-board`
// is an alias for `board`.
#import "/lib.typ": position, parse-fen, starting-fen, board, chess-board

#set page(width: auto, height: auto, margin: 1cm)

// Squares-dict form, mixing long names, kind abbreviations, and bare letters --
// all three must normalise to the same canonical (kind, color).
#let pa = position((
  e1: (kind: "king", color: "white"),   // long form
  d8: (kind: "q", color: "black"),       // kind abbreviation
  e4: "P",                                // bare letter (upper = white)
  e5: "p",                                // bare letter (lower = black)
))
#assert(pa.variant == "standard" and pa.cols == 8 and pa.rows == 8, message: "dict form geometry")
#assert(pa.squares.at("e1") == (kind: "king", color: "white"), message: "e1 white king (long)")
#assert(pa.squares.at("d8") == (kind: "queen", color: "black"), message: "d8 black queen (abbrev)")
#assert(pa.squares.at("e4") == (kind: "pawn", color: "white"), message: "e4 white pawn (letter)")
#assert(pa.squares.at("e5") == (kind: "pawn", color: "black"), message: "e5 black pawn (letter)")
#assert(pa.turn == "w" and pa.fullmove == 1, message: "default move state")
#assert(not ("board" in pa), message: "the field is `squares`, not `board`")

// Single-piece dict, explicit long form.
#let pd = position(("e4": (kind: "pawn", color: "white")))
#assert(pd.squares.at("e4").kind == "pawn", message: "dict form keeps the squares")

// FEN now exposes squares + variant + geometry.
#let pf = parse-fen(starting-fen)
#assert(pf.squares.at("e1") == (kind: "king", color: "white"), message: "FEN -> squares")
#assert(pf.variant == "standard" and pf.cols == 8 and pf.rows == 8, message: "FEN geometry")

// `chess-board` is the standard-variant entry point (sugar over `board`); it
// renders a standard position and rejects a non-standard one. (It is no longer
// literally `== board`, which is the generic variant-agnostic primitive.)
#chess-board(pa, size: 4cm, labels: false)
