// Microbench: board() — the board renderer (Typst-native content construction +
// layout + PDF export of one board). The suspected — and confirmed — real cost
// center, and the part a WASM plugin CANNOT help (WASM offloads parsing/compute,
// not Typst content building or layout).
//
// See parse.typ for the n-parameterisation / self-baseline scheme.
//
// Memoisation defeat — IMPORTANT: an earlier version drew the SAME position at
// varying `size`. That did NOT defeat memoisation: board construction memoises
// the size-independent square/piece content, so only re-layout was measured and
// the per-call figure came out ~10x too low. We instead draw a DISTINCT real
// position each iteration (the position after ply i+1), exactly as a real
// document does — so the full square/piece construction runs every time. N must
// stay <= the game's ply count so no position repeats (see run-bench.sh).
#import "/lib.typ": game, mainline, board
#set page(width: auto, height: auto)

#let n = int(sys.inputs.at("n", default: "0"))
#let g = game(read("/bench/_fixture_game.pgn"))
#let loc(p) = str(calc.quo(p + 1, 2)) + (if calc.odd(p) { "w" } else { "b" })

#for i in range(n) {
  board(g, at: loc(i + 1))
}
