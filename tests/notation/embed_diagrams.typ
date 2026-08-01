// inline diagram embedding. When `diagrams` is on and the source
// is a game, `notation` flows the movetext and splices a
// diagram after each move whose comment carries a diagram marker (ChessBase
// #/#[caption], Scid [d]/[D], \diagram, %%diagram), using that move's caption and
// (when annotations on) its %cal/%csl. Default off -> plain text, unchanged.
#import "/lib.typ": parse-pgn, notation, set-pgn-defaults, set-board-defaults, movetext
#import "/src/annotations.typ": interpret-comment  // internal helper, tested directly
#import "/src/game.typ": _origin-of                 // provenance builder, tested directly

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
// One comment can carry BOTH a diagram marker AND %cal/%csl. `notation` still
// runs `interpret-comment` per move to spot the DIAGRAM MARKER, but since prompt
// 49 it no longer extracts the arrows/highlights itself: the spliced board is an
// ordinary `diagram` over a `position-after` position, which carries that move's
// annotations (and its quality badge) in its own provenance. Deriving them here
// as well would DOUBLE them -- the merge is asserted directly in
// tests/pgn/provenance.
// We assert the data SOURCE here; the wiring + gating are shown by the annotated
// sheet below. (Content equality can't see it: a `diagrams: true` result is a
// `context` closure whose equality ignores the captured `annotations` value -- so
// annotations on/off compare EQUAL even though they render differently.)
#let ga = parse-pgn(```
[White "A"] [Black "B"]
1. e4 e5 2. Nf3! {[%cal Gf1c4] [%csl Re5] #[After 2. Nf3]} Nc6 *
```).first()
#let info = interpret-comment(movetext(ga).at(2).at("comment-after"))
#assert(info.diagram != none, message: "Nf3 comment carries a diagram marker")
#assert(info.diagram.caption == "After 2. Nf3", message: "marker caption parsed")
#assert(info.arrows == (("f1", "c4", "G"),), message: "%cal extracted for the spliced board")
#assert(info.highlights == (("e5", "R"),), message: "%csl extracted for the spliced board")

// The badge reaches a spliced board the same way the annotations do: through the
// position's provenance, not through anything `notation` derives. Assert the DATA
// here -- whether the disc is actually drawn is a visual check, and is gated by
// the `move-quality` style switch (default OFF), which is why the sheet below has
// to turn it on before a badge can appear at all.
#assert.eq(_origin-of(ga, "2w").quality, (square: "f3", symbol: "!"),
  message: "the marker-bearing move carries a quality mark for the spliced board")

= Diagrams off (plain text)
#notation(g, nags: false, comments: false)

= Diagrams on (per call) — boards spliced at the markers, with annotations
#notation(g, diagrams: true, annotations: true)

// marker + %cal + %csl on one move: the spliced board should show BOTH the arrow
// and the highlight (visual proof of the diagrams + annotations interaction).
= Marker + %cal + %csl on one move (annotations on)
#notation(ga, diagrams: true, annotations: true)

// document default via the bucket
#set-pgn-defaults(diagrams: true, annotations: true)
= Diagrams on (document default via set-pgn-defaults)
#notation(g)

// Move-quality badge on a spliced board. Two things must both be true: the move
// carries a quality mark (`2. Nf3!` above) AND `move-quality` is enabled -- it
// defaults to OFF and `notation` does not turn it on, so an embedded diagram is
// badge-free unless the document asks for badges. Set LAST so the sections above
// keep rendering without one.
#set-board-defaults(move-quality: true)
= Marker + quality mark, `move-quality` on — the spliced board wears a `!` badge
#notation(ga, diagrams: true, annotations: true)
