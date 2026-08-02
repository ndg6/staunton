// The arity contract of the two readers, asserted positively (the refusal case
// is tests/pgn/handling/malformed/game_on_multiple_games.typ).
#import "/lib.typ": game, games

#let one = "[White \"A\"] 1. e4 *"
#let two = "[White \"A\"] 1. e4 *\n\n[White \"B\"] 1. d4 *"

// games() ALWAYS returns an array -- including for a single game, which is the
// whole reason it is spelled in the plural.
#assert(type(games(one)) == array, message: "games() must return an array")
#assert(games(one).len() == 1, message: "games() on one game -> array of 1")
#assert(games(two).len() == 2, message: "games() on two games -> array of 2")

// game() returns the dict itself, not a one-element array.
#assert(type(game(one)) == dictionary, message: "game() must return a dictionary")
#assert(game(one) == games(one).first(), message: "game(x) == games(x).first() for single-game input")

// Tag roster is optional on BOTH readers: bare movetext is valid input.
#assert(game("1. e4 e5 *").tags == (:), message: "bare movetext -> empty roster")
#assert(games("1. e4 e5 *").len() == 1, message: "bare movetext -> one game")

Arity contract holds.
