// Phase 4: with-line(game, at:, moves:) adds a RAV as an alternative to the
// move at `at` (branch mode, `at:` present). `moves` is a PGN movetext fragment
// (parsed like `game(..)`), so it may carry nested () variations, $n NAGs and
// {comments}; a plain SAN run is the simple case. It composes with
// with-nags/with-comments, navigates like a parsed game, and never mutates the
// source. (The continuation mode, `at:` absent, is covered in with_line_continue.typ.)
#import "/lib.typ": game, notation, with-line, with-nags, play, move-at
#import "/src/game.typ": _position-after

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let g = game("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 *")
#let s(x) = notation(x, variations: true, nags: true, comments: true, lang: "en", diagrams: false, bold-mainline: false, spaced: true)
#let base = "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6"

// --- plain variation (SAN run) at a White move ------------------------------
#assert(s(with-line(g, at: "3w", moves: "Bc4 Bc5")) == "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4 Bc5) 3... a6", message: "plain variation at 3w")

// --- rich fragment: suffix glyph, {comment}, and a nested variation ---------
#assert(
  s(with-line(g, at: "3w", moves: "3. Bc4 Bc5! (3... Nf6 4. d4) {main alt}"))
    == "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4 Bc5! main alt (3... Nf6 4. d4)) 3... a6",
  message: "annotated + nested fragment",
)

// --- variation at a Black move (numbered 3... ...) --------------------------
#assert(s(with-line(g, at: "3b", moves: "3... Nf6 4. O-O")) == "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 (3... Nf6 4. O-O)", message: "variation at a black move")

// --- two variations at one move append (into 0, into 1) ---------------------
#assert(
  s(with-line(with-line(g, at: "3w", moves: "Bc4"), at: "3w", moves: "d4"))
    == "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4) (3. d4) 3... a6",
  message: "two variations append",
)

// --- compose: annotate a move INSIDE the just-added variation ---------------
#let bc4 = (line: ((at: "3w", into: 0),), at: "3w")
#assert(
  s(with-nags(with-line(g, at: "3w", moves: "Bc4 Bc5"), nags: ((bc4, "!!"),)))
    == "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4!! Bc5) 3... a6",
  message: "with-nags into an added variation",
)

// --- navigation into the added line is legal + correct (lazy legality) ------
#let gv = with-line(g, at: "3w", moves: "Bc4 Bc5")
#assert(
  _position-after(gv, at: (line: ((at: "3w", into: 0),), at: "3b")).squares
    == play(none, moves: "1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5").squares,
  message: "_position-after navigates into the added variation",
)

// --- source game is untouched -----------------------------------------------
#let _ = with-line(g, at: "3w", moves: "Bc4 Bc5")
#assert(s(g) == base, message: "source untouched")

// --- moves: is normalized to the game's language before being spliced in ---
// (bug fix, branch half): a German game's `moves:` fragment must be stored
// as canonical English SAN inside the variation, never left in German.
#let gde = game("1. e4 e5 2. Sf3 *", lang: "de")
#let gdeb = with-line(gde, at: "2w", moves: "Lc4")
#assert.eq(
  move-at(gdeb, at: (line: ((at: "2w", into: 0),), at: "2w")).san,
  "Bc4",
  message: "branch variation stores canonical English SAN (\"Bc4\"), not the German \"Lc4\"",
)

= with-line (branch)
#s(with-line(g, at: "3w", moves: "Bc4 Bc5! {a sharp alternative} (3... Nf6 4. O-O)"))
