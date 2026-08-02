// Asserting test: POSITION SHAPE INVARIANT after a move (regression guard for a
// fixed defect). `engine.typ`'s `apply()` used to end each move with a bare
// `board.remove(from-name)` statement — `dict.remove(k)` RETURNS the removed
// value, and a bare statement's value joins into the block's result, so the
// removed piece's `(kind, color)` leaked in as stray TOP-LEVEL keys on the
// returned position. Two positions denoting the same chess position then
// compared unequal (the leaky one carried extra keys the clean one didn't).
//
// This is asserted through the round trip `play` -> `to-fen` -> `position`:
// if `play`'s result carried stray keys, it would still equal itself trivially,
// so the real check is that it equals the INDEPENDENTLY-REBUILT position that
// `position(to-fen(..))` produces — a dict with only the canonical keys.
#import "/lib.typ": play, to-fen, position

#let expected-keys = (
  "variant", "cols", "rows", "squares", "turn", "castling", "en-passant", "halfmove", "fullmove",
).sorted()

// Every line below is VERIFIED legal chess (see task spec). Each exercises a
// different move `kind` in `apply()`, since the leaky statement sat once per
// kind (normal move, en-passant, castling, capture, promotion).
#let cases = (
  ("quiet", "1. Nf3"),
  ("castle O-O", "1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. d3 d6 5. O-O"),
  ("castle O-O-O", "1. d4 d5 2. Nc3 Nf6 3. Bf4 Bf5 4. Qd2 Qd7 5. O-O-O"),
  ("en passant", "1. e4 d5 2. e5 f5 3. exf6"),
  ("capture", "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Bxc6"),
  ("promotion", "1. e4 d5 2. exd5 c6 3. dxc6 Bf5 4. cxb7 e6 5. bxa8=Q"),
)

#for (label, line) in cases {
  let played = play(none, line)
  let rebuilt = position(to-fen(played))

  assert.eq(played, rebuilt, message: "round trip mismatch for " + label)
  assert.eq(played.keys().sorted(), expected-keys, message: "key set wrong for " + label)
  assert("kind" not in played, message: "'kind' leaked as a top-level key for " + label)
  assert("color" not in played, message: "'color' leaked as a top-level key for " + label)
}

`play` result: no stray `kind`/`color` keys, and equals its own FEN round trip, for every move kind.
