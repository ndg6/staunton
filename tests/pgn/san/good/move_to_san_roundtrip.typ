// Round-trip corpus for `move-to-san` (the inverse of `san-to-move`): for every
// mainline move m at position p, `move-to-san(p, m)` must encode a SAN token
// that `san-to-move` resolves back to the SAME move. We do NOT string-compare
// against the source PGN's own SAN -- real games may legally over-disambiguate
// or omit +/# suffixes, which would be a false failure here.
//
// Runtime is kept in check by replaying only two games: one full standard game
// (captures, a king-side castle) and the Chess960 Scharnagl game (castling with
// a non-h1 rook, the Chess960-safe path). Not every realworld/*.pgn fixture is
// replayed -- these two already exercise captures, castling and both variants.
#import "/lib.typ": game, mainline, game-start, apply, move-to-san
#import "/src/san.typ": san-to-move

#set page(width: auto, height: auto, margin: 1cm)

// A single replay-and-check pass over one game's mainline.
#let check-roundtrip(game, label) = {
  let pos = game-start(game)
  for s in mainline(game) {
    let mv = san-to-move(pos, s)
    let encoded = move-to-san(pos, mv)
    let mv2 = san-to-move(pos, encoded)
    assert(
      mv2 == mv,
      message: label + ": round-trip mismatch at SAN \"" + s + "\" -> encoded \"" + encoded
        + "\": " + repr(mv2) + " != " + repr(mv),
    )
    pos = apply(pos, mv)
  }
}

// -- standard game: Italian / Two Knights (32 plies, mainline only; captures,
// a king-side castle) --
#let g = game(read("/tests/pgn/realworld/italian_two_knights.pgn"))
#assert(mainline(g).len() == 32, message: "mainline: 16 full moves (32 plies)")
#check-roundtrip(g, "italian_two_knights")

// -- Chess960: Scharnagl's SmirfGUI game (11 plies incl. king-side castling
// where the castling rook is NOT on h1 -- the general Chess960-safe path) --
#let pgn960 = ```
[Event "SmirfGUI Computerchess Game"]
[SetUp "1"]
[Variant "Fischerrandom"]
[FEN "rnbnkqrb/pppppppp/8/8/8/8/PPPPPPPP/RNBNKQRB w KQkq - 0 1"]
1. h4 g6 2. g3 Bf6 3. a4 Qh6 4. Ra3 Bxh4 5. gxh4 Qxh4 6. Qh3 Qxh3 7. Rxh3 Ne6
8. Bf3 d6 9. Nbc3 Ng5 10. Rhh1 Bf5 11. O-O *
```
#let g960 = game(pgn960)
#assert(mainline(g960).len() == 21, message: "chess960 mainline plies")
#check-roundtrip(g960, "scharnagl_chess960")

= move-to-san round-trip: real games replay cleanly

Both the standard Italian/Two Knights game and Scharnagl's Chess960 game replay
with `move-to-san` round-tripping through `san-to-move` at every ply.
