// Microbench: legal-moves (the move generator) on a realistic midgame position.
//
// See parse.typ for the n-parameterisation / self-baseline scheme.
//
// Memoisation defeat: the midgame position is computed ONCE before the loop (so
// its cost is fixed, present at both n=0 and n=N and thus cancelled). Inside the
// loop we insert a distinct junk key per iteration. The move generator ignores
// the extra key, so the WORK is identical, but the argument identity differs so
// Typst recomputes instead of returning a cached result.
#import "/lib.typ": parse-pgn, mainline, position-after, legal-moves
#set page(width: auto, height: auto)

#let n = int(sys.inputs.at("n", default: "0"))
#let game = parse-pgn(read("/bench/_fixture_game.pgn")).first()
// A midgame position (~ply 20) — more pieces in play than the opening, so a
// representative move-generation load.
#let plies = mainline(game).len()
#let mid = calc.min(20, plies)
#let loc = str(calc.quo(mid + 1, 2)) + (if calc.odd(mid) { "w" } else { "b" })
#let pos = position-after(game, loc)

#let acc = 0
#for i in range(n) {
  let p = pos
  p.insert("_bench", i)          // distinct arg -> defeats memoisation
  acc += legal-moves(p).len()
}
#acc
