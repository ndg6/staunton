// EXPECT: disagree
// The two position-number tag spellings ([FRCPosition] / [Chess960Position]) may
// both appear only if they carry the same number; conflicting values are rejected.
#import "/lib.typ": parse-pgn, game-start

#let g = parse-pgn("[Variant \"Chess960\"][FRCPosition \"0\"][Chess960Position \"518\"] *").first()
#let _ = game-start(g)
