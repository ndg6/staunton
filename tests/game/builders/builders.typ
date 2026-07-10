// Phase 1 game builders: with-nags / with-comments annotate an EXISTING move
// anywhere in the tree (mainline or inside a nested variation), addressed by a
// mainline locator ("3w") or a variation path dict. They return a NEW game
// (stash-based), compose, and never mutate the source. Rendered via notation.
#import "/lib.typ": parse-pgn, chess-notation, with-nags, with-comments

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let g = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4 Bc5) a6 *").first()
#let bc4 = (line: ((at: "3w", into: 0),), at: "3w")   // Bc4, inside the variation
#let bc5 = (line: ((at: "3w", into: 0),), at: "3b")   // Bc5, inside the variation
// all switches explicit -> plain string (assertable)
#let s(x) = chess-notation(x, variations: true, nags: true, comments: true, lang: "en", diagrams: false, bold-mainline: false, spaced: true)

#let base = "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4 Bc5) 3... a6"
#assert(s(g) == base, message: "baseline (unbuilt) render")

// --- with-nags: mainline (dict form, backward compatible) -------------------
#assert(s(with-nags(g, ("3w": "!"))) == "1. e4 e5 2. Nf3 Nc6 3. Bb5! (3. Bc4 Bc5) 3... a6", message: "mainline nag, dict form")
// --- with-nags: same via the array-of-pairs form ----------------------------
#assert(s(with-nags(g, (("3w", "!"),))) == "1. e4 e5 2. Nf3 Nc6 3. Bb5! (3. Bc4 Bc5) 3... a6", message: "mainline nag, pairs form")
// --- with-nags: a move INSIDE the variation (path locator) ------------------
#assert(s(with-nags(g, ((bc4, "!!"),))) == "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4!! Bc5) 3... a6", message: "nag inside a variation")

// --- with-comments: mainline and inside a variation -------------------------
#assert(s(with-comments(g, ("3w": "main note"))) == "1. e4 e5 2. Nf3 Nc6 3. Bb5 main note (3. Bc4 Bc5) 3... a6", message: "comment on a mainline move")
#assert(s(with-comments(g, ((bc4, "sharp"),))) == "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4 sharp Bc5) 3... a6", message: "comment inside a variation")

// --- composition: build up, then render as one ------------------------------
#assert(
  s(with-comments(with-nags(g, ("3w": "!")), ((bc5, "counter"),)))
    == "1. e4 e5 2. Nf3 Nc6 3. Bb5! (3. Bc4 Bc5 counter) 3... a6",
  message: "compose with-comments . with-nags",
)

// --- the source game is never mutated ---------------------------------------
#let _ = with-nags(with-comments(g, ((bc4, "x"),)), ("3w": "?"))
#assert(s(g) == base, message: "source untouched after building")

= Phase 1 builders
#s(with-comments(with-nags(g, ("3w": "!")), ((bc4, "the alternative"),)))
