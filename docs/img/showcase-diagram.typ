// Source for the README showcase #1 (a position from a real game). Keep in sync
// with its README code block. Regenerate with:
//   typst compile --root . --format png --ppi 160 docs/img/showcase-diagram.typ docs/img/showcase-diagram.png
#import "/lib.typ": game, diagram-after

#set page(width: auto, height: auto, margin: 12pt, fill: white)
#set text(font: "Libertinus Serif", size: 10pt)

// Morphy's "Opera Game" (Paris, 1858) — the final mate.
#let g = game(```
[White "Morphy"] [Black "Allies"] [Date "1858"]
1. e4 e5 2. Nf3 d6 3. d4 Bg4 4. dxe5 Bxf3 5. Qxf3 dxe5 6. Bc4 Nf6 7. Qb3 Qe7
8. Nc3 c6 9. Bg5 b5 10. Nxb5 cxb5 11. Bxb5+ Nbd7 12. O-O-O Rd8 13. Rxd7 Rxd7
14. Rd1 Qe6 15. Bxd7+ Nxd7 16. Qb8+ Nxb8 17. Rd8# 1-0
```)

// The final position: roster -> info line, last move -> caption, check -> glow.
#diagram-after(g, "17w", check: true, size: 4.6cm)
