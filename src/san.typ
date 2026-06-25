// ===========================================================================
// SAN (Standard Algebraic Notation) resolution.
//
// `san-to-move(position, san)` interprets one SAN token against a position by
// matching it to exactly one of the position's *legal* moves. This is why a
// full legal generator is required: disambiguation in SAN is only omitted when
// a single move is legal (e.g. the other candidate is pinned).
//
// A move that matches zero legal moves is illegal/unresolvable -> hard error.
// A move that matches more than one is ambiguous -> hard error.
// ===========================================================================

#import "coords.typ": parse-square, file-letters, rank-digits
#import "engine.typ": legal-moves, apply, in-check

#let _promo-map = (Q: "queen", R: "rook", B: "bishop", N: "knight")
#let _piece-map = (K: "king", Q: "queen", R: "rook", B: "bishop", N: "knight")

// Strip trailing check/mate/annotation symbols (+ # ! ?).
#let _clean(san) = {
  let s = san
  while s.len() > 0 and ("+", "#", "!", "?").contains(s.slice(s.len() - 1)) {
    s = s.slice(0, s.len() - 1)
  }
  s
}

/// Resolve a SAN string to a concrete legal move dict for `position`.
#let san-to-move(position, san) = {
  let color = if position.turn == "w" { "white" } else { "black" }
  let legal = legal-moves(position)
  let s = _clean(san)
  assert(s.len() > 0, message: "empty SAN token")

  // castling (check the longer pattern first)
  if s == "O-O-O" or s == "0-0-0" {
    let cand = legal.filter(m => m.kind == "castle-q")
    assert(cand.len() == 1, message: "illegal queen-side castling \"" + san + "\" for " + color)
    return cand.first()
  }
  if s == "O-O" or s == "0-0" {
    let cand = legal.filter(m => m.kind == "castle-k")
    assert(cand.len() == 1, message: "illegal king-side castling \"" + san + "\" for " + color)
    return cand.first()
  }

  // promotion suffix "=Q"
  let promo = none
  if s.contains("=") {
    let parts = s.split("=")
    assert(parts.len() == 2 and parts.at(1).len() >= 1, message: "malformed promotion in SAN: " + san)
    s = parts.at(0)
    let pl = parts.at(1).slice(0, 1)
    assert(_promo-map.keys().contains(pl), message: "invalid promotion piece in SAN: " + san)
    promo = _promo-map.at(pl)
  }

  let cs = s.clusters()
  assert(cs.len() >= 2, message: "unparseable SAN: " + san)
  // destination is the trailing "<file><rank>"
  let dest = cs.at(cs.len() - 2) + cs.at(cs.len() - 1)
  let dsq = parse-square(dest) // hard error if not a valid square

  let prefix = cs.slice(0, cs.len() - 2)
  let piece = "pawn"
  let idx = 0
  if prefix.len() > 0 and _piece-map.keys().contains(prefix.at(0)) {
    piece = _piece-map.at(prefix.at(0))
    idx = 1
  }
  // remaining prefix chars: optional from-file, from-rank, and 'x'
  let from-file = none
  let from-rank = none
  for ch in prefix.slice(idx) {
    if file-letters.contains(ch) {
      from-file = file-letters.position(x => x == ch)
    } else if rank-digits.contains(ch) {
      from-rank = int(ch) - 1
    } else if ch == "x" {
      // capture indicator; not needed for matching
    } else {
      assert(false, message: "unexpected character '" + ch + "' in SAN: " + san)
    }
  }

  let cand = legal.filter(m =>
    m.piece == piece
      and m.to.at(0) == dsq.col and m.to.at(1) == dsq.row
      and (from-file == none or m.from.at(0) == from-file)
      and (from-rank == none or m.from.at(1) == from-rank)
  )
  // a non-promotion SAN must not match promotion moves, and vice versa
  cand = if promo == none {
    cand.filter(m => m.kind != "promotion")
  } else {
    cand.filter(m => m.kind == "promotion" and m.promotion == promo)
  }

  assert(cand.len() != 0, message: "illegal or unresolvable move \"" + san + "\" for " + color)
  assert(cand.len() == 1, message: "ambiguous move \"" + san + "\" matches " + str(cand.len()) + " legal moves")
  cand.first()
}

/// Convenience: resolve a SAN and return the resulting position.
#let play-san(position, san) = apply(position, san-to-move(position, san))
