// The two pieces of per-square material logic added in 1.0.0, both pure and so
// directly assertable (the rendered overlay is an `image` inside a `place`,
// which Typst cannot `query()` -- same precedent as `_material-asset`):
//
//   1. `_material-variant` -- which of the two marble artworks a square uses.
//   2. the `pattern-light` style field -- whether light squares are patterned
//      at all. Default `true`; `false` restores the pre-1.0 wood look.
#import "/src/board.typ": _material-variant, _material-asset, _material-orientation
#import "/src/coords.typ": is-dark-square
#import "/src/style.typ": default-board-style, board-style-keys

// --- 1. variant selection --------------------------------------------------

// Deterministic: the same cell must always pick the same artwork, or a board
// would render differently between builds.
#assert.eq(_material-variant(3, 5), _material-variant(3, 5),
  message: "_material-variant must be deterministic for a given cell")

// Only ever 1 or 2 -- an out-of-range value would resolve to a nonexistent
// asset path and fail at render time, far from the cause.
#for r in range(8) {
  for c in range(8) {
    let v = _material-variant(r, c)
    assert(v == 1 or v == 2, message: "_material-variant must return 1 or 2; got " + repr(v))
  }
}

// Both variants must occur WITHIN EACH SQUARE COLOR -- and this is the whole
// point of the test, so read the reason before touching it.
//
// The first version of this file swept the whole board into ONE list and
// asserted it saw both variants. That passes under the exact defect it was
// written to catch: the original hash `rem(row*31 + col*17 + 5, 2)` had odd
// multipliers, so mod 2 it WAS the parity of `row + col` -- i.e.
// `is-dark-square`. Every dark square took variant 2 and every light square
// variant 1, so both variants "occurred" board-wide while each square color in
// fact used a single artwork and two of the four assets were never drawn. The
// pooled assertion cannot see that; a per-square-color one can.
#let dark-seen = ()
#let light-seen = ()
#for r in range(8) {
  for c in range(8) {
    let v = _material-variant(r, c)
    if is-dark-square(c, r) {
      if not dark-seen.contains(v) { dark-seen.push(v) }
    } else {
      if not light-seen.contains(v) { light-seen.push(v) }
    }
  }
}
#assert.eq(dark-seen.len(), 2,
  message: "both marble variants must occur among DARK squares -- if the variant hash " +
    "collapses onto the checker parity, dark squares all share one artwork and the " +
    "second dark asset is never drawn")
#assert.eq(light-seen.len(), 2,
  message: "both marble variants must occur among LIGHT squares -- same degeneracy, " +
    "mirrored: light squares all share one artwork and the second light asset is dead")

// Directly forbid the degenerate relationship, so the failure names its cause
// rather than showing up as a puzzling count mismatch.
#let by-parity = ()
#for r in range(8) {
  for c in range(8) {
    let p = (is-dark-square(c, r), _material-variant(r, c))
    if not by-parity.contains(p) { by-parity.push(p) }
  }
}
#assert(by-parity.len() > 2,
  message: "the marble variant must NOT be a function of square color -- only " +
    repr(by-parity.len()) + " (is-dark, variant) pairs exist, meaning the hash reduced to " +
    "the checker parity (odd multipliers with a plain `rem(.., 2)` do exactly this)")

// The variant must also stay independent of `_material-orientation`: sharing
// that hash would make this its low bit and pin variant to rotation, halving
// the distinct looks from 16 to 8.
#let combos = ()
#for r in range(8) {
  for c in range(8) {
    let p = (_material-variant(r, c), _material-orientation("marble", r, c))
    if not combos.contains(p) { combos.push(p) }
  }
}
#assert.eq(combos.len(), 16,
  message: "variant and orientation must be independent: expected all 16 " +
    "(variant, orientation) pairs, got " + repr(combos.len()) + " -- a correlated hash " +
    "halves the distinct per-square looks")

// Both variants must resolve to assets that really exist, for both square
// colors. A typo'd path only surfaces as a render error otherwise.
#for v in (1, 2) {
  for is-d in (true, false) {
    let p = _material-asset("marble", is-d, variant: v)
    assert(read("/src/" + p, encoding: none).len() > 0,
      message: "marble asset " + p + " must exist and be non-empty")
  }
}

// --- 2. the `pattern-light` field ------------------------------------------

// Registered as a real board-style field, defaulting to on. `board-style-keys`
// derives from this dict, so being absent here means `set-board-defaults`
// would reject the option outright.
#assert.eq(default-board-style.pattern-light, true,
  message: "pattern-light must default to true -- both square colors patterned")
#assert(board-style-keys.contains("pattern-light"),
  message: "pattern-light must be an accepted board-style key")
#assert.eq(type(default-board-style.pattern-light), bool,
  message: "pattern-light must be a boolean field")

// The field gates DRAWING, not asset resolution: `_material-asset` still
// reports a light-square asset regardless, and `_checker` decides whether to
// place it. Pinned so the gate is not "helpfully" pushed down into the
// resolver, which would break the band (it shares neither path nor gate).
#assert.ne(_material-asset("wood", false), none,
  message: "the pattern-light gate belongs in _checker, not _material-asset -- " +
    "the resolver must still report a light-square asset")
