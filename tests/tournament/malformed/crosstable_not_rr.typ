// EXPECT: do not form a round-robin
// cross-table requires a round-robin; in a Swiss/league where some
// pair never met it errors (use standings + progress instead).
#import "/lib.typ": parse-pgn, crosstable
#let g = parse-pgn(```
[White "A"][Black "B"][Result "1-0"] 1-0
[White "A"][Black "C"][Result "1-0"] 1-0
```)
// B and C never met -> not a round-robin
#let _ = crosstable(g, by: "player")
