// Fairy chess -- `define-variant` sugar: named-argument constructor over the
// inline variant spec. It validates eagerly and returns the canonical spec, which
// must behave identically to the equivalent inline dict when passed as `variant:`.
//
// Asserting test: the returned spec has the expected canonical shape (inherited
// standard kinds + the added fairy kinds, letters, glyphs, geometry), and parsing
// a position through it matches parsing through the raw inline dict.
#import "/lib.typ": define-variant, position

#let fairy = define-variant("Fairy demo",
  extends: "standard",
  kinds: ("alfil", "dabbaba", "ferz"),
  abbr:  (a: "alfil", d: "dabbaba", f: "ferz"),
  glyphs: (alfil: "✶"),
)

// canonical, normalised spec
#assert(fairy.name == "Fairy demo", message: "name lost: " + repr(fairy.name))
#assert(fairy.kinds.contains("king") and fairy.kinds.contains("alfil"), message: "kinds not merged: " + repr(fairy.kinds))
#assert(fairy.abbr.a == "alfil" and fairy.abbr.k == "king", message: "abbr not merged: " + repr(fairy.abbr))
#assert(fairy.glyphs.alfil == "✶", message: "glyphs lost: " + repr(fairy.glyphs))
#assert(fairy.cols == 8 and fairy.rows == 8, message: "geometry not inherited")

// identical to the equivalent inline dict when parsing a position
#let inline = (extends: "standard", kinds: ("alfil", "dabbaba", "ferz"), abbr: (a: "alfil", d: "dabbaba", f: "ferz"))
#let p1 = position((e1: "K", a1: "A", d4: "d", f6: "F"), variant: fairy)
#let p2 = position((e1: "K", a1: "A", d4: "d", f6: "F"), variant: inline)
#assert(p1.squares == p2.squares, message: "define-variant must parse identically to the inline spec")

Defined OK.
