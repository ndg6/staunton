// ===========================================================================
// Coordinate system & square addressing.
//
// We use algebraic square names ("a1" .. "h8"). Internally a square is a pair
// of zero-based integer indices:
//
//   col : file a..h  ->  0..7   (a = 0, h = 7),  increases left -> right
//   row : rank 1..8  ->  0..7   (rank 1 = 0),    increases bottom -> top
//
// IMPORTANT off-by-one zone: Typst's drawing origin is the TOP-left and the
// y-axis points DOWN, while chess rank 1 is at the BOTTOM. The screen flip is
// therefore  dy = (7 - row) * square_size  and lives ONLY in the renderer.
// This module always speaks in chess-native (col, row).
// ===========================================================================

#let file-letters = ("a", "b", "c", "d", "e", "f", "g", "h")
#let rank-digits = ("1", "2", "3", "4", "5", "6", "7", "8")

/// Parse an algebraic square name into zero-based indices.
/// Capitalisation does not matter: "E4" and "e4" are equivalent.
/// -> (col: int, row: int)
#let parse-square(square) = {
  assert(type(square) == str, message: "square must be a string like \"e4\", got: " + repr(square))
  let s = lower(square).trim()
  assert(s.len() == 2, message: "square must be two characters like \"e4\", got: \"" + square + "\"")
  let file = s.at(0)
  let rank = s.at(1)
  let col = file-letters.position(c => c == file)
  assert(col != none, message: "invalid file in \"" + square + "\" (must be a-h)")
  assert(rank-digits.contains(rank), message: "invalid rank in \"" + square + "\" (must be 1-8)")
  (col: col, row: int(rank) - 1)
}

/// Inverse of `parse-square`: (col, row) -> "e4".
#let square-name(col, row) = {
  assert(0 <= col and col <= 7, message: "col out of range 0..7: " + repr(col))
  assert(0 <= row and row <= 7, message: "row out of range 0..7: " + repr(row))
  file-letters.at(col) + str(row + 1)
}

/// Is the square dark? a1 (0,0) is a dark square in standard orientation.
#let is-dark-square(col, row) = calc.even(col + row)
