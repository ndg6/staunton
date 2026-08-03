// Asserting test: prompt 53 Phase 3 — `into` defaults to 0 in `notation.typ:246`
// (`_resolve-variation-line`), reached via `notation(g, line: <hops>)`. `notation`
// returns CONTENT (default `bold-mainline: true`), so the two renders are
// compared structurally with `==` rather than string-matched, PLUS one concrete
// plain-string render (via the explicit-switches fast path) pins the actual value.
#import "/lib.typ": game, notation

#let g = game("[White \"V\"][Black \"T\"] 1. e4 (1. d4 d5 2. c4) e5 2. Nf3 *")

// content form: default bold-mainline -> content, compared structurally.
#let with-into = notation(g, line: ((at: "1w", into: 0),))
#let sans-into = notation(g, line: ((at: "1w"),))
#assert(with-into == sans-into, message: "omitting `into` on a `line:` hop renders identical content to `into: 0`")

// plain-string form: all switches explicit -> a str, so the concrete value is
// directly assertable.
#let s(..a) = notation(g, ..((diagrams: false, bold-mainline: false, spaced: true, nags: false, comments: false, lang: "en", variations: true) + a.named()))
#assert(s(line: ((at: "1w", into: 0),)) == "1. d4 d5 2. c4", message: "concrete: 1w's variation renders 1. d4 d5 2. c4")
#assert(s(line: ((at: "1w"),)) == s(line: ((at: "1w", into: 0),)), message: "plain-string form: `into` omitted matches `into: 0`")

Path-locator `into: 0` default (prompt 53 Phase 3), reached through `notation(g, line: ..)`: omitting `into` on a `line:` hop renders identical content (and identical plain-string output) to writing `into: 0` explicitly.
