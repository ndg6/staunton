// End-to-end realistic workload for the Phase 0 performance baseline.
//
// The 9 decisive-by-play games of the Spassky-Fischer 1972 World Championship
// match (draws and the game-2 forfeit excluded). For each game we typeset a
// bulletin-style entry: a header from the PGN tags, the full move notation, and
// a board diagram at several plies. This is the "not an engine, just typeset
// it" workload from the prompt: it drives parse + replay + notation + drawing
// across real games, and is what we profile with `typst compile --timings`.
//
// This is NOT an asserting test; it is a benchmark input. It lives under bench/
// and is compiled by bench/run-bench.sh, not by tests/run.sh.
#import "/lib.typ": game, mainline, notation, diagram-after
#set page(paper: "a4", margin: 2cm)
#set text(size: 10pt)

#let rounds = (1, 3, 5, 6, 8, 10, 11, 13, 21)

#let game-file(r) = "/bench/spassky_fischer_1972/game_" + (if r < 10 { "0" } else { "" }) + str(r) + ".pgn"

#let ply-locator(p) = str(calc.quo(p + 1, 2)) + (if calc.odd(p) { "w" } else { "b" })

#align(center)[
  #text(size: 18pt, weight: "bold")[Spassky – Fischer 1972]
  #linebreak()
  #text(size: 12pt)[Decisive games — benchmark workload]
]

#for r in rounds {
  let g = game(read(game-file(r)))
  let tags = g.tags
  let plies = mainline(g).len()

  pagebreak(weak: true)
  heading(level: 2)[Game #r: #tags.at("White", default: "?") – #tags.at("Black", default: "?") · #g.result]
  [*Opening:* #tags.at("Opening", default: tags.at("ECO", default: "?")) · #plies plies]

  // Full move notation.
  block(notation(g))

  // Board diagrams every 10 plies plus the final position.
  let marks = range(10, plies, step: 10) + (plies,)
  grid(
    columns: 3,
    gutter: 8pt,
    ..marks.map(p => diagram-after(g, ply-locator(p), caption: "after ply " + str(p), size: 4cm)),
  )
}
