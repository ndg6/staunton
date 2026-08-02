// Programmatic NAGs: with-nags(game, map) attaches NAGs to MAINLINE moves so
// notation(.., nags: true) renders them without editing the PGN. Values may be
// the canonical "$n" form or one of the six suffix glyphs (sugar for $1..$6),
// or an array of them; the mapping REPLACES any NAGs already on the move and the
// source game is never mutated.
#import "/lib.typ": game, with-nags, notation, movetext

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let g = game("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 *")
// string fast path: every option explicit (incl. diagrams) -> a plain string
#let s(src, ..a) = notation(src, ..((diagrams: false, bold-mainline: false, spaced: true, nags: true, comments: false, variations: false, lang: "en") + a.named()))

// glyph sugar: "!" -> $1 on 1. e4 ; "?!" -> $6 on 2... Nc6
#let g2 = with-nags(g, ("1w": "!", "2b": "?!"))
#assert(s(g2) == "1. e4! e5 2. Nf3 Nc6?!", message: "glyph sugar maps to $1/$6")

// canonical "$n" form, including a positional glyph ($14 -> "\u{2A72}")
#let g3 = with-nags(g, ("2w": "$14"))
#assert(s(g3) == "1. e4 e5 2. Nf3\u{2A72} Nc6", message: "$n form incl. positional glyph")

// an array value attaches several NAGs to one move
#let g4 = with-nags(g, ("1w": ("!", "$14")))
#assert(s(g4) == "1. e4!\u{2A72} e5 2. Nf3 Nc6", message: "array of NAGs on one move")

// REPLACE semantics: a NAG parsed from the PGN is overwritten by the mapping
#let gp = game("[White \"A\"][Black \"B\"] 1. e4 $2 e5 *")
#assert(s(gp) == "1. e4? e5", message: "parsed $2 renders as ?")
#assert(s(with-nags(gp, ("1w": "!"))) == "1. e4! e5", message: "mapping replaces the parsed NAG")

// still gated by `nags:` -- with-nags only sets data, rendering decides
// (this case covers the "$n" spelling, attached via with-nags -- $2 on 1w)
#assert(
  notation(g2, diagrams: false, bold-mainline: false, spaced: true, nags: false, comments: false, variations: false, lang: "en") == "1. e4 e5 2. Nf3 Nc6",
  message: "nags: false still suppresses",
)

// `nags:` must gate BOTH spellings (regression guard for the D2 fix): a move-
// quality suffix glyph parsed straight from PGN text ("!" on 1.e4, no with-nags
// involved) used to leak past `nags: false` because the old code kept the "!"
// glued onto `san` instead of routing it through the NAG machinery. Now the
// suffix is converted to a NAG at parse time, so `nags: false` suppresses it
// exactly like the "$n" spelling above.
#let common = (diagrams: false, bold-mainline: false, spaced: true, comments: false, variations: false, lang: "en")
#let gs = game("1. e4! e5 *")
#assert.eq(notation(gs, nags: true, ..common), "1. e4! e5", message: "suffix glyph renders when nags: true")
#assert.eq(notation(gs, nags: false, ..common), "1. e4 e5", message: "suffix glyph suppressed when nags: false (was leaking)")

// an explicit $n NAG alongside the suffix glyph must not double the mark either
// way (`nags: true` shows exactly one glyph, `nags: false` shows none)
#let gs2 = game("1. e4! $1 e5 *")
#assert.eq(notation(gs2, nags: true, ..common), "1. e4! e5", message: "suffix + explicit $1 must not double (was '1. e4!! e5')")
#assert.eq(notation(gs2, nags: false, ..common), "1. e4 e5", message: "suffix + explicit $1 both suppressed by nags: false")

// --- SOURCE PARITY: a bare SAN string and the equivalent parsed game must ---
// render IDENTICALLY. src/notation.typ's `_bare-node` normalises a string/array
// SAN source through the same `_split-quality-suffix` helper `game`/`games` use,
// specifically so "1. e4! e5" typed straight into `notation()` behaves like the
// same text run through a game. Assert the parity directly (string == game
// result), not two separate literals, so a future divergence between the two
// paths fails THIS assertion instead of silently passing two now-different
// "expected" strings.
#let san-str = "1. e4! e5"
#let san-game = game(san-str + " *")
#assert.eq(notation(san-str, nags: true, ..common), notation(san-game, nags: true, ..common),
  message: "string source and game source must render identically with nags: true")
#assert.eq(notation(san-str, nags: false, ..common), notation(san-game, nags: false, ..common),
  message: "string source and game source must render identically with nags: false")
// pin the actual values too, so a bug that changes BOTH sides identically (and
// would otherwise still satisfy the parity check above) is still caught
#assert.eq(notation(san-str, nags: true, ..common), "1. e4! e5")
#assert.eq(notation(san-str, nags: false, ..common), "1. e4 e5")

// the source game is untouched (no mutation)
#assert(s(g) == "1. e4 e5 2. Nf3 Nc6", message: "original game not mutated")

// the move tree is otherwise intact (NAGs do not affect navigation)
#assert(movetext(g2).at(0).san == "e4" and movetext(g2).len() == 4, message: "nodes intact")

= Programmatic NAGs
#s(with-nags(g, ("1w": "!!", "2w": "$14")))
