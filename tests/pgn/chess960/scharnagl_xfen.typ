// Real-world Chess960 game (R. Scharnagl's SmirfGUI test game) exercising the
// X-FEN castling-ambiguity case: White's a1-rook travels a1->a3->h3->h1, so by
// move 11 White has rooks on g1 AND h1 with the king still on e1. King-side
// castling is still available via the g1-rook, but because the h1-rook is now the
// OUTERMOST rook on that side, X-FEN must name the castling rook by file -> "G".
// Serialising the position must reproduce Scharnagl's published field "Gkq".
#import "/lib.typ": parse-pgn, to-fen, position-after, game-variant, game-start, chess960-diagram

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

#let pgn = ```
[Event "SmirfGUI Computerchess Game"]
[Site "CHESSBOX"]
[Date "2005.06.19"]
[Round "Test"]
[White "White"]
[Black "Black"]
[Result "*"]
[Annotator "R. Scharnagl"]
[SetUp "1"]
[Variant "Fischerrandom"]
[FEN "rnbnkqrb/pppppppp/8/8/8/8/PPPPPPPP/RNBNKQRB w KQkq - 0 1"]
1. h4 g6 2. g3 Bf6 3. a4 Qh6 4. Ra3 Bxh4 5. gxh4 Qxh4 6. Qh3 Qxh3 7. Rxh3 Ne6
8. Bf3 d6 9. Nbc3 Ng5 10. Rhh1 Bf5 11. O-O *
```
#let g = parse-pgn(pgn).first()

#assert(game-variant(g) == "chess960", message: "variant: " + game-variant(g))
#assert(
  to-fen(game-start(g)) == "rnbnkqrb/pppppppp/8/8/8/8/PPPPPPPP/RNBNKQRB w KQkq - 0 1",
  message: "start: " + to-fen(game-start(g)),
)

// The position at the start of move 11 (after 10...Bf5, before 11.O-O) is exactly
// Scharnagl's published X-FEN, including the "Gkq" castling field.
#assert(
  to-fen(position-after(g, "10b")) == "rn2k1r1/ppp1pp1p/3p2p1/5bn1/P7/2N2B2/1PPPPP2/2BNK1RR w Gkq - 4 11",
  message: "move-11 X-FEN: " + to-fen(position-after(g, "10b")),
)

// 11.O-O is legal from there: king e1->g1, g1-rook->f1 (the h1-rook stays put),
// and both White castling rights are then gone.
#assert(
  to-fen(position-after(g, "11w")) == "rn2k1r1/ppp1pp1p/3p2p1/5bn1/P7/2N2B2/1PPPPP2/2BN1RKR b kq - 5 11",
  message: "after 11.O-O: " + to-fen(position-after(g, "11w")),
)

= Scharnagl Chess960 game — the "Gkq" X-FEN

#chess960-diagram(position-after(g, "10b"), size: 4.5cm,
  caption: [Before 11.O-O. White may castle king-side with the g1-rook; the outer
  h1-rook forces the X-FEN file letter, giving `Gkq`.])
