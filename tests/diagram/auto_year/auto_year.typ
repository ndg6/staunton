// Asserting test: automatic year from the PGN roster (the `Date` tag). A diagram
// prints " (<YEAR>)" after the players ONLY when the year is known from the
// roster; otherwise the info line is just the player names. `diagram-after`
// resolves the year with `year: auto` -> `_year-of(game)`, and a caller's
// explicit `year:` still overrides. Here we lock down the roster-extraction core
// (`_year-of`): a full or partial `Date` yields the four-digit year, while an
// unknown ("????") year or a missing `Date` tag yields `none` (-> names only).
// The display/override wiring is eyeballed in diagram/auto_captions (VISUAL_CHECKS).
#import "/lib.typ": parse-pgn, _year-of

#let mk(tags) = parse-pgn(tags + "\n1. e4 *").first()

// known from roster -> the year
#assert.eq(_year-of(mk("[White \"Morphy\"][Black \"Allies\"][Date \"1858.11.02\"]")), "1858", message: "full Date -> year")
#assert.eq(_year-of(mk("[Date \"1972.??.??\"]")), "1972", message: "partial Date (year known) -> year")

// not known from roster -> none (info line falls back to names only)
#assert.eq(_year-of(mk("[Date \"????.??.??\"]")), none, message: "unknown year (????) -> none")
#assert.eq(_year-of(mk("[White \"X\"][Black \"Y\"]")), none, message: "no Date tag -> none")

#set page(width: auto, height: auto, margin: 4mm)
`_year-of` roster extraction: all cases pass.
