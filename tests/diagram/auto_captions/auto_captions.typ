// Diagrams - automatic caption situations. Two label slots:
//  * ABOVE (game-info): drawn only when BOTH players are known; year appended
//  in parentheses if present.
//  * BELOW (figure caption): source-specific default — FEN string -> "White to
//  move" / "Black to move" (a bare FEN has no reliable move number); PGN
//  (diagram(.., at: ..)) -> "Position after <last move>"; manual position/board dict ->
//  no default.
#import "/lib.typ": diagram, position, starting-fen, game

#set page(width: 13cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)

= Auto-caption situations

== FEN source, no players → below caption only
#diagram(starting-fen, size: 3.2cm)

== FEN source, both players + year → above line *and* below caption
#diagram(starting-fen, size: 3.2cm, white: [Carlsen], black: [Nepo], year: 2021)

== FEN source, both players, no year → above line without "(year)"
#diagram(starting-fen, size: 3.2cm, white: [Alice], black: [Bob])

== FEN source, only one player known → no above line (needs both)
#diagram(starting-fen, size: 3.2cm, white: [Solo])

== Manual position dict → no above line, no default caption
#diagram(position((
  e1: (kind: "king", color: "white"), e8: (kind: "king", color: "black"), d1: "Q",
)), size: 3.2cm)

== PGN source via diagram(.., at: ..) → players/year/last-move pulled from the game
#let g = game(```
[White "Morphy"] [Black "Allies"] [Date "1858.11.02"]
1. e4 e5 2. Nf3 d6 3. d4 Bg4 *
```)
#diagram(g, at: "3w", size: 3.2cm)

== PGN source, no Date tag → above line shows the players *without* "(year)"
#let undated = game(```
[White "Morphy"] [Black "Allies"]
1. e4 e5 2. Nf3 d6 3. d4 Bg4 *
```)
#diagram(undated, at: "3w", size: 3.2cm)

== PGN source, manual `year:` override → shows (2024), not the roster's 1858
#diagram(g, at: "3w", year: 2024, size: 3.2cm)
