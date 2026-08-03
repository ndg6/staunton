// Asserting test: 2.0.0 Phase B' localized movetext input (`lang:`). This is
// THE HAZARD test: "R" is the ROOK in English but the KING in Spanish (and
// French/Italian/Portuguese). Both readings are legal moves from the SAME
// starting position, so a wrong (or ignored) language silently produces a
// DIFFERENT game instead of an error -- there is no crash to catch it.
//
// Both directions are asserted in this ONE sheet on purpose: a test that only
// checked the English reading would also pass if `lang:` were ignored
// entirely (English is the default), because "Rf1" would still mean rook.
// Only the Spanish assertion -- that the SAME letter "R" resolves to the KING
// -- actually exercises the `lang:` argument. Do not split this into two
// sheets or drop either half.
#import "/lib.typ": game, position-after

#let sq(pos, name) = pos.squares.at(name, default: none)

// English: 1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. d3 d6 5. Rf1
// (Rf1 = the a1-rook returns to f1 after castling rights were never used --
// a quiet developing move, verified legal.)
#let g-en = game("1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. d3 d6 5. Rf1", lang: "en")
#let p-en = position-after(g-en, at: "5w")
#assert(
  sq(p-en, "f1") != none and sq(p-en, "f1").kind == "rook" and sq(p-en, "f1").color == "white",
  message: "en: f1 must hold the white rook, got " + repr(sq(p-en, "f1")),
)
#assert(
  sq(p-en, "e1") != none and sq(p-en, "e1").kind == "king" and sq(p-en, "e1").color == "white",
  message: "en: e1 must still hold the white king, got " + repr(sq(p-en, "e1")),
)

// Spanish, same shape with Spanish letters: 1. e4 e5 2. Cf3 Cc6 3. Ac4 Ac5
// 4. d3 d6 5. Rf1 -- here "R" is Rey (king), so this is 5. Kf1, the SAME
// letter as the English rook move above but a DIFFERENT piece and a
// DIFFERENT resulting position.
#let g-es = game("1. e4 e5 2. Cf3 Cc6 3. Ac4 Ac5 4. d3 d6 5. Rf1", lang: "es")
#let p-es = position-after(g-es, at: "5w")
#assert(
  sq(p-es, "f1") != none and sq(p-es, "f1").kind == "king" and sq(p-es, "f1").color == "white",
  message: "es: f1 must hold the white king (Rey), got " + repr(sq(p-es, "f1")),
)
#assert(
  sq(p-es, "e1") == none,
  message: "es: e1 must now be EMPTY (the king vacated it), got " + repr(sq(p-es, "e1")),
)

= lang hazard OK

Both readings of the letter "R" are exercised from the identical movetext
shape: the English game ends with the rook on f1 and the king still on e1;
the Spanish game (Rey = king) ends with the king on f1 and e1 empty. A
`lang:` argument that were ignored, or that always fell back to English,
would make the Spanish assertions fail.
