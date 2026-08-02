// Asserting test: 2.0.0 Phase B' -- localized letters normalize recursively
// into (R)AV variations, not just the mainline. `movetext(game)` builds the
// whole tree (mainline + nested variations) in one pass, so a variation
// missing normalisation would be a distinct bug from the mainline working.
#import "/lib.typ": game, move-node

// German movetext with a variation at move 2 (2. Sf3 mainline; 2. Lc4 Lc5
// alternative).
#let g = game("1. e4 e5 2. Sf3 (2. Lc4 Lc5) Sc6 3. Lb5 a6", lang: "de")

#let node2w = move-node(g, "2w")
#assert(node2w.san == "Nf3", message: "mainline 2w should normalize to Nf3, got " + node2w.san)
#assert(node2w.variations.len() == 1, message: "expected exactly one variation at 2w")

#let var-sans = node2w.variations.at(0).map(n => n.san)
#assert(
  var-sans == ("Bc4", "Bc5"),
  message: "variation SAN must be normalized too, got " + repr(var-sans),
)

= variations normalize recursively OK

The mainline move at 2w normalizes ("Sf3" -> "Nf3"), and so does its nested
variation ("Lc4 Lc5" -> "Bc4", "Bc5").
