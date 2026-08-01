// The in-check glow's Lichess-style radial gradient (prompt 50). `board.typ`
// draws this via `place(.., rect(fill: _check-gradient(color)))`, which is a
// rendered fill and NOT queryable (CLAUDE.md §6) -- but `_check-gradient`
// itself is a pure helper that returns a `gradient`, and `gradient.stops()`
// is inspectable, so we assert the stop structure directly. The rendered
// look (glow under the king, blue on the custom-color board) is eyeballed in
// markings.typ; this sheet is the machine-checkable seam behind it.
#import "/src/board.typ": _check-gradient

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

// ---- structure: four stops at the documented offsets ----------------------
#let g-red = _check-gradient(rgb(255, 0, 0))
#let stops-red = g-red.stops()
#assert.eq(stops-red.len(), 4)
#assert.eq(stops-red.map(s => s.at(1)), (0%, 25%, 89%, 100%))

// ---- radius: 70.71% (CSS farthest-corner), NOT Typst's 50% default --------
// The single most fragile measured value in the whole change: dropping the
// `radius:` argument silently reverts to the 50% inscribed-circle look (the
// OLD "fills to the edge midpoints, bare corners" shape this change replaced),
// and nothing else here would notice.
#assert.eq(g-red.radius(), 70.71%)

// ---- alpha: the two outer stops are fully transparent, the inner two are not
#let alpha-of(c) = rgb(c).components().at(3)
#assert.eq(alpha-of(stops-red.at(0).at(0)), 100%)   // centre: opaque
#assert.eq(alpha-of(stops-red.at(1).at(0)), 100%)   // mid: opaque
#assert.eq(alpha-of(stops-red.at(2).at(0)), 0%)     // outer: fully clear
#assert.eq(alpha-of(stops-red.at(3).at(0)), 0%)     // edge: fully clear

// ---- darkening: the mid (25%) stop is darker than the centre (0%) stop ----
// "darker" = lower summed RGB channels (both are opaque so alpha doesn't
// confound the comparison).
#let rgb-sum(c) = {
  let k = rgb(c).components()
  k.at(0) + k.at(1) + k.at(2)
}
#assert(rgb-sum(stops-red.at(1).at(0)) < rgb-sum(stops-red.at(0).at(0)))

// ---- the same structure holds for a non-red check-color -------------------
// This is what proves the gradient is DERIVED from `color`, not hard-coded to
// red: a blue check-color must still glow blue, with the same 4-stop, 2
// opaque + 2 transparent, centre-darker-at-mid profile.
#let g-blue = _check-gradient(rgb(0, 0, 255))
#let stops-blue = g-blue.stops()
#assert.eq(stops-blue.len(), 4)
#assert.eq(stops-blue.map(s => s.at(1)), (0%, 25%, 89%, 100%))
#assert.eq(alpha-of(stops-blue.at(0).at(0)), 100%)
#assert.eq(alpha-of(stops-blue.at(1).at(0)), 100%)
#assert.eq(alpha-of(stops-blue.at(2).at(0)), 0%)
#assert.eq(alpha-of(stops-blue.at(3).at(0)), 0%)
#assert(rgb-sum(stops-blue.at(1).at(0)) < rgb-sum(stops-blue.at(0).at(0)))
// and the hue is blue, not red: the blue channel dominates the centre stop
#let comps-blue-centre = rgb(stops-blue.at(0).at(0)).components()
#assert(comps-blue-centre.at(2) > comps-blue-centre.at(0))

// ---- the transparent stops keep the colour's hue at alpha 0 ("hueless fade",
// not "grey fade"): even though the outer (89%) stop is fully transparent, its
// underlying RGB must still be blue-dominant. A fade to `rgb(0,0,0,0%)` (plain
// transparent black) would pass every alpha/offset assertion above but grey out
// visibly under interpolation -- this is what catches that.
#let comps-blue-outer = rgb(stops-blue.at(2).at(0)).components()
#assert(comps-blue-outer.at(2) > comps-blue-outer.at(0))

// (default check-color -- pure rgb(255, 0, 0), not Typst's coral `red` -- is
// owned by tests/board/markings/options.typ; not re-asserted here.)

= check-gradient
All assertions passed.
