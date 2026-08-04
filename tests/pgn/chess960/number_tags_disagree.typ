// EXPECT: disagree
// The two position-number tag spellings ([FRCPosition] / [Chess960Position]) may
// both appear only if they carry the same number; conflicting values are rejected.
#import "/lib.typ": game, game-start

#let g = game("[Variant \"Chess960\"][FRCPosition \"0\"][Chess960Position \"518\"] *")
#let _ = game-start(g)
