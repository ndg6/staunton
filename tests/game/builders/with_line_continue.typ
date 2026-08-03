// Phase 4: with-line(game, moves:) with `at:` OMITTED continues the mainline —
// the moves are appended to the END of the movetext instead of branching from
// it. Implemented as `_stash(game, movetext(game) + sub)`. `result` is a
// SEPARATE field from the node tree and is rendered by `notation` as a
// game-level token AFTER the moves, so continuing a DECISIVE game must never
// error and must never reset the result to "*" — it stays exactly as recorded
// (the real-world case: a game scored e.g. 1-0 on resignation, then played out
// for publication). Legality is checked lazily: `with-line` itself never plays
// out the position, so an illegal continuation is only caught later, when
// something navigates into it.
#import "/lib.typ": game, with-line, notation, mainline, move-at, position-after, play, to-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let s(x, ..a) = notation(x, ..((diagrams: false, bold-mainline: false, spaced: true, nags: false, comments: false, variations: true, lang: "en") + a.named()))

// --- 1) continue an OPEN game ("*") -----------------------------------------
#let g1 = game("1. e4 e5 *")
#let g1c = with-line(g1, moves: "2. Nf3 Nc6")
#assert.eq(mainline(g1c), ("e4", "e5", "Nf3", "Nc6"), message: "continued mainline (open game)")
#assert.eq(g1c.result, "*", message: "result stays \"*\" for an open game")
#assert.eq(s(g1c), "1. e4 e5 2. Nf3 Nc6", message: "rendered continuation (open game)")
// source untouched
#assert.eq(mainline(g1), ("e4", "e5"), message: "source mainline untouched (continue)")
#assert.eq(g1.result, "*", message: "source result untouched (continue)")

// --- 2) THE HEADLINE CASE: continue a DECISIVE game -------------------------
// A game recorded 1-0 because the loser resigned just before mate, then played
// out for publication: the appended moves must not error, and the "1-0" token
// must render AFTER them, unchanged.
#let g2 = game("1. e4 e5 1-0")
#let g2c = with-line(g2, moves: "2. Nf3")
#assert.eq(mainline(g2c), ("e4", "e5", "Nf3"), message: "continued mainline (decisive game)")
#assert.eq(g2c.result, "1-0", message: "result field unchanged after continuing a decisive game")
#assert.eq(
  s(g2c, result: true),
  "1. e4 e5 2. Nf3 1-0",
  message: "rendered: result token comes AFTER the appended moves, value unchanged",
)
// source untouched
#assert.eq(mainline(g2), ("e4", "e5"), message: "source mainline untouched (decisive continue)")
#assert.eq(g2.result, "1-0", message: "source result untouched (decisive continue)")

// --- 4) appended moves are addressable afterwards ---------------------------
#assert.eq(move-at(g2c, at: "2w").san, "Nf3", message: "move-at reaches an appended move")

// --- 5) composition: continuing a game that already has variations leaves ---
//        them intact, and with-line twice in a row accumulates -------------
#let g5 = game("1. e4 e5 (1... c5) *")
#let g5a = with-line(g5, moves: "2. Nf3 Nc6")
#let g5b = with-line(g5a, moves: "3. Bb5")
#assert.eq(mainline(g5b), ("e4", "e5", "Nf3", "Nc6", "Bb5"), message: "two continues accumulate")
#assert.eq(
  s(g5b),
  "1. e4 e5 (1... c5) 2. Nf3 Nc6 3. Bb5",
  message: "pre-existing variation at 1w survives both continuations",
)

// --- 6) moves: carrying its own (even wrong) move numbers ------------------
// `num` tokens are ignorable; a deliberately wrong number is simply ignored,
// not an error, and does not affect where the moves land.
#let g6 = game("1. e4 e5 *")
#let g6c = with-line(g6, moves: "9. Nf3 Nc6")
#assert.eq(mainline(g6c), ("e4", "e5", "Nf3", "Nc6"), message: "a wrong leading move number in `moves:` is ignored, not an error")

// --- 7) legality stays LAZY: an illegal continuation does not error at ------
//        with-line time; only navigating into it does ----------------------
#let g7 = game("1. e4 e5 *")
#let g7c = with-line(g7, moves: "2. Bxc6") // no White bishop can reach c6 in one move
#assert.eq(mainline(g7c), ("e4", "e5", "Bxc6"), message: "with-line accepts an illegal continuation without erroring")
// navigating into it is where legality is actually checked (backstop, not the
// focus of this sheet — see malformed/ for the dedicated expected-fail form)

// --- 8) `moves:` is normalized to the game's language BEFORE being spliced --
// into the mainline (bug fix): a German game's continuation must store
// canonical English SAN, never the German letters, so mainline/`to-fen` never
// see a leaked "S" (Springer) where English expects "N" (Knight).
#let gde = game("1. e4 e5 2. Sf3 *", lang: "de")
#let gdec = with-line(gde, moves: "2... Sc6 3. Lb5")
#assert.eq(mainline(gdec), ("e4", "e5", "Nf3", "Nc6", "Bb5"), message: "continued mainline is normalized to English SAN, not left in German")
#assert.eq(
  to-fen(gdec, at: "3w"),
  "r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3",
  message: "to-fen resolves correctly post-normalization (would panic on unnormalized \"Sc6\")",
)

// --- 9) `moves:` carrying a result-like token INSIDE a {comment} is fine ----
// (the negative side of the result-token guard below): the guard uses the
// PGN tokenizer, which never treats comment content as tokens, so this must
// keep working even though the literal text "1-0" appears in the fragment.
#let g9 = game("1. e4 e5 *")
#let g9c = with-line(g9, moves: "2. Nf3 {1-0 was agreed} Nc6")
#assert.eq(mainline(g9c), ("e4", "e5", "Nf3", "Nc6"), message: "a result-like string inside a {comment} is not mistaken for a result token")

// --- 10) FEN-start game continuation (locators are FEN-aware; lock-in) ------
#let gfen = game("[SetUp \"1\"][FEN \"r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 5 12\"] 12... Bc5 13. O-O *")
#let gfenc = with-line(gfen, moves: "13... Nf6 14. d3")
#assert.eq(move-at(gfenc, at: "14w").san, "d3", message: "continuation numbering keeps working from a FEN start")

= with-line (continue)
#s(g2c, result: true)
