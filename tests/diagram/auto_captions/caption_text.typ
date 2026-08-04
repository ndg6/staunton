// Asserting test: the automatic "Position after …" caption TEXT.
//
// This exists because the caption was silently changed once and nothing caught
// it: Phase A of 2.0.0 moved the move-quality glyph out of `san` and into a NAG,
// and the caption — built from `san` — quietly lost the grade
// ("Position after 3... Nf6??" became "Position after 3... Nf6"). The suite
// stayed green because the only sheet showing a graded caption is render-only
// and the one caption assertion used an ungraded move. A pixel diff against the
// previous commit found it, which is not a repeatable gate — this is.
//
// The grade belongs in the caption because the move-quality BADGE is OFF by
// default (`move-quality: false`), so for most documents the caption is the only
// place a grade appears at all.
#import "/lib.typ": _pgn-caption

// --- the grade is appended, for either colour ------------------------------
#assert.eq(_pgn-caption("3b", "Nf6", (square: "f6", symbol: "??"), "en"),
  "Position after 3... Nf6??", message: "black move, graded")
#assert.eq(_pgn-caption("2w", "Nf3", (square: "f3", symbol: "!!"), "en"),
  "Position after 2. Nf3!!", message: "white move, graded")

// --- an ungraded move gets no glyph and no stray spacing -------------------
#assert.eq(_pgn-caption("3b", "Nf6", none, "en"),
  "Position after 3... Nf6", message: "ungraded move must not gain a glyph")

// --- every grade symbol reaches the caption --------------------------------
#for sym in ("!", "?", "!!", "??", "!?", "?!") {
  assert.eq(_pgn-caption("1w", "e4", (square: "e4", symbol: sym), "en"),
    "Position after 1. e4" + sym, message: "grade " + sym + " must reach the caption")
}

// --- localization still wraps the (language-independent) glyph -------------
#assert.eq(_pgn-caption("3b", "Nf6", (square: "f6", symbol: "??"), "de"),
  "Stellung nach 3... Nf6??", message: "de caption keeps the grade")

= Automatic caption text OK

The grade is part of the caption, for both colours, all six symbols and in
translation; an ungraded move is unaffected.
