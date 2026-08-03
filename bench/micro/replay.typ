// Microbench: SAN replay — position-after walking the whole mainline (this
// drives san-to-move + apply for every move of the game).
//
// See parse.typ for the n-parameterisation / self-baseline scheme.
//
// Memoisation defeat: position-after memoises the mainline replay on the game
// dict, so replaying the same game n times would cost one replay. We insert a
// distinct junk key into the game dict per iteration; the replay logic ignores
// it, so the WORK is identical but the cache is bypassed.
#import "/lib.typ": game, mainline, position-after
#set page(width: auto, height: auto)

#let n = int(sys.inputs.at("n", default: "0"))
#let g = game(read("/bench/_fixture_game.pgn"))
#let plies = mainline(g).len()
#let loc = str(calc.quo(plies + 1, 2)) + (if calc.odd(plies) { "w" } else { "b" })

#let acc = 0
#for i in range(n) {
  let probe = g                      // copy, so the insert below cannot touch `g`
  probe.insert("_bench", i)          // distinct arg -> full replay, no cache hit
  acc += position-after(probe, at: loc).squares.len()
}
#acc
