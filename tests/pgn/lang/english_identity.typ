// Asserting test: 2.0.0 Phase B' -- English is an exact identity, and
// `movetext-raw` stays byte-verbatim regardless of `lang:` (normalisation
// happens only in the parsed tree, never to the stored source text).
#import "/lib.typ": game, mainline

// English mainline, unchanged by the new lang machinery.
#let en-src = "1. e4 e5 2. Nf3 *"
#let g-en = game(en-src, lang: "en")
#assert(mainline(g-en) == ("e4", "e5", "Nf3"), message: "en mainline identity: " + repr(mainline(g-en)))
#assert(g-en.movetext-raw == en-src, message: "en movetext-raw must be byte-verbatim")

// Same check with the default (no explicit lang: argument at all).
#let g-en-default = game(en-src)
#assert(mainline(g-en-default) == ("e4", "e5", "Nf3"), message: "default-lang mainline identity")
#assert(g-en-default.movetext-raw == en-src, message: "default-lang movetext-raw must be byte-verbatim")

// A localized game's movetext-raw stays verbatim in the SOURCE language too --
// only the parsed tree (`mainline`/`movetext`) is normalized, never the raw
// text the game carries.
#let de-src = "1. e4 e5 2. Sf3 Sc6"
#let g-de = game(de-src, lang: "de")
#assert(g-de.movetext-raw == de-src, message: "de movetext-raw must stay verbatim (not normalized)")

= English identity + verbatim movetext-raw OK

`mainline` on an English game is unchanged; `movetext-raw` is byte-identical
to the input for both an English and a German game -- normalisation happens
only when the tree is built, not to the stored source text.
