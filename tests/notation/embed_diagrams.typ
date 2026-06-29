// inline diagram embedding. When `diagrams` is on and the source
// is a game, `notation` / `chess-notation` flow the movetext and splice a
// chess-diagram after each move whose comment carries a diagram marker (ChessBase
// #/#[caption], Scid [d]/[D], \diagram, %%diagram), using that move's caption and
// (when annotations on) its %cal/%csl. Default off -> plain text, unchanged.
#import "/lib.typ": parse-pgn, notation, chess-notation, set-pgn-defaults

#set page(width: 14cm, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let g = parse-pgn(```
[White "A"] [Black "B"]
1. e4 e5 2. Nf3 {[%cal Gf1c4] #[After 2.Nf3]} Nc6 3. Bb5 {[d]} a6 4. Ba4 Nf6 *
```).first()

// diagrams OFF -> plain text string (no embedding), unchanged behaviour. lang is
// explicit so the string fast-path applies (lang: auto would consult the document
// and yield content).
#assert(
  notation(g, diagrams: false, nags: false, comments: false, lang: "en")
    == "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6",
  message: "diagrams off -> plain text",
)

// a non-game source never embeds, even with diagrams: true
#assert(
  notation("1. e4 e5", diagrams: true, nags: false, comments: false, lang: "en") == "1. e4 e5",
  message: "SAN source ignores diagrams",
)

// diagrams ON over a game -> content (text runs + spliced boards), not a string
#assert(type(notation(g, diagrams: true)) == content, message: "embedding yields content")

= Diagrams off (plain text)
#chess-notation(g, nags: false, comments: false)

= Diagrams on (per call) — boards spliced at the markers, with annotations
#chess-notation(g, diagrams: true, annotations: true)

// document default via the bucket
#set-pgn-defaults(diagrams: true, annotations: true)
= Diagrams on (document default via set-pgn-defaults)
#chess-notation(g)
