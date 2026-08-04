// Asserting test: 2.0.0 Phase B' -- Russian multi-cluster piece letters.
// Russian's king letter is "Кр" (TWO grapheme clusters); its knight is "К"
// (one cluster), a PREFIX of the king letter. The risk is a naive matcher
// reading "Кр"+square as the knight letter "К" plus a stray "р". Both
// directions are pinned in this one sheet: a Russian king move must
// normalize to an English "K.." SAN, and a Russian knight move (which does
// NOT start with the two-cluster king letter) must still normalize to "N..".
#import "/lib.typ": game, mainline

// Built via concatenation, not typed inline: Cyrillic "е" (U+0435) and Latin
// "e" are visually identical in an editor, so typing the square coordinates
// directly next to Cyrillic piece letters is an easy way to silently plant a
// Cyrillic letter into what must be an ASCII square name.
#let king-move = "Кр" + "e2"    // Russian king to e2
#let knight-move = "К" + "c6"   // Russian knight to c6
#let movetext = "1. e4 e5 2. " + king-move + " " + knight-move

#let g-ru = game(movetext, lang: "ru")
#assert(
  mainline(g-ru) == ("e4", "e5", "Ke2", "Nc6"),
  message: "ru multi-cluster: " + repr(mainline(g-ru)),
)

= Russian multi-cluster letters OK

"Кр" (king, two clusters) normalizes to "K", and "К" (knight, one cluster,
a prefix of the king letter) normalizes to "N" -- confirming the
longest-match-first rule in both directions.
