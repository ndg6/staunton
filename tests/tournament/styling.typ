// Render-only (no asserts): tournament-table styling options (prompt 42).
// The machine-checkable pure mapping is pinned in tournament/table_style_args.typ;
// this sheet is for the human eyeball pass — see tests/VISUAL_CHECKS.md.
#import "/lib.typ": games, standings-table, crosstable-table, set-table-defaults

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

// Small round-robin, same shape as tests/tournament/standings.typ: A>all,
// B>{C,D}, C>D -- gives a clear rank-1 winner (A) to check winner-bold.
#let rr = games(```
[White "A"][Black "B"][Result "1-0"] 1-0
[White "A"][Black "C"][Result "1-0"] 1-0
[White "A"][Black "D"][Result "1-0"] 1-0
[White "B"][Black "C"][Result "1-0"] 1-0
[White "B"][Black "D"][Result "1-0"] 1-0
[White "C"][Black "D"][Result "1-0"] 1-0
```)

= 1. Default look
#standings-table(rr, by: "player", caption: [Default styling])

= 2. grid presets
== no-outer
#standings-table(rr, by: "player", grid: "no-outer", caption: [grid: "no-outer"])
== header-rule
#standings-table(rr, by: "player", grid: "header-rule", caption: [grid: "header-rule"])

= 3. header-fill: "gray"
#standings-table(rr, by: "player", header-fill: "gray", caption: [header-fill: "gray"])

= 4. body-fill: "zebra"
#standings-table(rr, by: "player", body-fill: "zebra", caption: [body-fill: "zebra"])

= 5. crosstable with zebra (diagonal recolored)
#crosstable-table(rr, by: "player", body-fill: "zebra", caption: [crosstable, body-fill: "zebra"])

= 6. table-align
== left
#standings-table(rr, by: "player", table-align: left, caption: [table-align: left -- the TABLE hugs the left margin; the caption stays centered (does not follow)])
== right
#standings-table(rr, by: "player", table-align: right, caption: [table-align: right -- the TABLE hugs the right margin; the caption stays centered (does not follow)])

= 7. caption-bold: true
#standings-table(rr, by: "player", caption-bold: true, caption: [This caption should render bold])

= 8. highlight-winners: false
#standings-table(rr, by: "player", highlight-winners: false, caption: [highlight-winners: false -- A's name/points should NOT be bold, unlike section 1])

= 9. header repeat across pages
// A fixed short page height forces this standings table to spill onto a second
// page; the header row (rank/player/+/=/-/points) should repeat at the top of
// page 2. Page size is reset to auto afterwards for the rest of the document
// (there is none, this is the last section).
#set page(height: 6cm)
#standings-table(rr, by: "player", caption: [Forced page break -- header should repeat on page 2])
