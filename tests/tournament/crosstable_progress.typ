// §prompt 16 (Stage 2/3) - cross-table (round-robin only) and progress (round by
// round), for player and team entities.
#import "/lib.typ": parse-pgn, crosstable, crosstable-table, progress, progress-table

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

// player round-robin, with rounds
#let rr = parse-pgn(```
[White "A"][Black "B"][Round "1"][Result "1-0"] 1-0
[White "C"][Black "D"][Round "1"][Result "1-0"] 1-0
[White "A"][Black "C"][Round "2"][Result "1-0"] 1-0
[White "B"][Black "D"][Round "2"][Result "1-0"] 1-0
[White "A"][Black "D"][Round "3"][Result "1-0"] 1-0
[White "B"][Black "C"][Round "3"][Result "1-0"] 1-0
```)

// --- cross-table ---
#let ct = crosstable(rr, by: "player")
#assert(ct.names == ("A", "B", "C", "D"), message: "cross-table rows in standings order")
#assert(ct.matrix.at(0) == (none, 1.0, 1.0, 1.0), message: "row A beat all (diag none)")
#assert(ct.matrix.at(1) == (0.0, none, 1.0, 1.0), message: "row B")
#assert(ct.matrix.at(3) == (0.0, 0.0, 0.0, none), message: "row D lost all")
#assert(ct.totals == (3.0, 2.0, 1.0, 0.0), message: "row totals = scores")

// --- progress ---
#let pg = progress(rr, by: "player")
#assert(pg.rounds == (1, 2, 3), message: "rounds discovered + sorted")
#assert(pg.cells.at(0).map(c => c.cumulative) == (1.0, 2.0, 3.0), message: "A cumulative 1,2,3")
#assert(pg.cells.at(3).map(c => c.score) == (0.0, 0.0, 0.0), message: "D scored 0 each round")

// --- team cross-table + progress (2 teams meet in R1 and R2) ---
#let tm = parse-pgn(```
[White "P1"][Black "P2"][WhiteTeam "Alpha"][BlackTeam "Beta"][Round "1.1"][Result "1-0"] 1-0
[White "P3"][Black "P4"][WhiteTeam "Beta"][BlackTeam "Alpha"][Round "1.2"][Result "1-0"] 1-0
[White "P1"][Black "P2"][WhiteTeam "Alpha"][BlackTeam "Beta"][Round "2.1"][Result "1-0"] 1-0
[White "P3"][Black "P4"][WhiteTeam "Beta"][BlackTeam "Alpha"][Round "2.2"][Result "1/2-1/2"] 1/2-1/2
```)
#let tct = crosstable(tm, by: "team")
// Alpha's board points vs Beta across both matches: R1 1 + R2 1.5 = 2.5
#assert(tct.matrix.at(0).at(1) == 2.5, message: "Alpha board points vs Beta = 2.5")
#assert(tct.matrix.at(1).at(0) == 1.5, message: "Beta board points vs Alpha = 1.5")
#assert(tct.totals == (3.0, 1.0), message: "team totals = match points")

#let tpg = progress(tm, by: "team")
#assert(tpg.rounds == (1, 2), message: "team rounds")
// Alpha match points per round: R1 draw -> 1, R2 win -> 2 ; cumulative 1,3
#assert(tpg.cells.at(0).map(c => c.score) == (1.0, 2.0), message: "Alpha mp per round")
#assert(tpg.cells.at(0).map(c => c.cumulative) == (1.0, 3.0), message: "Alpha cumulative mp")

= Cross-table (round-robin)
#crosstable-table(rr, by: "player")

#v(1em)
= Progress
#progress-table(rr, by: "player")

#v(1em)
= Team cross-table
#crosstable-table(tm, by: "team")
