// Single-game trace target for `typst compile --timings`.
//
// The full 9-game bench/spassky_fischer.typ produces a ~600 MB timings trace,
// which is impractical to open. One game (notation + a handful of boards) yields
// a trace small enough to load in https://ui.perfetto.dev while still showing
// the eval-vs-layout / func-call breakdown. Game 13 is the longest decisive
// game, so it is a good single-game stand-in.
#import "/lib.typ": parse-pgn, mainline, notation, diagram-after
#set page(paper: "a4", margin: 2cm)

#let game = parse-pgn(read("/bench/spassky_fischer_1972/game_13.pgn")).first()
#let plies = mainline(game).len()
#let loc(p) = str(calc.quo(p + 1, 2)) + (if calc.odd(p) { "w" } else { "b" })

#notation(game)
#grid(
  columns: 3, gutter: 8pt,
  ..range(10, plies, step: 10).map(p => diagram-after(game, loc(p), caption: "ply " + str(p), size: 4cm)),
)
