// PGN (good) - a game whose start is a FEN/SetUp custom position must number
// its DISPLAY (`notation`, captions) and its ADDRESSING (locators, `move-at`)
// from the game's own starting move, not from move 1. This is the regression
// guard for a bug where both halves were silently renumbered from 1: display
// and locators are asserted TOGETHER in each fixture below, on purpose --
// fixing only one half is worse than the original bug (a diagram captioned
// "Position after 3. Bb5" that a locator addressed as move 1 would be a new,
// silent way for the two to disagree), so a partial fix must fail this sheet.
#import "/lib.typ": game, move-at, notation, _pgn-caption

#let s(src, ..a) = notation(src, ..((diagrams: false, bold-mainline: false, spaced: true, nags: false, comments: false, variations: false, lang: "en") + a.named()))

// A small helper: the auto-caption text for the move at `at`, built exactly the
// way `diagram`'s default caption is (see lib.typ's `_pgn-caption` call site).
#let caption-at(g, at) = {
  let mv = move-at(g, at: at)
  _pgn-caption(mv.locator, mv.san, mv.quality, "en")
}

// --- (1) White-to-move mid-game start (the reported case) ------------------
#let g1 = game(```
[FEN "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3"] [SetUp "1"]
3. Bb5 a6 4. Ba4 Nf6 *
```)
#assert.eq(s(g1), "3. Bb5 a6 4. Ba4 Nf6", message: "notation must number from the FEN's own move 3, not 1")
#assert.eq(move-at(g1, at: "3w").san, "Bb5", message: "locator 3w must resolve to White's 3rd move in THIS game's numbering")
#assert.eq(move-at(g1, at: "4w").san, "Ba4", message: "locator 4w must resolve to White's 4th move")
#assert.eq(caption-at(g1, "3w"), "Position after 3. Bb5", message: "caption must use the game's own move number")

// --- (2) Black-to-move mid-game start (the subtle one: ply 1 is Black's) ---
#let g2 = game(```
[FEN "r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/2N2N2/PPPP1PPP/R1BQK2R b KQkq - 6 12"] [SetUp "1"]
12... O-O 13. O-O d6 *
```)
#assert.eq(s(g2), "12... O-O 13. O-O d6", message: "notation must print the Black-to-move start with the \"12...\" ellipsis prefix, not \"12.\"")
#assert.eq(move-at(g2, at: "12b").san, "O-O", message: "locator 12b must resolve to ply 1 (the FEN's own side to move)")
#assert.eq(move-at(g2, at: "12b").color, "black", message: "ply 1 must be recognised as a BLACK move -- the numbering must not assume White starts")
#assert.eq(move-at(g2, at: "13w").san, "O-O", message: "locator 13w must resolve to White's next move")
#assert.eq(caption-at(g2, "12b"), "Position after 12... O-O", message: "caption for a Black-start move must keep the \"12...\" ellipsis")

// --- (3) offset zero: a normal move-1 start is completely unchanged --------
#let g3 = game("[White \"A\"][Black \"B\"]
1. e4 e5 2. Nf3 Nc6 *")
#assert.eq(s(g3), "1. e4 e5 2. Nf3 Nc6", message: "no [FEN]/[SetUp] -> offset zero, notation unchanged")
#assert.eq(move-at(g3, at: "2w").san, "Nf3", message: "offset zero -> locator 2w unchanged")
#assert.eq(caption-at(g3, "2w"), "Position after 2. Nf3", message: "offset zero -> caption unchanged")

// --- (4) a bare SAN string/array (no game) still numbers from 1 ------------
// There is no game and so no start tag to read an offset from -- this path
// must stay exactly as before.
#assert.eq(s("1. e4 e5 2. Nf3"), "1. e4 e5 2. Nf3", message: "bare SAN string numbers from 1")
#assert.eq(s(("e4", "e5", "Nf3")), "1. e4 e5 2. Nf3", message: "bare SAN array numbers from 1")

= Custom-start move numbering OK
Display (`notation`/captions) and addressing (`move-at` locators) agree on the
game's own starting move number, for both a White-to-move and a Black-to-move
custom start; a normal move-1 game and a bare SAN source are unaffected.
