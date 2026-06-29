// standings tables. Compute (`standings`) returns sorted
// records; `standings-table` renders a #table. Player and team entities; Buchholz
// / Sonneborn-Berger tie-breaks; sort = score desc, ties by first appearance.
#import "/lib.typ": parse-pgn, standings, standings-table, games-by-event

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

// --- player single round-robin: A>all, B>{C,D}, C>D ---
#let rr = parse-pgn(```
[White "A"][Black "B"][Result "1-0"] 1-0
[White "A"][Black "C"][Result "1-0"] 1-0
[White "A"][Black "D"][Result "1-0"] 1-0
[White "B"][Black "C"][Result "1-0"] 1-0
[White "B"][Black "D"][Result "1-0"] 1-0
[White "C"][Black "D"][Result "1-0"] 1-0
```)
#let sp = standings(rr, by: "player")
#assert(sp.map(r => r.name) == ("A", "B", "C", "D"), message: "RR order")
#assert(sp.map(r => r.score) == (3.0, 2.0, 1.0, 0.0), message: "RR scores")
#assert(sp.map(r => r.rank) == (1, 2, 3, 4), message: "RR ranks")
// SB = Σ opp final score × result: A = 2·1+1·1+0·1 = 3 ; B = 3·0+1·1+0·1 = 1
#assert(sp.at(0).sonneborn-berger == 3.0 and sp.at(1).sonneborn-berger == 1.0, message: "SB")
// Buchholz = Σ opp final scores: A = 2+1+0 = 3 ; D = 3+2+1 = 6
#assert(sp.at(0).buchholz == 3.0 and sp.at(3).buchholz == 6.0, message: "Buchholz")
#assert(sp.at(0).wins == 3 and sp.at(3).losses == 3, message: "W/L counts")

// --- draws and a tie broken by first appearance ---
#let dr = parse-pgn(```
[White "X"][Black "Y"][Result "1/2-1/2"] 1/2-1/2
[White "Y"][Black "X"][Result "1/2-1/2"] 1/2-1/2
```)
#let sd = standings(dr, by: "player")
#assert(sd.map(r => (r.name, r.score, r.draws)) == (("X", 1.0, 2), ("Y", 1.0, 2)), message: "two draws, X first (tie -> first appearance)")
#assert(sd.at(0).rank == 1 and sd.at(1).rank == 1, message: "equal score -> shared rank")

// --- team: 2 teams, 2 rounds, 2 boards. R1 drawn 1-1, R2 Alpha wins 1.5-0.5 ---
#let tm = parse-pgn(```
[White "P1"][Black "P2"][WhiteTeam "Alpha"][BlackTeam "Beta"][Round "1.1"][Result "1-0"] 1-0
[White "P3"][Black "P4"][WhiteTeam "Beta"][BlackTeam "Alpha"][Round "1.2"][Result "1-0"] 1-0
[White "P1"][Black "P2"][WhiteTeam "Alpha"][BlackTeam "Beta"][Round "2.1"][Result "1-0"] 1-0
[White "P3"][Black "P4"][WhiteTeam "Beta"][BlackTeam "Alpha"][Round "2.2"][Result "1/2-1/2"] 1/2-1/2
```)
#let st = standings(tm, by: "team")
#assert(st.map(r => r.name) == ("Alpha", "Beta"), message: "team order")
#assert(st.at(0).played == 2 and st.at(1).played == 2, message: "2 matches each (boards grouped per round+pair)")
#assert(st.at(0).score == 3.0 and st.at(1).score == 1.0, message: "match points: Alpha win+draw=3, Beta loss+draw=1")
#assert(st.at(0).at("board-points") == 2.5 and st.at(1).at("board-points") == 1.5, message: "board points")
#assert(st.at(0).wins == 1 and st.at(0).draws == 1, message: "Alpha match record")

// --- games-by-event splits a multi-division list ---
#let multi = parse-pgn(```
[Event "Div A"][White "A1"][Black "A2"][Result "1-0"] 1-0
[Event "Div B"][White "B1"][Black "B2"][Result "0-1"] 0-1
[Event "Div A"][White "A3"][Black "A1"][Result "1/2-1/2"] 1/2-1/2
```)
#let ev = games-by-event(multi)
#assert(ev.keys() == ("Div A", "Div B"), message: "events in first-seen order")
#assert(ev.at("Div A").len() == 2 and ev.at("Div B").len() == 1, message: "event grouping")

= Round-robin standings
#standings-table(rr, by: "player")

= Team standings
#standings-table(tm, by: "team")
