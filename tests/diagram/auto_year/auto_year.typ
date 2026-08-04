// Asserting test: automatic year from the PGN roster (the `Date` tag). A diagram
// prints " (<YEAR>)" after the players ONLY when the year is known from the
// roster; otherwise the info line is just the player names. `diagram` resolves
// the year with `year: auto` -> `_year-of(tags)`, reading the tags straight off
// the game (`source.tags`), and a caller's explicit `year:` still overrides.
// Here we lock down the roster-extraction core (`_year-of`): a full or
// partial `Date` yields the four-digit year, while an unknown ("????") year or a
// missing `Date` tag yields `none` (-> names only). The display/override wiring is
// eyeballed in diagram/auto_captions (VISUAL_CHECKS).
//
// `_year-of` takes the raw TAGS dict, not a game — since 2.0.0 Phase D, the move
// record (`move-at`, see src/game.typ) deliberately does NOT carry `tags` (a
// roster belongs to the game, not a move), so `diagram` reads `source.tags`
// directly rather than through the move context.
#import "/lib.typ": game, _year-of

#let mk(tags) = game(tags + "\n1. e4 *").tags

// known from roster -> the year
#assert.eq(_year-of(mk("[White \"Morphy\"][Black \"Allies\"][Date \"1858.11.02\"]")), "1858", message: "full Date -> year")
#assert.eq(_year-of(mk("[Date \"1972.??.??\"]")), "1972", message: "partial Date (year known) -> year")

// not known from roster -> none (info line falls back to names only)
#assert.eq(_year-of(mk("[Date \"????.??.??\"]")), none, message: "unknown year (????) -> none")
#assert.eq(_year-of(mk("[White \"X\"][Black \"Y\"]")), none, message: "no Date tag -> none")

#set page(width: auto, height: auto, margin: 4mm)
`_year-of` roster extraction: all cases pass.
