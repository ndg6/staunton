// RENDER-ONLY sheet (prompt 27/28): eyeball the in-check glow and the move-quality
// badge. See tests/VISUAL_CHECKS.md for what to check.
//
// Prompt 28 changes: (1) the glow is a Lichess-style centre-hot radial drawn UNDER
// the king (king crisp on top, glow radiates from beneath); (2) badges are tied to
// a MOVE and therefore come ONLY from a game (`diagram(.., at: ..)`) — never from a
// bare position or an empty square.
#import "/lib.typ": board, diagram, game, with-nags

#set page(width: 16cm, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

= In-check glow

Auto-detected from the position (side-to-move king). Left: Black in check
(Scholar's mate). Right: White in check. Both need `check: true`. The king piece
stays crisp *on top*; the red glow radiates from underneath.

#grid(columns: 2, gutter: 1cm,
  board("rnb1kbnr/pppp1Qpp/8/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4",
    check: true, size: 5cm),
  board("4k3/8/8/8/8/6b1/8/4K2r w - - 0 1", check: true, size: 5cm),
)

`check: false` (default) hides it even when a king is in check; a custom
`check-color` re-tints the glow:

#grid(columns: 2, gutter: 1cm,
  board("rnb1kbnr/pppp1Qpp/8/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4", size: 5cm),
  board("rnb1kbnr/pppp1Qpp/8/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4",
    check: true, check-color: rgb("#2b6cff"), size: 5cm),
)

Reference play `1. b3 g5 2. e3 f6 3. Qh5#` (the fool's-mate shape) — the mated
Black king glows, piece unaffected on top:

#let mate = game("1. b3 g5 2. e3 f6 3. Qh5#")
#diagram(mate, at: "3w", check: true, caption: none, game-info: none, size: 5cm)

= Move-quality badge

Badges come from a game only. This game tags each of six plies with a literal
quality suffix; `diagram(.., at: ..)` derives the badge and places it on the move's
destination square — always an occupied square. Good `!`/`!!` blue, bad `?`/`??`
red, interesting `!?`/`?!` green.

#let q = game("1. e4! e5? 2. Nf3!! Nc6?? 3. Bb5!? a6?!")

#grid(columns: 3, gutter: 0.6cm,
  diagram(q, at: "1w", move-quality: true, caption: none, game-info: none, size: 4.6cm),
  diagram(q, at: "2w", move-quality: true, caption: none, game-info: none, size: 4.6cm),
  diagram(q, at: "1b", move-quality: true, caption: none, game-info: none, size: 4.6cm),
  diagram(q, at: "2b", move-quality: true, caption: none, game-info: none, size: 4.6cm),
  diagram(q, at: "3w", move-quality: true, caption: none, game-info: none, size: 4.6cm),
  diagram(q, at: "3b", move-quality: true, caption: none, game-info: none, size: 4.6cm),
)

Corner square (a8) — a FEN-seeded game whose first move is `Nxa8!!`. The badge
should spill above/right of the board, and stay screen-upper-right under a flip:

#let corner = game(
  "[SetUp \"1\"][FEN \"r3k3/8/1N6/8/8/8/8/4K3 w - - 0 1\"] 1. Nxa8!! 1-0",
)

#grid(columns: 2, gutter: 1cm,
  diagram(corner, at: "1w", move-quality: true, caption: none, game-info: none, size: 5cm),
  diagram(corner, at: "1w", flip: true, move-quality: true, caption: none, game-info: none, size: 5cm),
)

= Both, wired through a game

`diagram(.., at: ..)` auto-places the badge (from the move's NAG / literal suffix) and
the glow (check delivered by the move). Left: the mate `4.Qxf7#`, badge from a
programmatic `!` on that move. Right: `3...Nf6??`, badge on f6 from the literal
suffix (the badge always sits on the addressed move's destination).

#let g = game(
  "[White \"Player A\"][Black \"Player B\"][Date \"2026.01.01\"] " +
  "1. e4 e5 2. Qh5 Nc6 3. Bc4 Nf6?? 4. Qxf7# 1-0",
)

#grid(columns: 2, gutter: 1cm,
  diagram(with-nags(g, ("4w": "!")), at: "4w",
    check: true, move-quality: true, size: 5cm),
  diagram(g, at: "3b",
    check: true, move-quality: true, size: 5cm),   // Nf6?? badge on f6
)
