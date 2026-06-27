// §3 Diagrams - automatic caption situations. Two label slots:
//   * ABOVE (game-info): drawn only when BOTH players are known; year appended
//     in parentheses if present.
//   * BELOW (figure caption): source-specific default — FEN string -> "Position
//     at move N, X to play"; PGN (board-after) -> "Position after move <last>";
//     manual position/board dict -> no default.
#import "/lib.typ": chess-diagram, board-after, position, starting-fen, parse-pgn

#set page(width: 13cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)

= Auto-caption situations

== FEN source, no players → below caption only
#chess-diagram(starting-fen, size: 3.2cm)

== FEN source, both players + year → above line *and* below caption
#chess-diagram(starting-fen, size: 3.2cm, white: [Carlsen], black: [Nepo], year: 2021)

== FEN source, both players, no year → above line without "(year)"
#chess-diagram(starting-fen, size: 3.2cm, white: [Alice], black: [Bob])

== FEN source, only one player known → no above line (needs both)
#chess-diagram(starting-fen, size: 3.2cm, white: [Solo])

== Manual position dict → no above line, no default caption
#chess-diagram(position((
  e1: (kind: "king", color: "white"), e8: (kind: "king", color: "black"), d1: "Q",
)), size: 3.2cm)

== PGN source via board-after → players/year/last-move pulled from the game
#let game = parse-pgn(```
[White "Morphy"] [Black "Allies"] [Date "1858.11.02"]
1. e4 e5 2. Nf3 d6 3. d4 Bg4 *
```).first()
#board-after(game, "3w", size: 3.2cm)
