// Canonical-string asserts for `move-to-san` on hand-built positions: one rule
// per case, each isolated on its own FEN so the assertion pins down exactly the
// behaviour named in its comment.
#import "/lib.typ": parse-fen, starting-fen, legal-moves, move-to-san
#import "/src/coords.typ": parse-square

// The one legal move between two squares (optionally filtered by promotion
// piece, for the two candidate promotions from the same pawn push).
#let move-at(pos, from, to, promotion: none) = {
  let f = parse-square(from)
  let t = parse-square(to)
  let cand = legal-moves(pos).filter(m =>
    m.from == (f.col, f.row) and m.to == (t.col, t.row)
      and (promotion == none or m.promotion == promotion)
  )
  assert(cand.len() == 1, message: "move-at: expected exactly one legal move " + from + "-" + to + ", got " + str(cand.len()))
  cand.first()
}

#set page(width: auto, height: auto, margin: 1cm)

// Plain pawn push.
#let start = parse-fen(starting-fen)
#assert(move-to-san(start, move-at(start, "e2", "e4")) == "e4", message: "plain pawn push")

// Pawn capture.
#let cap-pos = parse-fen("4k3/8/8/3p4/4P3/8/8/4K3 w - - 0 1")
#assert(move-to-san(cap-pos, move-at(cap-pos, "e4", "d5")) == "exd5", message: "pawn capture")

// En passant, written as a plain capture (no special "e.p." marker).
#let ep-pos = parse-fen("4k3/8/8/3pP3/8/8/8/4K3 w - d6 0 1")
#assert(move-to-san(ep-pos, move-at(ep-pos, "e5", "d6")) == "exd6", message: "en passant as plain capture")

// Promotion with check (not mate: the black king has a7 to run to).
#let promo-pos = parse-fen("k7/4P3/8/8/8/8/8/4K3 w - - 0 1")
#assert(
  move-to-san(promo-pos, move-at(promo-pos, "e7", "e8", promotion: "queen")) == "e8=Q+",
  message: "promotion with check",
)

// Non-queen promotion, same square: e8=N gets NO spurious disambiguator even
// though the queen promotion e8=Q from the same pawn is also legal. (The
// knight on e8 does not attack a8, so unlike e8=Q+ there is no check suffix.)
#assert(
  move-to-san(promo-pos, move-at(promo-pos, "e7", "e8", promotion: "knight")) == "e8=N",
  message: "underpromotion without spurious disambiguator",
)

// Promotion captures onto the SAME square from different files: pawn-capture
// SAN always carries the from-file, so the two moves self-disambiguate as
// bxc8=Q vs dxc8=Q from one position. (Black king on h1, off every line of
// the new c8 queen, so no check suffix.)
#let promo-cap-pos = parse-fen("2r5/1P1P4/8/8/8/8/8/4K2k w - - 0 1")
#assert(
  move-to-san(promo-cap-pos, move-at(promo-cap-pos, "b7", "c8", promotion: "queen")) == "bxc8=Q",
  message: "promotion capture from the b-file",
)
#assert(
  move-to-san(promo-cap-pos, move-at(promo-cap-pos, "d7", "c8", promotion: "queen")) == "dxc8=Q",
  message: "promotion capture from the d-file",
)

// Stalemate: Qb6 leaves the a8 king with no moves (a7, b7 and b8 are all
// covered by the queen) but NOT in check -- stalemate is not check, so the
// SAN gets NO suffix at all.
#let stale-pos = parse-fen("k7/8/8/2Q5/8/8/8/6K1 w - - 0 1")
#assert(move-to-san(stale-pos, move-at(stale-pos, "c5", "b6")) == "Qb6", message: "stalemate gets no suffix")

// Checkmate: Ra8# traps the king behind its own f7/g7/h7 pawns.
#let mate-pos = parse-fen("6k1/5ppp/8/8/8/8/8/R3K3 w - - 0 1")
#assert(move-to-san(mate-pos, move-at(mate-pos, "a1", "a8")) == "Ra8#", message: "checkmate suffix")

// Castling, both sides, from the same position (side-based, so both are legal
// candidates without having to play one first).
#let castle-pos = parse-fen("r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
#let castle-moves = legal-moves(castle-pos)
#let king-side = castle-moves.filter(m => m.kind == "castle-k").first()
#let queen-side = castle-moves.filter(m => m.kind == "castle-q").first()
#assert(move-to-san(castle-pos, king-side) == "O-O", message: "king-side castle")
#assert(move-to-san(castle-pos, queen-side) == "O-O-O", message: "queen-side castle")

// File disambiguation: rooks on d8 and f1 can both reach f8; they differ by
// file, so the file letter alone disambiguates. (Black king on a4, off the
// rank/file the rook lands on, so the move carries no check suffix.)
#let file-pos = parse-fen("3R4/8/8/8/k7/8/8/5R1K w - - 0 1")
#assert(move-to-san(file-pos, move-at(file-pos, "d8", "f8")) == "Rdf8", message: "file disambiguation")

// Rank disambiguation: rooks on a1 and a5 share a file, so the rank digit
// disambiguates instead.
#let rank-pos = parse-fen("4k3/8/8/8/R7/8/8/R3K3 w - - 0 1")
#assert(move-to-san(rank-pos, move-at(rank-pos, "a1", "a3")) == "R1a3", message: "rank disambiguation")

// Double disambiguation: three queens (h4, h1, b4) can all reach e1; h4 shares
// a file with h1 and a rank with b4, so neither letter alone disambiguates and
// the full origin square is needed. (Black king on a6, off every line the
// three queens or the landing square e1 attack, so no check suffix.)
#let three-q-pos = parse-fen("8/8/k7/8/1Q5Q/8/8/K6Q w - - 0 1")
#assert(move-to-san(three-q-pos, move-at(three-q-pos, "h4", "e1")) == "Qh4e1", message: "double disambiguation")

// Pinned piece: the rook on e5 is pinned to the king on e1 by the black rook on
// e8, so its geometrically-possible move to b5 is ILLEGAL and must not be
// counted as a disambiguation candidate for the b1 rook's legal Rb5.
#let pin-pos = parse-fen("4r2k/8/8/4R3/8/8/8/1R2K3 w - - 0 1")
#assert(move-to-san(pin-pos, move-at(pin-pos, "b1", "b5")) == "Rb5", message: "pinned piece must not force disambiguation")

= move-to-san: canonical SAN on constructed positions

Each assertion above pins down one encoding rule: plain pushes, captures, en
passant, promotion with check, underpromotion, self-disambiguating promotion
captures, stalemate (no suffix), checkmate, both castles, file/rank/double
disambiguation, and the classic pinned-piece non-disambiguation case.
