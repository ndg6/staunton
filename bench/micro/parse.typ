// Microbench: parse-pgn (PGN tokenize + parse).
//
// Parameterised by  --input n=<count>.  The loop body is the ONLY thing that
// scales with n; everything above it (import, read) is FIXED cost that is
// identical at n=0. So the driver measures per-call cost as
//   ( T(n) - T(0) ) / n .
//
// Memoisation defeat: Typst memoises pure calls by argument identity, so
// parsing the SAME string n times would parse once and hit the cache n-1 times.
// We prepend a distinct tag line per iteration to force a genuine parse each
// time. (The extra tag is a few bytes; its cost is counted into the per-call
// figure but is negligible next to parsing a full game.)
#import "/lib.typ": parse-pgn
#set page(width: auto, height: auto)

#let n = int(sys.inputs.at("n", default: "0"))
#let raw = read("/bench/_fixture_game.pgn")

#let acc = 0
#for i in range(n) {
  let g = parse-pgn("[Bench \"" + str(i) + "\"]\n" + raw).first()
  acc += g.movetext-raw.len()
}
// Emit the accumulator so the work cannot be optimised away.
#acc
