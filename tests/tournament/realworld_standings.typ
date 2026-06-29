// smoke test over a real division (roster-only subset of
// real_tournament.pgn). Player standings only sum per-player points, so they are
// robust regardless of the file's (non-standard) round numbering. (The full
// tournament file is too large for Typst's loop limit; this is the M1 subset.)
#import "/lib.typ": parse-pgn, standings, standings-table

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 8pt)

#let g = parse-pgn(read("/tests/pgn/realworld/M1_roster.pgn"))
#assert(g.len() == 87, message: "M1 subset has 87 games, got " + str(g.len()))
#let s = standings(g, by: "player")
#assert(s.len() > 0, message: "non-empty standings")
#assert(s.first().score >= s.last().score, message: "sorted best-first")

= M1 individual standings (real data)
#standings-table(g, by: "player")
