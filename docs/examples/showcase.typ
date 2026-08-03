// staunton showcase - a single document touring the plugin's capabilities. All
// games here are SYNTHETIC: inline PGN with made-up players and textbook opening
// lines, so the example is self-contained (no bundled PGN files to ship). This is
// an example, not a test (the runner compiles it to ensure it does not break, but
// keeps no assertions).
//
// Compile with the package root:  typst compile --root . examples/showcase.typ
#import "/lib.typ": (
  game, games, board, diagram, diagram-outline,
  mainline, game-result, position-after, play, set-chess-defaults, starting-fen,
  color-theme, standings-table,
)

#set page(paper: "a4", margin: 2cm)
#set text(font: "Libertinus Serif", size: 10pt)
#set heading(numbering: "1.1")

#align(center)[
  #text(size: 20pt, weight: "bold")[staunton] \
  #text(size: 12pt)[chess diagrams for Typst — capability showcase]
]
#v(6pt)

// --- synthetic games (inline; legal textbook lines, fictional players) ---

// A complete Giuoco Piano (~29 plies), used for most of the position diagrams.
#let g-main = game(```
[White "Alice"] [Black "Bob"] [Event "Synthetic Open"] [Result "1/2-1/2"]
1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. c3 Nf6 5. d4 exd4 6. cxd4 Bb4+
7. Bd2 Bxd2+ 8. Nbxd2 d5 9. exd5 Nxd5 10. Qb3 Nce7 11. O-O O-O
12. Rfe1 c6 13. a4 Qb6 14. Qxb6 Nxb6 15. Bb3 1/2-1/2
```)

// A 7-ply miniature ("Scholar's mate") - short, decisive, ends in checkmate.
#let g-mate = game(```
[White "Carol"] [Black "Dan"] [Event "Synthetic Blitz"] [Result "1-0"]
1. e4 e5 2. Bc4 Bc5 3. Qh5 Nf6 4. Qxf7# 1-0
```)

// Locator for the final mainline position of a game (move number + side).
#let final-locator(game) = {
  let n = mainline(game).len()
  let movenum = calc.ceil(n / 2)
  let color = if calc.rem(n, 2) == 1 { "w" } else { "b" }
  str(movenum) + color
}

#diagram-outline(title: [List of diagrams in this showcase])

= The synthetic games at a glance

#table(
  columns: (1fr, 1fr, 1fr, auto, auto),
  inset: 6pt,
  align: (left, left, left, center, center),
  table.header([*Event*], [*White*], [*Black*], [*plies*], [*result*]),
  ..(g-main, g-mate).map(g => (
    g.tags.at("Event", default: "?"),
    g.tags.at("White", default: "?"),
    g.tags.at("Black", default: "?"),
    str(mainline(g).len()),
    game-result(g),
  )).flatten(),
)

= Diagrams from a game (auto captions, different piece sets)

`diagram(g, at: ..)` pulls the roster and the last move into the labels automatically.
Each diagram below uses a different bundled piece set.

#grid(
  columns: 2,
  gutter: 14pt,
  diagram(g-main, at: "8w", size: 5cm, piece-set: "merida"),
  diagram(g-main, at: final-locator(g-main), size: 5cm, piece-set: "cburnett"),
)

= Label modes and orientation

The same final position drawn three ways, plus flipped to Black's view.

#grid(
  columns: 4,
  gutter: 8pt,
  align: bottom + center,
  board(position-after(g-main, at: final-locator(g-main)), size: 3.2cm, label-mode: "on-square"),
  board(position-after(g-main, at: final-locator(g-main)), size: 3.2cm, label-mode: "outside"),
  board(position-after(g-main, at: final-locator(g-main)), size: 3.2cm, label-mode: "border"),
  board(position-after(g-main, at: final-locator(g-main)), size: 3.2cm, label-mode: "border", flip: true),
  [on-square], [outside], [border], [border, flipped],
)

= A short, decisive miniature

The position right before the final blow, and the checkmate itself:

#grid(
  columns: 2,
  gutter: 14pt,
  diagram(g-mate, at: "3b", size: 5cm),
  diagram(g-mate, at: final-locator(g-mate), size: 5cm, piece-set: "merida"),
)

= A "what-if" line that does not exist in any game

`play` applies move text (or a SAN array) to a position (or FEN, or `none`
for the start) and returns the resulting position, without mutating anything.

#diagram(
  play(starting-fen, moves: "1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. b4"),
  size: 5cm,
  caption: [The Evans Gambit after 4.b4, built with `play`.],
)

= Arrows, highlights and a grid

Explicit arrows (tuple / dict forms), square highlights, and the optional grid:

#board(
  position-after(g-main, at: "6w"),
  size: 6cm,
  grid: true,
  highlight: ("e4", "e5"),
  arrows: (("g1", "f3"), ("f1", "c4", rgb(0, 70, 160, 200))),
)

PGN `{[%cal …]}` / `{[%csl …]}` annotations are picked up automatically:

#let annotated = game(```
[White "Demo"] [Black "Annotations"]
1. e4 e5 2. Nf3 {[%cal Gf3e5,Bf1c4] [%csl Re5]} Nc6 *
```)
#diagram(annotated, at: "2w", size: 6cm)

= Document-wide styling

#set-chess-defaults(light: rgb("#eeeed2"), dark: rgb("#769656"))
After `set-chess-defaults`, subsequent diagrams inherit the green theme:

#grid(columns: 2, gutter: 14pt,
  diagram(g-main, at: "10w", size: 4.5cm),
  diagram(g-main, at: "14w", size: 4.5cm),
)

= Themed boards  (reusable `color-theme` / `board-theme`, patterns, material borders)

Eleven built-in color/board themes, square patterns (stripes / marble / wood),
and a matching material band around the board via `border-theme`. Set per call
here, but equally valid as document-wide defaults through `set-board-defaults`.

#grid(
  columns: 3, gutter: 10pt, align: horizon,
  board(position-after(g-main, at: "8w"), size: 3.6cm,
    color-theme: "marine"),
  board(position-after(g-main, at: "8w"), size: 3.6cm,
    color-theme: color-theme(light: rgb("#d9b98a"), dark: rgb("#6b4a2f"), pattern: "wood")),
  board(position-after(g-main, at: "8w"), size: 3.6cm,
    label-mode: "border", border-theme: "marble",
    color-theme: color-theme(base: "emerald", pattern: "marble", brightness: -15%, contrast: 30%)),
)

= Tournament-table styling  (zebra rows, winner highlighting, and more)

#let mini = games(```
[White "Alice"][Black "Bob"][Result "1-0"][Round "1"]
1. e4 e5 2. Nf3 Nc6 3. Bb5 1-0
[White "Carol"][Black "Dan"][Result "0-1"][Round "1"]
1. d4 d5 2. c4 e6 0-1
[White "Alice"][Black "Carol"][Result "1/2-1/2"][Round "2"]
1. e4 c5 2. Nf3 d6 1/2-1/2
[White "Bob"][Black "Dan"][Result "1-0"][Round "2"]
1. c4 c5 2. Nc3 Nc6 1-0
```)

#standings-table(
  mini,
  caption: [Synthetic mini-tournament, zebra rows and highlighted winners],
  body-fill: "zebra",
  highlight-winners: true,
)
