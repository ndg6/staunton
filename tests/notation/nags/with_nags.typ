// Programmatic NAGs: with-nags(game, map) attaches NAGs to MAINLINE moves so
// notation(.., nags: true) renders them without editing the PGN. Values may be
// the canonical "$n" form or one of the six suffix glyphs (sugar for $1..$6),
// or an array of them; the mapping REPLACES any NAGs already on the move and the
// source game is never mutated.
#import "/lib.typ": parse-pgn, with-nags, notation, movetext

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let g = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 *").first()
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
#let gp = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 $2 e5 *").first()
#assert(s(gp) == "1. e4? e5", message: "parsed $2 renders as ?")
#assert(s(with-nags(gp, ("1w": "!"))) == "1. e4! e5", message: "mapping replaces the parsed NAG")

// still gated by `nags:` -- with-nags only sets data, rendering decides
#assert(
  notation(g2, diagrams: false, bold-mainline: false, spaced: true, nags: false, comments: false, variations: false, lang: "en") == "1. e4 e5 2. Nf3 Nc6",
  message: "nags: false still suppresses",
)

// the source game is untouched (no mutation)
#assert(s(g) == "1. e4 e5 2. Nf3 Nc6", message: "original game not mutated")

// the move tree is otherwise intact (NAGs do not affect navigation)
#assert(movetext(g2).at(0).san == "e4" and movetext(g2).len() == 4, message: "nodes intact")

= Programmatic NAGs
#s(with-nags(g, ("1w": "!!", "2w": "$14")))
