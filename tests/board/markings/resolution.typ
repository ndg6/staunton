// Move-markings (prompt 27) data resolution — the machine-checkable core behind
// the in-check glow and the move-quality badge. Asserts only; the visual sheet is
// markings.typ.
//   * checked-king-square: the side-to-move king when (and only when) in check.
//   * move-destination: where the addressed move landed (captures, castling,
//     promotion, mainline + variations).
// (move-quality-mark has its own sheet: move_quality.typ.)
#import "/src/engine.typ": checked-king-square
#import "/src/game.typ": move-destination
#import "/lib.typ": position, game

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

// ---- checked-king-square --------------------------------------------------
// Scholar's-mate final position: Black to move, its king on e8 is in check.
#assert.eq(
  checked-king-square(position("rnb1kbnr/pppp1Qpp/8/4p3/2B1P3/8/PPPP1PPP/RNB1K1NR b KQkq - 0 4")),
  "e8",
)
// Not in check -> none. Test both sides to move.
#assert.eq(checked-king-square(position("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")), none)
#assert.eq(checked-king-square(position("4k3/8/8/8/8/8/8/4K3 b - - 0 1")), none)
// White king in check (a rook checks along the file): white to move -> e1.
#assert.eq(checked-king-square(position("4k3/8/8/8/8/8/8/r3K3 w - - 0 1")), "e1")

// ---- move-destination -----------------------------------------------------
#let g = game(
  "[White \"A\"][Black \"B\"] 1. e4 e5 2. Qh5 Nc6 3. Bc4 Nf6?? 4. Qxf7# 1-0",
)
#assert.eq(move-destination(g, "1w"), "e4")   // first move (before = start)
#assert.eq(move-destination(g, "3b"), "f6")   // knight move
#assert.eq(move-destination(g, "4w"), "f7")   // capture (Qxf7)

// castling + promotion destinations resolve from the move (not the SAN text)
#let gc = game("[W \"a\"][B \"b\"] 1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. O-O Nf6 *")
#assert.eq(move-destination(gc, "4w"), "g1")   // O-O -> king to g1
#let gp = game("[W \"a\"][B \"b\"] 1. e4 d5 2. exd5 Qxd5 3. Nc3 Qa5 4. d4 c6 5. Nf3 Bg4 *")
#assert.eq(move-destination(gp, "2w"), "d5")   // exd5 capture

// destination inside a variation (path locator)
#let gv = game("[W \"a\"][B \"b\"] 1. e4 e5 (1... c5 2. Nf3) 2. Nf3 *")
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
#assert.eq(_resolve-square-dim(auto, 4cm, 10%), 0.4cm)    // mark stroke default (10%): cross/circle/frame
#assert.eq(_resolve-square-dim(auto, 4cm, 15%), 0.6cm)    // ARROW stroke default (15%) -- arrows stay heavier
#assert.eq(_resolve-square-dim(auto, 4cm, 3%), 0.12cm)    // circle-margin default
#assert.eq(_resolve-square-dim(auto, 2cm, 10%), 0.2cm)    // cross-margin default (corner-to-tip)
#assert.eq(_resolve-square-dim(10%, 4cm, 15%), 0.4cm)     // explicit ratio wins
#assert.eq(_resolve-square-dim(2pt, 4cm, 15%), 2pt)       // absolute escape hatch
// The 22% default radius resolves like any other proportional dimension.
#assert.eq(_resolve-square-dim(auto, 4cm, 22%), 0.88cm)   // frame-radius default (22%)

// ---- _frame-geom: "frame" highlight geometry (prompt 51) -------------------
// Pure arithmetic over already-resolved lengths -- no board/style dependency, so
// it is asserted directly (same rationale as _resolve-square-dim above).
#import "/src/board.typ": _frame-geom

// (a) outer-edge invariant: the drawn rect's outer stroke edge sits `m` inside
// the square border on both the near and far side, for two different
// (sq, w, m) triples.
#for (sq, w, m) in ((4cm, 0.6cm, 0.12cm), (3cm, 0.2cm, 0.05cm)) {
  let geom = _frame-geom(sq, w, m, 5pt)
  assert.eq(geom.offset - w / 2, m, message: "outer edge should sit m from the near side")
  assert.eq(geom.offset + geom.side + w / 2, sq - m, message: "outer edge should sit m from the far side")
}

// (b) radius passes through UNMODIFIED (no `- w/2` "correction"): unlike the
// circle branch, `rect(radius:)` does not straddle the corner with the stroke,
// so the outer corner radius equals `frame-radius` exactly as passed. A
// `- w/2` shrink here would silently draw corners too tight and no test would
// catch it if this assert were only checking the field exists.
#assert.eq(_frame-geom(4cm, 0.6cm, 0.12cm, 0.5cm).radius, 0.5cm)

// (c) the clamp: an over-large radius is capped at half of (sq - 2*m), not
// passed through.
#let clamped = _frame-geom(4cm, 0.6cm, 0.12cm, 10cm)
#assert.eq(clamped.radius, (4cm - 2 * 0.12cm) / 2)
#assert.ne(clamped.radius, 10cm)

// (d) `auto` defaults resolve to the documented ratios (10% width, 3% margin,
// 22% radius) -- `_frame-geom` now resolves raw style values internally. The
// expected numbers below are LITERAL lengths, computed by hand, NOT by calling
// `_resolve-square-dim(auto, sq, ratio)` here: that would just mirror the
// implementation and could not catch the implementation resolving the wrong
// ratio against the wrong field (e.g. margin and radius transposed) --
// exactly the bug this assert exists to catch. Do not "simplify" this back to
// a call through `_resolve-square-dim`.
#let g4 = _frame-geom(4cm, auto, auto, auto)
#assert.eq(g4.width, 0.4cm)    // 10% of 4cm
#assert.eq(g4.offset, 0.32cm)  // 3% margin (0.12cm) + half the 0.4cm stroke
#assert.eq(g4.side, 3.36cm)    // 4cm - 2*0.12cm - 0.4cm
#assert.eq(g4.radius, 0.88cm)  // 22% of 4cm

#let g2 = _frame-geom(2cm, auto, auto, auto)
#assert.eq(g2.width, 0.2cm)    // 10% of 2cm
#assert.eq(g2.offset, 0.16cm)  // 3% margin (0.06cm) + half the 0.2cm stroke
#assert.eq(g2.side, 1.68cm)    // 2cm - 2*0.06cm - 0.2cm
#assert.eq(g2.radius, 0.44cm)  // 22% of 2cm

= move-markings resolution
All assertions passed.
