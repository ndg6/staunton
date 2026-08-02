// Source for the README showcase #3 (tournament standings). Keep in sync with its
// README code block. Regenerate with:
//   typst compile --root . --format png --ppi 160 docs/img/showcase-table.typ docs/img/showcase-table.png
#import "/lib.typ": games, standings-table

#set page(width: auto, height: auto, margin: 12pt, fill: white)
#set text(font: "Libertinus Serif", size: 11pt)

// A small single round-robin (4 players, 6 games) — enough for standings + tiebreaks.
#let gs = games(```
[White "Carlsen"][Black "Nakamura"][Result "1-0"][Round "1"] 1-0
[White "Caruana"][Black "Nepomniachtchi"][Result "1/2-1/2"][Round "1"] 1/2-1/2
[White "Carlsen"][Black "Caruana"][Result "1/2-1/2"][Round "2"] 1/2-1/2
[White "Nepomniachtchi"][Black "Nakamura"][Result "1-0"][Round "2"] 1-0
[White "Carlsen"][Black "Nepomniachtchi"][Result "1-0"][Round "3"] 1-0
[White "Nakamura"][Black "Caruana"][Result "0-1"][Round "3"] 0-1
```)

#standings-table(gs, caption: [Final standings])
