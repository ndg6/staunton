// staunton showcase - a single document touring the plugin's capabilities using
// the three real PGNs under examples/pgn/. This is an example, not a test (the
// runner compiles it to ensure it does not break, but keeps no assertions).
//
// `read` resolves relative to THIS file, so the PGN paths are relative to
// examples/. Compile with the package root:  typst compile --root . examples/showcase.typ
#import "/lib.typ": (
  parse-pgn, board-after, board, chess-diagram, chess-outline,
  mainline, game-result, position-after, play-moves, set-chess-defaults, starting-fen,
)

#set page(paper: "a4", margin: 2cm)
#set text(font: "Libertinus Serif", size: 10pt)
#set heading(numbering: "1.1")

#align(center)[
  #text(size: 20pt, weight: "bold")[staunton] \
  #text(size: 12pt)[chess diagrams for Typst — capability showcase]
]
#v(6pt)

// The three bundled example games.
#let g-blitz    = parse-pgn(read("pgn/game_1044723.pgn")).first()
#let g-analysis = parse-pgn(read("pgn/game_1044723_analysis.pgn")).first()
#let g-classic  = parse-pgn(read("pgn/game_1860342.pgn")).first()

// Locator for the final mainline position of a game (move number + side).
#let final-locator(game) = {
  let n = mainline(game).len()
  let movenum = calc.ceil(n / 2)
  let color = if calc.rem(n, 2) == 1 { "w" } else { "b" }
  str(movenum) + color
}

#chess-outline(title: [List of diagrams in this showcase])

= The three example games at a glance

#table(
  columns: (auto, 1fr, 1fr, auto, auto),
  inset: 6pt,
  align: (left, left, left, center, center),
  table.header([*file*], [*White*], [*Black*], [*plies*], [*result*]),
  ..(
    ("game_1044723.pgn", g-blitz),
    ("game_1044723_analysis.pgn", g-analysis),
    ("game_1860342.pgn", g-classic),
  ).map(((name, g)) => (
    raw(name),
    g.tags.at("White", default: "?"),
    g.tags.at("Black", default: "?"),
    str(mainline(g).len()),
    game-result(g),
  )).flatten(),
)

= Diagrams from a real game (auto captions, different piece sets)

`board-after` pulls the roster and the last move into the labels automatically.
Each diagram below uses a different bundled piece set.

#grid(
  columns: 2,
  gutter: 14pt,
  board-after(g-blitz, "8w", size: 5cm, piece-set: "merida"),
  board-after(g-blitz, final-locator(g-blitz), size: 5cm, piece-set: "alpha"),
)

= Label modes and orientation

The same final position drawn three ways, plus flipped to Black's view.

#grid(
  columns: 4,
  gutter: 8pt,
  align: bottom + center,
  board(position-after(g-classic, final-locator(g-classic)), size: 3.2cm, label-mode: "on-square"),
  board(position-after(g-classic, final-locator(g-classic)), size: 3.2cm, label-mode: "outside"),
  board(position-after(g-classic, final-locator(g-classic)), size: 3.2cm, label-mode: "border"),
  board(position-after(g-classic, final-locator(g-classic)), size: 3.2cm, label-mode: "border", flip: true),
  [on-square], [outside], [border], [border, flipped],
)

= A "what-if" line that does not exist in any file

`play-moves` applies move text (or a SAN array) to a position (or FEN, or `none`
for the start) and returns the resulting position, without mutating anything.

#chess-diagram(
  play-moves(starting-fen, "1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. b4"),
  size: 5cm,
  caption: [The Evans Gambit after 4.b4, built with `play-moves`.],
)

= Arrows, highlights and a grid

Explicit arrows (tuple / dict forms), square highlights, and the optional grid:

#board(
  position-after(g-blitz, "6w"),
  size: 6cm,
  grid: true,
  highlight: ("e4", "e5"),
  arrows: (("g1", "f3"), ("f1", "c4", rgb(0, 70, 160, 200))),
)

PGN `{[%cal …]}` / `{[%csl …]}` annotations are picked up automatically:

#let annotated = parse-pgn(```
[White "Demo"] [Black "Annotations"]
1. e4 e5 2. Nf3 {[%cal Gf3e5,Bf1c4] [%csl Re5]} Nc6 *
```).first()
#board-after(annotated, "2w", size: 6cm)

= Document-wide styling

#set-chess-defaults(light: rgb("#eeeed2"), dark: rgb("#769656"))
After `set-chess-defaults`, subsequent diagrams inherit the green theme:

#grid(columns: 2, gutter: 14pt,
  board-after(g-analysis, "12w", size: 4.5cm),
  board-after(g-analysis, "20w", size: 4.5cm),
)
