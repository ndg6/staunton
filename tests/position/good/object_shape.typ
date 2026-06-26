// §position - the position object shape after reshaping: it now carries
// `variant`, `cols`, `rows`, and a `squares` dict (renamed from `board`). All
// constructors (array, squares dict, FEN) yield the same shape; `chess-board`
// is an alias for `board`.
#import "/lib.typ": position, parse-fen, starting-fen, board, chess-board

#set page(width: auto, height: auto, margin: 1cm)

// Array-of-pieces form.
#let pa = position((("king", "white", "e1"), ("queen", "black", "d8")))
#assert(pa.variant == "standard" and pa.cols == 8 and pa.rows == 8, message: "array form geometry")
#assert(pa.squares.at("e1") == (kind: "king", color: "white"), message: "e1 white king")
#assert(pa.turn == "w" and pa.fullmove == 1, message: "default move state")
#assert(not ("board" in pa), message: "the field is `squares`, not `board`")

// Bare squares-dict form.
#let pd = position(("e4": (kind: "pawn", color: "white")))
#assert(pd.squares.at("e4").kind == "pawn", message: "dict form keeps the squares")

// FEN now exposes squares + variant + geometry.
#let pf = parse-fen(starting-fen)
#assert(pf.squares.at("e1") == (kind: "king", color: "white"), message: "FEN -> squares")
#assert(pf.variant == "standard" and pf.cols == 8 and pf.rows == 8, message: "FEN geometry")

// `chess-board` is the standard-chess alias of `board` (same function).
#assert(chess-board == board, message: "chess-board aliases board")

#chess-board(pa, size: 4cm, labels: false)
