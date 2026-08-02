// Asserting test: 2.0.0 Phase B' -- per-language piece-letter normalisation.
// `mainline(game(..))` must always come back in canonical English SAN,
// regardless of which supported language wrote the input movetext.
#import "/lib.typ": game, mainline

// German (K D T L S): the Ruy Lopez opening moves.
#let g-de = game("1. e4 e5 2. Sf3 Sc6 3. Lb5 a6", lang: "de")
#assert(
  mainline(g-de) == ("e4", "e5", "Nf3", "Nc6", "Bb5", "a6"),
  message: "de normalisation: " + repr(mainline(g-de)),
)

// French (R D T F C): the same opening shape, French letters (knight C,
// bishop F).
#let g-fr = game("1. e4 e5 2. Cf3 Cc6 3. Fb5 a6", lang: "fr")
#assert(
  mainline(g-fr) == ("e4", "e5", "Nf3", "Nc6", "Bb5", "a6"),
  message: "fr normalisation: " + repr(mainline(g-fr)),
)

= per-language normalisation OK

`mainline` returns identical canonical English SAN for the same opening
written in German and in French piece letters.
