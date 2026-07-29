// RENDER-ONLY (not asserted): localized automatic captions + tournament-table
// column headers, so a human can eyeball the translations that Claude proposed
// but cannot verify (es / fr / it / pt / ru especially). The auto-caption and
// header WORDING is what to check here; the machine-checkable en/de strings live
// in i18n.typ.
#import "/lib.typ": (
  set-lang, diagram, diagram-after, standings-table,
  starting-fen, parse-pgn,
)

#set page(width: 15cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let game = parse-pgn(```
[White "Morphy"] [Black "Allies"] [Date "1858.11.02"]
1. e4 e5 2. Nf3 d6 3. d4 Bg4 *
```).first()

#let standings = parse-pgn(```
[White "Alice"][Black "Bob"][Result "1-0"][Round "1"] 1-0
[White "Cara"][Black "Dan"][Result "1/2-1/2"][Round "1"] 1/2-1/2
[White "Alice"][Black "Cara"][Result "1-0"][Round "2"] 1-0
[White "Bob"][Black "Dan"][Result "0-1"][Round "2"] 0-1
```)

= Localized captions & table headers

// Each language block: a FEN diagram (fen-caption), a diagram-after
// (pgn-caption), and a standings table (localized column headers).
#let showcase(code, label) = {
  set-lang(code)
  [== #label (`#code`)]
  grid(columns: (auto, auto), gutter: 1em,
    diagram(starting-fen, size: 3cm),
    diagram-after(game, "2w", size: 3cm),
  )
  standings-table(standings, caption: [Standings])
}

#showcase("en", "English")
#showcase("de", "German")
#showcase("fr", "French")
#showcase("es", "Spanish")
#showcase("it", "Italian")
#showcase("pt", "Portuguese")
#showcase("ru", "Russian")
