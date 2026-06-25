// EXPECT: unexpected ')'
// Structurally malformed movetext: a variation close with no open. This is
// caught at PARSE time (Phase A), before the engine runs.
#import "/src/pgn.typ": parse-pgn
#let _ = parse-pgn("1. e4 e5 ) 2. Nf3 *")
