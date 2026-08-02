// EXPECT: malformed PGN tag pair
// A roster tag with no value is malformed (this is NOT mere leniency about a
// *missing* tag; the tag syntax itself is broken).
#import "/src/pgn.typ": game
#let _ = game("[White]

1. e4 e5 *")
