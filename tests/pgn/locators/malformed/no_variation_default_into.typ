// EXPECT: no variation #0 at move 1w
// prompt 53 Phase 3: `into` defaults to 0, but the guard `assert(into <
// vars.len(), ..)` is unchanged — addressing a move that has NO recorded
// variations at all (via an omitted `into`, i.e. the new default) must still
// be a hard error, just like the pre-existing explicit-`into` out-of-range
// fixtures (`no_such_variation.typ` in this dir and in
// tests/notation/variations/malformed/).
#import "/lib.typ": game, diagram
#let g = game("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 *")
// 1w has zero recorded variations; omitting `into` still defaults to 0, and
// 0 < 0 is false.
#let _ = diagram(g, at: (line: ((at: "1w"),), at: "1b"))
