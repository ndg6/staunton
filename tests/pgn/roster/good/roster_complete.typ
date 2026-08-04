// PGN (good) - a complete Seven-Tag-Roster parses and the tags are readable.
// (Missing roster tags are tolerated and default; that lenient path is exercised
// elsewhere. Here we confirm a well-formed roster round-trips.)
#import "/lib.typ": game, mainline

#set page(width: auto, height: auto, margin: 1cm)

#let g = game(```
[Event "Test Open"]
[Site "Somewhere"]
[Date "2024.01.15"]
[Round "1"]
[White "Player, One"]
[Black "Player, Two"]
[Result "1-0"]

1. e4 e5 2. Nf3 Nc6 1-0
```)

#assert(g.tags.at("White") == "Player, One", message: "White tag")
#assert(g.tags.at("Event") == "Test Open", message: "Event tag")
#assert(g.tags.at("Result") == "1-0", message: "Result tag")
#assert(mainline(g) == ("e4", "e5", "Nf3", "Nc6"), message: "mainline SANs")

Roster parsed: #g.tags.at("White") vs #g.tags.at("Black"),
#g.tags.at("Event") (#g.tags.at("Date")).
