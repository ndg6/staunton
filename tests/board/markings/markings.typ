// RENDER-ONLY sheet (prompt 27): eyeball the in-check glow and the move-quality
// badge. See tests/VISUAL_CHECKS.md for what to check.
#import "/lib.typ": board, chess-board, diagram-after, parse-pgn, with-nags, set-board-defaults

#set page(width: 16cm, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

= In-check glow

Auto-detected from the position (side-to-move king). Left: Black in check
(Scholar's mate). Right: White in check. Both need `check: true`.

#grid(columns: 2, gutter: 1cm,
  chess-board("rnb1kbnr/pppp1Qpp/8/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4",
    check: true, size: 5cm),
  chess-board("4k3/8/8/8/8/6b1/8/4K2r w - - 0 1", check: true, size: 5cm),
)

`check: false` (default) hides it even when a king is in check; a custom
`check-color` re-tints the glow:

#grid(columns: 2, gutter: 1cm,
  chess-board("rnb1kbnr/pppp1Qpp/8/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4", size: 5cm),
  chess-board("rnb1kbnr/pppp1Qpp/8/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4",
    check: true, check-color: rgb("#2b6cff"), size: 5cm),
)

= Move-quality badge

All six glyphs, per-call, on an empty board — good (blue), bad (red),
interesting (green). The disc sits on the square's upper-right corner, clears the
piece, and spills into the neighbours.

#board("8/8/8/8/8/8/8/8 w - - 0 1", move-quality: true, size: 7cm, highlight: (
    "b7", "d7", "f7", "b4", "d4", "f4",
  ),
  // draw six pieces so we can see the badge not touching them
)

#grid(columns: 3, gutter: 0.6cm,
  board("8/1N6/8/8/8/8/8/8 w - - 0 1", move-quality: true,
    move-quality-mark: (square: "b7", symbol: "!"), size: 4.6cm),
  board("8/3N4/8/8/8/8/8/8 w - - 0 1", move-quality: true,
    move-quality-mark: (square: "d7", symbol: "!!"), size: 4.6cm),
  board("8/5N2/8/8/8/8/8/8 w - - 0 1", move-quality: true,
    move-quality-mark: (square: "f7", symbol: "?"), size: 4.6cm),
  board("8/8/8/8/1n6/8/8/8 w - - 0 1", move-quality: true,
    move-quality-mark: (square: "b4", symbol: "??"), size: 4.6cm),
  board("8/8/8/8/3n4/8/8/8 w - - 0 1", move-quality: true,
    move-quality-mark: (square: "d4", symbol: "!?"), size: 4.6cm),
  board("8/8/8/8/5n2/8/8/8 w - - 0 1", move-quality: true,
    move-quality-mark: (square: "f4", symbol: "?!"), size: 4.6cm),
)

Corner square (a8) — the badge should spill above/right of the board, and stay
screen-upper-right under a flip:

#grid(columns: 2, gutter: 1cm,
  board("N7/8/8/8/8/8/8/8 w - - 0 1", move-quality: true,
    move-quality-mark: (square: "a8", symbol: "!!"), size: 5cm),
  board("N7/8/8/8/8/8/8/8 w - - 0 1", flip: true, move-quality: true,
    move-quality-mark: (square: "a8", symbol: "!!"), size: 5cm),
)

= Both, wired through a game

`diagram-after` auto-places the badge (from the move's NAG / literal suffix) and
the glow (check delivered by the move). Left: the mate `4.Qxf7#`, badge from a
programmatic `!` on that move. Right: `3...Nf6??`, badge on f6 from the literal
suffix (the badge always sits on the addressed move's destination).

#let g = parse-pgn(
  "[White \"Player A\"][Black \"Player B\"][Date \"2026.01.01\"] " +
  "1. e4 e5 2. Qh5 Nc6 3. Bc4 Nf6?? 4. Qxf7# 1-0",
).first()

#grid(columns: 2, gutter: 1cm,
  diagram-after(with-nags(g, ("4w": "!")), "4w",
    check: true, move-quality: true, size: 5cm),
  diagram-after(g, "3b",
    check: true, move-quality: true, size: 5cm),   // Nf6?? badge on f6
)
