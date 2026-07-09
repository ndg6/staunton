// Fairy chess -- INLINE custom variant spec (the "define your own kinds per call"
// path). A spec that `extends: "standard"` inherits the six standard kinds and
// letters, then adds alfil/dabbaba/ferz with non-overlapping letters a/d/f.
//
// Asserting test: `position` must resolve the custom letters (case = color) in
// BOTH the squares-dict and the string form, and keep the standard kinds working
// alongside them. No rendering -- this pins the position layer.
#import "/lib.typ": position

#let fairy = (
  extends: "standard",
  kinds: ("alfil", "dabbaba", "ferz"),
  abbr: (a: "alfil", d: "dabbaba", f: "ferz"),
)

// squares-dict form: bare letters + a (kind, color) dict, mixed standard + fairy.
#let p = position((e1: "K", a1: "A", d4: "d", f6: "F", e8: (kind: "king", color: "black")), variant: fairy)
#assert(p.squares.e1 == (kind: "king", color: "white"), message: "std king lost")
#assert(p.squares.e8 == (kind: "king", color: "black"), message: "std black king lost")
#assert(p.squares.a1 == (kind: "alfil", color: "white"), message: "alfil (A) misparsed: " + repr(p.squares.a1))
#assert(p.squares.d4 == (kind: "dabbaba", color: "black"), message: "dabbaba (d) misparsed: " + repr(p.squares.d4))
#assert(p.squares.f6 == (kind: "ferz", color: "white"), message: "ferz (F) misparsed: " + repr(p.squares.f6))

// string form: first line = top rank; '.' empty; upper = white.
#let ps = position(
  "....k...
   ........
   .....F..
   ...d....
   ........
   ........
   ........
   A...K...",
  variant: fairy,
)
#assert(ps.squares.a1 == (kind: "alfil", color: "white"), message: "string-form alfil misparsed")
#assert(ps.squares.d5 == (kind: "dabbaba", color: "black"), message: "string-form dabbaba misparsed: " + repr(ps.squares.at("d5", default: none)))
#assert(ps.squares.f6 == (kind: "ferz", color: "white"), message: "string-form ferz misparsed")
#assert(ps.squares.e8 == (kind: "king", color: "black"), message: "string-form black king misparsed")

Parse OK.
