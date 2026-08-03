// with-line (branch mode) composes: a game built from moves, a variation added at
// a mainline move, then a SECOND variation nested INSIDE that first variation (its
// `at` is a variation-path locator). Each step returns a NEW game (source intact).
// The final game is rendered in BLOCK style and asserted: block notation yields a
// `stack` of one `pad`ded line per rendered run, each variation parenthesised and
// indented one level per nesting depth. We assert the line texts (layout-agnostic)
// AND the indent levels; the inline form and an independent legality check back it
// up.
#import "/lib.typ": game, with-line, notation, position-after, play

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

// Fully-explicit options -> the plain-string / concrete-content fast paths
// (assertable). `diagrams: false` bypasses the lib-level diagram-embedding
// context so the result is a real string (inline) or `stack` content (block).
#let common = (diagrams: false, bold-mainline: false, spaced: true, nags: false, comments: false, lang: "en", variations: true)
#let inline(g) = notation(g, ..common)
#let block(g) = notation(g, ..(common + (variation-style: "block")))

// --- 1) a game from some moves ---------------------------------------------
#let base = game("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 *")

// --- 2) a variation at a move in between (alternative to 3. Bb5) -------------
#let gv1 = with-line(base, at: "3w", moves: "Bc4 Bc5 4. d4")

// --- 3) a nested variation INSIDE the first one (alternative to 3... Bc5, the
//        Black move of that variation, addressed by a variation-path locator) -
#let gv2 = with-line(gv1, at: (line: ((at: "3w", into: 0),), at: "3b"), moves: "Nf6 4. Ng5")

// Each builder returns a NEW game; earlier games are untouched.
#assert(inline(base) == "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6", message: "base game unchanged (no variation)")
#assert(
  inline(gv1) == "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4 Bc5 4. d4) 3... a6",
  message: "first variation added; base still clean",
)
#assert(
  inline(gv2) == "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4 Bc5 (3... Nf6 4. Ng5) 4. d4) 3... a6",
  message: "nested variation spliced inside the first",
)

// --- 4) the final game in BLOCK style, asserted ----------------------------
// Block notation is a `stack` of `pad`ded lines. `.body.text` is the plain line
// string (no coupling to indent/spacing lengths); `.left.length / 1.2em` is the
// nesting level (1.2em is the renderer's per-level indent).
#let sheet = block(gv2)
#assert(sheet.func() == stack, message: "block style returns a stack of lines")

#let lines = sheet.children.map(c => c.body.text)
#let levels = sheet.children.map(c => c.left.length / 1.2em)

#assert(
  lines == (
    "1. e4 e5 2. Nf3 Nc6 3. Bb5",   // mainline up to the branch move
    "(3. Bc4 Bc5",                 // first variation opens, up to its branch move
    "(3... Nf6 4. Ng5)",            // the nested variation, one level deeper
    "4. d4)",                      // first variation resumes and closes
    "3... a6",                     // mainline resumes
  ),
  message: "block line texts (parenthesised, correctly numbered)",
)
#assert(levels == (0.0, 1.0, 2.0, 1.0, 0.0), message: "each variation indented one level per nesting depth")

// --- back-stop: the nested line is legal + navigable, and its position equals
//     an INDEPENDENT play-out of the same move sequence ----------------------
#let nested-loc = (line: ((at: "3w", into: 0), (at: "3b", into: 0)), at: "4w")
#assert(
  position-after(gv2, at: nested-loc).squares
    == play(none, moves: "1. e4 e5 2. Nf3 Nc6 3. Bc4 Nf6 4. Ng5").squares,
  message: "position-after into the nested variation == independent play",
)

= Nested variation, block style
#notation(gv2, variations: true, variation-style: "block")
