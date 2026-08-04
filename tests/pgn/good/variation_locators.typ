// PGN (good) - path LOCATORS into variations, asserted. Each variation position
// from the internal `_position-after` is cross-checked against an INDEPENDENT
// `play` of the same line (two separate code paths must agree), and `to-fen`'s
// game+locator form is checked to delegate to `_position-after`.
#import "/lib.typ": game, to-fen, play
#import "/src/game.typ": _position-after

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

// Mainline 1.e4 e5 2.Nf3. Two variations at White's move 1:
//   into 0 : 1.d4 d5   -- with a NESTED variation (into 0 at 1b): 1...Nf6 2.c4
//   into 1 : 1.c4 e5
#let g = game(```
[White "Loc"] [Black "Test"]
1. e4 (1. d4 d5 (1... Nf6 2. c4)) (1. c4 e5) 1... e5 2. Nf3 *
```)

// A path locator's position must equal an independent play of `line`.
#let same(loc, line) = {
  assert(
    _position-after(g, at: loc).squares == play(none, moves: line).squares,
    message: "locator " + repr(loc) + " != play(" + line + ")",
  )
}

// mainline still resolves via the string (fast) form ("2w" = after White's 2nd
// move, i.e. after 2.Nf3)
#same("2w", "1. e4 e5 2. Nf3")
// ...and identically via an explicit empty path
#same((line: (), at: "2w"), "1. e4 e5 2. Nf3")

// one hop: into variation 0 at 1w (the 1.d4 line), position after 1...d5
#same((line: ((at: "1w", into: 0),), at: "1b"), "1. d4 d5")

// the SECOND variation at the same move: into 1 (the 1.c4 line), after 1...e5
#same((line: ((at: "1w", into: 1),), at: "1b"), "1. c4 e5")

// nested: into var 0 at 1w, then var 0 at 1b, position after 2.c4
#same((line: ((at: "1w", into: 0), (at: "1b", into: 0)), at: "2w"), "1. d4 Nf6 2. c4")

// to-fen(g, at: <path>) delegates to _position-after on the same locator
#let p = (line: ((at: "1w", into: 0),), at: "1b")
#assert(
  to-fen(g, at: p) == to-fen(_position-after(g, at: p)),
  message: "to-fen game+path locator delegates to _position-after",
)

= Variation locators
All path-locator assertions passed.
