// Asserting test: GAME STRUCTURE CONTRACT (2.0.0 Phase A step 5, updated for
// Phase B' localized input). A `game` dict has no dedicated constructor
// function to document its shape, so this pins it directly: a freshly parsed
// game is exactly (tags, movetext-raw, result, lang), and a game touched by
// ANY builder is that PLUS `movetext-nodes` (the precomputed tree the builder
// installs via the shared `_stash` helper so its edit sticks without
// re-parsing the raw text). All three builders (`with-nags`, `with-comments`,
// `with-variation`) route through `_stash`, so all three are checked here
// rather than just one.
//
// `lang` is ALWAYS present (defaulting to `"en"`) rather than sometimes-3-
// sometimes-4, so the key set stays stable regardless of whether the caller
// passed `lang:` explicitly.
#import "/lib.typ": game, with-nags, with-comments, with-variation

#let g = game("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 *")
#assert.eq(g.keys().sorted(), ("lang", "movetext-raw", "result", "tags"), message: "a parsed game must have exactly these keys")
#assert.eq(g.lang, "en", message: "lang defaults to \"en\" when not passed")

#let g-de = game("[White \"A\"][Black \"B\"] 1. e4 e5 2. Sf3 Sc6 *", lang: "de")
#assert.eq(g-de.keys().sorted(), ("lang", "movetext-raw", "result", "tags"), message: "an explicit lang: does not change the key set")
#assert.eq(g-de.lang, "de", message: "lang reflects an explicit lang: argument")

#let expected-builder-keys = ("lang", "movetext-nodes", "movetext-raw", "result", "tags")

#let g-nags = with-nags(g, nags: ("1w": "!"))
#assert.eq(g-nags.keys().sorted(), expected-builder-keys,
  message: "with-nags: a builder-touched game adds exactly `movetext-nodes`, nothing else")

#let g-comments = with-comments(g, comments: ("1w": "a note"))
#assert.eq(g-comments.keys().sorted(), expected-builder-keys,
  message: "with-comments: a builder-touched game adds exactly `movetext-nodes`, nothing else")

#let g-variation = with-variation(g, at: "1w", moves: "d4")
#assert.eq(g-variation.keys().sorted(), expected-builder-keys,
  message: "with-variation: a builder-touched game adds exactly `movetext-nodes`, nothing else")

Game structure contract: a parsed game is `(tags, movetext-raw, result, lang)`, with `lang` always present (defaulting to `"en"`); each of the three builders (`with-nags`, `with-comments`, `with-variation`) adds exactly `movetext-nodes`.
