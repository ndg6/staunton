// Pure `_table-style-args` helper (prompt 42, table styling) — pins the
// stroke/fill/align FUNCTIONS the three `*-table` renderers wire into `#table`.
// Rendered tables aren't `query()`-able, so this is the machine-checkable seam;
// the eyeball pass lives in tournament/styling.typ (render-only).
#import "/src/tournament.typ": _table-style-args, _winner-bold, _crosstable-diagonal-fill

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

// Shared shape: 7 data columns, 5 rows (1 header + 4 body), name column 1.
#let cols = 7
#let nrows = 5

// 1. Default-ish look: gray header, zebra body, header centered, body left.
#let st1 = (
  grid: "complete", header-align: center, header-fill: "gray",
  body-align: left, body-fill: "zebra",
  table-align: center, caption-bold: false, highlight-winners: true,
)
#let sa1 = _table-style-args(st1, cols, nrows, 1)
#assert.eq((sa1.fill)(0, 0), luma(230), message: "header-fill \"gray\" -> luma(230)")
#assert.eq((sa1.fill)(1, 2), luma(245), message: "zebra shades even body rows -> luma(245)")
#assert.eq((sa1.fill)(1, 1), none, message: "zebra leaves odd body rows unfilled")
#assert.eq((sa1.align)(3, 0), center, message: "header row -> header-align")
#assert.eq((sa1.align)(1, 3), left, message: "name column -> always left, any body row")
#assert.eq((sa1.align)(3, 3), left, message: "data column -> body-align (here left)")
#assert.eq(
  (sa1.stroke)(0, 0),
  (left: 1pt, top: 1pt, right: none, bottom: none),
  message: "complete grid: top-left corner is outer-thick on left/top only",
)

// 2. grid: "no-outer" — inner lines survive, all four border lines vanish.
#let st2 = st1 + (grid: "no-outer")
#let sa2 = _table-style-args(st2, cols, nrows, 1)
#assert.eq(
  (sa2.stroke)(0, 0),
  (left: none, top: none, right: none, bottom: none),
  message: "no-outer: top-left corner has no border lines",
)
#assert.eq(
  (sa2.stroke)(1, 1),
  (left: 0.5pt, top: 0.5pt, right: none, bottom: none),
  message: "no-outer: an inner cell still carries the 0.5pt inner lines",
)

// 3. grid: "header-rule" — only the y==1 horizontal rule is drawn.
#let st3 = st1 + (grid: "header-rule")
#let sa3 = _table-style-args(st3, cols, nrows, 1)
#assert.eq((sa3.stroke)(3, 1).top, 1pt, message: "header-rule: 1pt line under the header row")
#assert.eq(
  (sa3.stroke)(3, 1),
  (top: 1pt, left: none, right: none, bottom: none),
  message: "header-rule: only top is set, everything else none",
)
#assert.eq((sa3.stroke)(3, 0).top, none, message: "header-rule: no rule above the header (y != 1)")

// 4. Last-cell corner for "complete": outer-thick on right/bottom too.
#assert.eq(
  (sa1.stroke)(cols - 1, nrows - 1),
  (left: 0.5pt, top: 0.5pt, right: 1pt, bottom: 1pt),
  message: "complete grid: bottom-right corner is outer-thick on right/bottom",
)

// 5. header-fill: none / body-fill: none -> fill is none everywhere.
#let st5 = st1 + (header-fill: none, body-fill: none)
#let sa5 = _table-style-args(st5, cols, nrows, 1)
#assert.eq((sa5.fill)(0, 0), none, message: "header-fill: none -> no header fill")
#assert.eq((sa5.fill)(1, 1), none, message: "body-fill: none -> no body fill (odd row)")
#assert.eq((sa5.fill)(1, 2), none, message: "body-fill: none -> no body fill (even row either)")

// 6. header-align: right, body-align: center variations.
#let st6 = st1 + (header-align: right, body-align: center)
#let sa6 = _table-style-args(st6, cols, nrows, 1)
#assert.eq((sa6.align)(3, 0), right, message: "header-align: right applies to the header row")
#assert.eq((sa6.align)(3, 3), center, message: "body-align: center applies to data columns")
#assert.eq((sa6.align)(1, 3), left, message: "name column stays left even when body-align is center")

// 7. _winner-bold: which cells of a rank-1 row get bolded (name-col=1, pts-col=6).
#assert.eq(_winner-bold(true, 1, 1, 1, 6), true, message: "rank-1 name cell is bold")
#assert.eq(_winner-bold(true, 1, 6, 1, 6), true, message: "rank-1 points cell is bold")
#assert.eq(_winner-bold(true, 1, 3, 1, 6), false, message: "rank-1 but a data column -> not bold")
#assert.eq(_winner-bold(true, 2, 1, 1, 6), false, message: "name cell but not rank 1 -> not bold")
#assert.eq(_winner-bold(false, 1, 1, 1, 6), false, message: "highlight-winners off -> never bold")

// 8. _crosstable-diagonal-fill: self/self diagonal cell color.
#assert.eq(_crosstable-diagonal-fill(none), luma(220), message: "no zebra -> classic gray diagonal")
#assert.eq(_crosstable-diagonal-fill("zebra"), rgb("#c9d6e5"), message: "zebra -> distinct blue tint diagonal")
#assert.eq(_crosstable-diagonal-fill(luma(245)), rgb("#c9d6e5"), message: "any non-none body-fill -> tint diagonal")

= table-style-args
All assertions passed.
