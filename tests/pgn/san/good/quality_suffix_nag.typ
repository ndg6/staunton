// Asserting test: SAN CLEANLINESS after the D2 fix (src/pgn.typ). A move-quality
// suffix glyph ("!", "?", "!!", "??", "!?", "?!") is now stripped from `san` at
// parse time and recorded as the equivalent NAG code ($1..$6) in `nags`. `+`/`#`
// stay in `san` (they are check/mate markers, not quality assessments). If an
// EXPLICIT quality NAG ($1..$6) is already present on the move, it wins and the
// glyph is discarded rather than doubled.
#import "/lib.typ": game, movetext, with-nags, position-after, notation
#import "/src/game.typ": _origin-of

// --- plain suffix glyph is stripped, converted to the matching NAG ----------
#let g1 = game("1. e4! e5 *")
#let n1 = movetext(g1).first()
#assert.eq(n1.san, "e4", message: "quality suffix must not remain in `san`")
#assert.eq(n1.nags, ("1",), message: "'!' converts to NAG $1")

// --- check/mate markers stay in `san`; the suffix is still stripped --------
// Scholar's mate: a real, well-known legal mating line (not invented for this
// test) so the "#" is a genuine checkmate marker, not just parsed text.
#let g2 = game("1. e4 e5 2. Bc4 Nc6 3. Qh5 Nf6 4. Qxf7#!! *")
#let n2 = movetext(g2).at(6)
#assert.eq(n2.san, "Qxf7#", message: "'#' must stay in `san`")
#assert.eq(n2.nags, ("3",), message: "'!!' converts to NAG $3")

// --- an explicit $n NAG wins over the suffix glyph; never doubled ----------
#let g3 = game("1. e4! $1 e5 *")
#let n3 = movetext(g3).first()
#assert.eq(n3.nags, ("1",), message: "explicit $1 plus '!' suffix must not double up")

// --- suffix glyph is inserted BEFORE an unrelated explicit NAG -------------
#let g4 = game("1. e4! $14 e5 *")
#let n4 = movetext(g4).first()
#assert.eq(n4.nags, ("1", "14"), message: "suffix-derived code goes first")

// --- variation nodes get the same treatment ---------------------------------
#let g5 = game("1. e4 e5 (1... c5! 2. Nf3) *")
#let var-n0 = movetext(g5).at(1).variations.first().first()
#assert.eq(var-n0.san, "c5", message: "suffix stripped inside a variation too")
#assert.eq(var-n0.nags, ("1",), message: "variation move '!' converts to NAG $1")

// --- across a game using every grade, no `san` ends in a quality glyph ------
// This fixture is already used (and known legal) at
// tests/board/style_options/defaults_walkthrough.typ:28.
//
// A "san is clean" check ALONE cannot tell a correct strip from data loss: if
// the glyph were silently DESTROYED instead of converted (the exact bug this
// sheet exists to catch), `san` would still be clean and this would still
// pass. So each move is checked as a PAIR -- clean `san` AND the matching
// quality NAG code present -- enumerated explicitly rather than a predicate
// loop, so a failure names exactly which move/grade regressed.
#let g6 = game("1. e4! e5? 2. Nf3!! Nc6?? 3. Bb5!? a6?!")
#let g6-nodes = movetext(g6)
#let expected-grades = (
  (0, "e4", "1"),
  (1, "e5", "2"),
  (2, "Nf3", "3"),
  (3, "Nc6", "4"),
  (4, "Bb5", "5"),
  (5, "a6", "6"),
)
#for (i, san, nag) in expected-grades {
  let n = g6-nodes.at(i)
  assert.eq(n.san, san, message: "move " + str(i) + ": san must be clean, got " + repr(n.san))
  assert.eq(n.nags, (nag,), message: "move " + str(i) + " (" + san + "): expected NAG $" + nag + ", got " + repr(n.nags))
}

// --- LOSSLESSNESS: an exotic/unrecognised glyph run is left COMPLETELY alone,
// not silently stripped or emptied -- "!!!" and "?!?" are not one of the six
// recognised glyphs, so no NAG is added and `san` keeps the run verbatim.
#let g7 = game("1. e4!!! e5?!? *")
#let g7-nodes = movetext(g7)
#assert.eq(g7-nodes.at(0).san, "e4!!!", message: "unrecognised 3-glyph run must stay in san verbatim")
#assert.eq(g7-nodes.at(0).nags, (), message: "unrecognised run must not synthesize a NAG")
#assert.eq(g7-nodes.at(1).san, "e5?!?", message: "unrecognised run must stay in san verbatim (2)")
#assert.eq(g7-nodes.at(1).nags, (), message: "unrecognised run must not synthesize a NAG (2)")

// --- a STANDALONE glyph token (nothing in front of it) is also left alone --
// `_split-quality-suffix` requires something to remain IN FRONT of the run, so
// a bare "?!" token (whitespace-separated from the move before it) keeps its
// text as-is rather than being stripped down to an EMPTY san. An empty san
// would be a real bug: it would not surface here but would die downstream in
// src/san.typ ("empty SAN token") without naming which token was at fault --
// so this sheet is the place that actually catches it, at the source.
#let g8 = game("1. e4 ?! e5 *")
#let g8-nodes = movetext(g8)
#assert.eq(g8-nodes.len(), 3, message: "the standalone glyph token becomes its own (odd) node, not swallowed")
#assert.eq(g8-nodes.at(1).san, "?!", message: "standalone glyph token must NOT become an empty san")
#assert.eq(g8-nodes.at(1).nags, (), message: "standalone glyph token gets no NAG (nothing precedes it)")

// --- the move-quality badge still derives from the converted NAG -----------
#assert.eq(
  position-after(game("1. e4 e5 2. Nf3! *"), "2w").at("_origin").quality,
  (square: "f3", symbol: "!"),
  message: "badge must still derive after suffix->NAG conversion",
)

`san` cleanliness after suffix->NAG conversion: verified for a plain suffix, a check/mate marker, explicit-NAG precedence, ordering, variations, all six grades, and the move-quality badge.
