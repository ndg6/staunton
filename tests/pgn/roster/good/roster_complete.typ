// PGN (good) - a complete Seven-Tag-Roster parses and the tags are readable.
// (Missing roster tags are tolerated and default; that lenient path is exercised
// elsewhere. Here we confirm a well-formed roster round-trips.)
#import "/lib.typ": parse-pgn, mainline

#set page(width: auto, height: auto, margin: 1cm)

#let game = parse-pgn(```
[Event "Test Open"]
[Site "Somewhere"]
[Date "2024.01.15"]
[Round "1"]
[White "Player, One"]
[Black "Player, Two"]
[Result "1-0"]

1. e4 e5 2. Nf3 Nc6 1-0
```).first()

#assert(game.tags.at("White") == "Player, One", message: "White tag")
#assert(game.tags.at("Event") == "Test Open", message: "Event tag")
#assert(game.tags.at("Result") == "1-0", message: "Result tag")
#assert(mainline(game) == ("e4", "e5", "Nf3", "Nc6"), message: "mainline SANs")

Roster parsed: #game.tags.at("White") vs #game.tags.at("Black"),
#game.tags.at("Event") (#game.tags.at("Date")).
