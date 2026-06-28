// staunton showcase - a single document touring the plugin's capabilities. All
// games here are SYNTHETIC: inline PGN with made-up players and textbook opening
// lines, so the example is self-contained (no bundled PGN files to ship). This is
// an example, not a test (the runner compiles it to ensure it does not break, but
// keeps no assertions).
//
// Compile with the package root:  typst compile --root . examples/showcase.typ
#import "/lib.typ": (
  parse-pgn, board-after, board, chess-diagram, chess-diagram-outline,
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

// --- synthetic games (inline; legal textbook lines, fictional players) ---

// A complete Giuoco Piano (~29 plies), used for most of the position diagrams.
#let g-main = parse-pgn(```
[White "Alice"] [Black "Bob"] [Event "Synthetic Open"] [Result "1/2-1/2"]
1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. c3 Nf6 5. d4 exd4 6. cxd4 Bb4+
7. Bd2 Bxd2+ 8. Nbxd2 d5 9. exd5 Nxd5 10. Qb3 Nce7 11. O-O O-O
12. Rfe1 c6 13. a4 Qb6 14. Qxb6 Nxb6 15. Bb3 1/2-1/2
```).first()

// A 7-ply miniature ("Scholar's mate") - short, decisive, ends in checkmate.
#let g-mate = parse-pgn(```
[White "Carol"] [Black "Dan"] [Event "Synthetic Blitz"] [Result "1-0"]
1. e4 e5 2. Bc4 Bc5 3. Qh5 Nf6 4. Qxf7# 1-0
```).first()

// Locator for the final mainline position of a game (move number + side).
#let final-locator(game) = {
  let n = mainline(game).len()
  let movenum = calc.ceil(n / 2)
  let color = if calc.rem(n, 2) == 1 { "w" } else { "b" }
  str(movenum) + color
}

#chess-diagram-outline(title: [List of diagrams in this showcase])

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

`board-after` pulls the roster and the last move into the labels automatically.
Each diagram below uses a different bundled piece set.

#grid(
  columns: 2,
  gutter: 14pt,
  board-after(g-main, "8w", size: 5cm, piece-set: "merida"),
  board-after(g-main, final-locator(g-main), size: 5cm, piece-set: "cburnett"),
)

= Label modes and orientation

The same final position drawn three ways, plus flipped to Black's view.

#grid(
  columns: 4,
  gutter: 8pt,
  align: bottom + center,
  board(position-after(g-main, final-locator(g-main)), size: 3.2cm, label-mode: "on-square"),
  board(position-after(g-main, final-locator(g-main)), size: 3.2cm, label-mode: "outside"),
  board(position-after(g-main, final-locator(g-main)), size: 3.2cm, label-mode: "border"),
  board(position-after(g-main, final-locator(g-main)), size: 3.2cm, label-mode: "border", flip: true),
  [on-square], [outside], [border], [border, flipped],
)

= A short, decisive miniature

The position right before the final blow, and the checkmate itself:

#grid(
  columns: 2,
  gutter: 14pt,
  board-after(g-mate, "3b", size: 5cm),
  board-after(g-mate, final-locator(g-mate), size: 5cm, piece-set: "merida"),
)

= A "what-if" line that does not exist in any game

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
  position-after(g-main, "6w"),
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
  board-after(g-main, "10w", size: 4.5cm),
  board-after(g-main, "14w", size: 4.5cm),
)
