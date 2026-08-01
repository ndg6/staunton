// Move-markings (prompt 27) data resolution — the machine-checkable core behind
// the in-check glow and the move-quality badge. Asserts only; the visual sheet is
// markings.typ.
//   * checked-king-square: the side-to-move king when (and only when) in check.
//   * move-destination: where the addressed move landed (captures, castling,
//     promotion, mainline + variations).
// (move-quality-mark has its own sheet: move_quality.typ.)
#import "/src/engine.typ": checked-king-square
#import "/src/game.typ": move-destination
#import "/src/fen.typ": parse-fen
#import "/lib.typ": parse-pgn

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

// ---- checked-king-square --------------------------------------------------
// Scholar's-mate final position: Black to move, its king on e8 is in check.
#assert.eq(
  checked-king-square(parse-fen("rnb1kbnr/pppp1Qpp/8/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4")),
  "e8",
)
// Not in check -> none. Test both sides to move.
#assert.eq(checked-king-square(parse-fen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")), none)
#assert.eq(checked-king-square(parse-fen("4k3/8/8/8/8/8/8/4K3 b - - 0 1")), none)
// White king in check (a rook checks along the file): white to move -> e1.
#assert.eq(checked-king-square(parse-fen("4k3/8/8/8/8/8/8/r3K3 w - - 0 1")), "e1")

// ---- move-destination -----------------------------------------------------
#let g = parse-pgn(
  "[White \"A\"][Black \"B\"] 1. e4 e5 2. Qh5 Nc6 3. Bc4 Nf6?? 4. Qxf7# 1-0",
).first()
#assert.eq(move-destination(g, "1w"), "e4")   // first move (before = start)
#assert.eq(move-destination(g, "3b"), "f6")   // knight move
#assert.eq(move-destination(g, "4w"), "f7")   // capture (Qxf7)

// castling + promotion destinations resolve from the move (not the SAN text)
#let gc = parse-pgn("[W \"a\"][B \"b\"] 1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. O-O Nf6 *").first()
#assert.eq(move-destination(gc, "4w"), "g1")   // O-O -> king to g1
#let gp = parse-pgn("[W \"a\"][B \"b\"] 1. e4 d5 2. exd5 Qxd5 3. Nc3 Qa5 4. d4 c6 5. Nf3 Bg4 *").first()
#assert.eq(move-destination(gp, "2w"), "d5")   // exd5 capture

// destination inside a variation (path locator)
#let gv = parse-pgn("[W \"a\"][B \"b\"] 1. e4 e5 (1... c5 2. Nf3) 2. Nf3 *").first()
#assert.eq(move-destination(gv, (line: ((at: "1b", into: 0),), at: "2w")), "f3")

// ---- move-quality-mark ----------------------------------------------------
// Deliberately NOT here: the badge-derivation matrix (six symbols x three input
// forms, NAG-vs-literal precedence, the ignored non-quality NAGs) lives in
// move_quality.typ, which owns that subject end to end. This sheet keeps the two
// markings helpers that have no other home.

// ---- _resolve-square-dim: proportional marker dimensions (0.2.2, topic 3) ---
// auto -> the default ratio * square; an explicit ratio -> that fraction of the
// square; an absolute length -> passed through unchanged.
#import "/src/board.typ": _resolve-square-dim
#assert.eq(_resolve-square-dim(auto, 4cm, 15%), 0.6cm)    // stroke default (15%)
#assert.eq(_resolve-square-dim(auto, 4cm, 3%), 0.12cm)    // circle-margin default
#assert.eq(_resolve-square-dim(auto, 2cm, 10%), 0.2cm)    // cross-margin default (corner-to-tip)
#assert.eq(_resolve-square-dim(10%, 4cm, 15%), 0.4cm)     // explicit ratio wins
#assert.eq(_resolve-square-dim(2pt, 4cm, 15%), 2pt)       // absolute escape hatch

= move-markings resolution
All assertions passed.
