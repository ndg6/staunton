// Phase 2: with-variation(game, at:, moves:) adds a RAV as an alternative to the
// move at `at`. `moves` is a PGN movetext fragment (parsed like parse-pgn), so it
// may carry nested () variations, $n NAGs and {comments}; a plain SAN run is the
// simple case. It composes with with-nags/with-comments, navigates like a parsed
// game, and never mutates the source.
#import "/lib.typ": parse-pgn, chess-notation, with-variation, with-nags, position-after, play-moves

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let g = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 *").first()
#let s(x) = chess-notation(x, variations: true, nags: true, comments: true, lang: "en", diagrams: false)
#let base = "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6"

// --- plain variation (SAN run) at a White move ------------------------------
#assert(s(with-variation(g, at: "3w", moves: "Bc4 Bc5")) == "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4 Bc5) 3... a6", message: "plain variation at 3w")

// --- rich fragment: suffix glyph, {comment}, and a nested variation ---------
#assert(
  s(with-variation(g, at: "3w", moves: "3. Bc4 Bc5! (3... Nf6 4. d4) {main alt}"))
    == "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4 Bc5! main alt (3... Nf6 4. d4)) 3... a6",
  message: "annotated + nested fragment",
)

// --- variation at a Black move (numbered 3... ...) --------------------------
#assert(s(with-variation(g, at: "3b", moves: "3... Nf6 4. O-O")) == "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 (3... Nf6 4. O-O)", message: "variation at a black move")

// --- two variations at one move append (into 0, into 1) ---------------------
#assert(
  s(with-variation(with-variation(g, at: "3w", moves: "Bc4"), at: "3w", moves: "d4"))
    == "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4) (3. d4) 3... a6",
  message: "two variations append",
)

// --- compose: annotate a move INSIDE the just-added variation ---------------
#let bc4 = (line: ((at: "3w", into: 0),), at: "3w")
#assert(
  s(with-nags(with-variation(g, at: "3w", moves: "Bc4 Bc5"), ((bc4, "!!"),)))
    == "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4!! Bc5) 3... a6",
  message: "with-nags into an added variation",
)

// --- navigation into the added line is legal + correct (lazy legality) ------
#let gv = with-variation(g, at: "3w", moves: "Bc4 Bc5")
#assert(
  position-after(gv, (line: ((at: "3w", into: 0),), at: "3b")).squares
    == play-moves(none, "1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5").squares,
  message: "position-after navigates into the added variation",
)

// --- source game is untouched -----------------------------------------------
#let _ = with-variation(g, at: "3w", moves: "Bc4 Bc5")
#assert(s(g) == base, message: "source untouched")

= with-variation
#s(with-variation(g, at: "3w", moves: "Bc4 Bc5! {a sharp alternative} (3... Nf6 4. O-O)"))
