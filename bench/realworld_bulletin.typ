// Diagram-dense real-document workload for the prompt-37 drawing-perf work.
//
// Three long real games (216 / 217 / 160 plies) from tests/pgn/realworld,
// typeset as an annotated bulletin: header + full notation + a board diagram
// every 8 plies plus the final position. At that density the three games yield
// ~70 distinct diagrams — the "real document with many diagrams" workload the
// drawing optimisations (prompt 37) target. Every diagram is a distinct real
// position, so this measures true per-diagram drawing cost (no memoisation
// short-cut), the same way bench/spassky_fischer.typ does for the 9-game set.
//
// NOT an asserting test; a benchmark input compiled by bench/run-bench.sh.
#import "/lib.typ": game, mainline, notation, diagram
#set page(paper: "a4", margin: 2cm)
#set text(size: 10pt)

// The three new long games (tests/pgn/realworld/). Read from the repo root so
// this compiles with `--root .` like the rest of the harness.
#let game-ids = (1012928, 1125843, 1281900)
#let game-file(id) = "/tests/pgn/realworld/game_" + str(id) + ".pgn"

#let ply-locator(p) = str(calc.quo(p + 1, 2)) + (if calc.odd(p) { "w" } else { "b" })

#align(center)[
  #text(size: 18pt, weight: "bold")[Real-world bulletin — drawing benchmark]
  #linebreak()
  #text(size: 12pt)[Three long games, a diagram every 8 plies]
]

#for id in game-ids {
  let g = game(read(game-file(id)))
  let tags = g.tags
  let plies = mainline(g).len()

  pagebreak(weak: true)
  heading(level: 2)[#tags.at("White", default: "?") – #tags.at("Black", default: "?") · #g.result]
  [*Event:* #tags.at("Event", default: "?") · #tags.at("Opening", default: tags.at("ECO", default: "?")) · #plies plies]

  // Full move notation.
  block(notation(g))

  // Board diagrams every 8 plies plus the final position.
  let marks = range(8, plies, step: 8) + (plies,)
  grid(
    columns: 3,
    gutter: 8pt,
    ..marks.map(p => diagram(g, at: ply-locator(p), caption: "after ply " + str(p), size: 4cm)),
  )
}
