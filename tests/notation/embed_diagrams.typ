// inline diagram embedding. When `diagrams` is on and the source
// is a game, `notation` / `chess-notation` flow the movetext and splice a
// chess-diagram after each move whose comment carries a diagram marker (ChessBase
// #/#[caption], Scid [d]/[D], \diagram, %%diagram), using that move's caption and
// (when annotations on) its %cal/%csl. Default off -> plain text, unchanged.
#import "/lib.typ": parse-pgn, notation, chess-notation, set-pgn-defaults, movetext
#import "/src/annotations.typ": interpret-comment  // internal helper, tested directly

#set page(width: 14cm, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let g = parse-pgn(```
[White "A"] [Black "B"]
1. e4 e5 2. Nf3 {[%cal Gf1c4] #[After 2. Nf3]} Nc6 3. Bb5 {[d]} a6 4. Ba4 Nf6 *
```).first()

// diagrams OFF -> plain text string (no embedding), unchanged behaviour. lang is
// explicit so the string fast-path applies (lang: auto would consult the document
// and yield content).
#assert(
  notation(g, diagrams: false, bold-mainline: false, spaced: true, nags: false, comments: false, variations: false, lang: "en")
    == "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6",
  message: "diagrams off -> plain text",
)

// a non-game source never embeds, even with diagrams: true
#assert(
  notation("1. e4 e5", diagrams: true, nags: false, comments: false, variations: false, bold-mainline: false, spaced: true, lang: "en") == "1. e4 e5",
  message: "SAN source ignores diagrams",
)

// diagrams ON over a game -> content (text runs + spliced boards), not a string
#assert(type(notation(g, diagrams: true)) == content, message: "embedding yields content")

// --- annotations on a marker-bearing move feed the spliced board ------------
// One comment can carry BOTH a diagram marker AND %cal/%csl; `notation` runs a
// single `interpret-comment` per move and (when `annotations` is on) hands the
// extracted arrows/highlights to the spliced `chess-diagram`. We assert the data
// SOURCE here; the wiring + gating are shown by the annotated sheet below.
// (Content equality can't see it: a `diagrams: true` result is a `context`
// closure whose equality ignores the captured `annotations` value -- so
// annotations on/off compare EQUAL even though they render differently.)
#let ga = parse-pgn(```
[White "A"] [Black "B"]
1. e4 e5 2. Nf3 {[%cal Gf1c4] [%csl Re5] #[After 2. Nf3]} Nc6 *
```).first()
#let info = interpret-comment(movetext(ga).at(2).at("comment-after"))
#assert(info.diagram != none, message: "Nf3 comment carries a diagram marker")
#assert(info.diagram.caption == "After 2. Nf3", message: "marker caption parsed")
#assert(info.arrows == (("f1", "c4", "G"),), message: "%cal extracted for the spliced board")
#assert(info.highlights == (("e5", "R"),), message: "%csl extracted for the spliced board")

= Diagrams off (plain text)
#chess-notation(g, nags: false, comments: false)

= Diagrams on (per call) — boards spliced at the markers, with annotations
#chess-notation(g, diagrams: true, annotations: true)

// marker + %cal + %csl on one move: the spliced board should show BOTH the arrow
// and the highlight (visual proof of the diagrams + annotations interaction).
= Marker + %cal + %csl on one move (annotations on)
#chess-notation(ga, diagrams: true, annotations: true)

// document default via the bucket
#set-pgn-defaults(diagrams: true, annotations: true)
= Diagrams on (document default via set-pgn-defaults)
#chess-notation(g)
