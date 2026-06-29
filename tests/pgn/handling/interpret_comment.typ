// the comment interpreter: split a PGN comment into a diagram
// marker (+caption), %cal arrows, %csl highlights, and residual prose.
#import "/src/annotations.typ": interpret-comment, nag-symbol

#set page(width: auto, height: auto, margin: 1cm)

// diagram markers (the ambiguous bare {d}/{D} are NOT recognised)
#assert(interpret-comment("#").diagram == (caption: none), message: "ChessBase #")
#assert(interpret-comment("#[My caption]").diagram == (caption: "My caption"), message: "ChessBase #[caption]")
#assert(interpret-comment("[d]").diagram == (caption: none), message: "Scid [d]")
#assert(interpret-comment("[D]").diagram == (caption: none), message: "Scid [D]")
#assert(interpret-comment("\diagram").diagram == (caption: none), message: "LaTeX \diagram")
#assert(interpret-comment("%%diagram").diagram == (caption: none), message: "Markdown %%diagram")
#assert(interpret-comment("d").diagram == none, message: "bare d NOT a diagram marker")
#assert(interpret-comment("D").diagram == none, message: "bare D NOT a diagram marker")
#assert(interpret-comment(none).diagram == none, message: "none comment")

// mixed comment: arrows + highlights + marker + prose all split out
#let r = interpret-comment("[%cal Gf3e5,Bf1c4] [%csl Re5] #[after Nf3] White is better")
#assert(r.arrows == (("f3", "e5", "G"), ("f1", "c4", "B")), message: "%cal arrows")
#assert(r.highlights == (("e5", "R"),), message: "%csl highlights")
#assert(r.diagram == (caption: "after Nf3"), message: "diagram marker + caption")
#assert(r.text == "White is better", message: "residual prose")

// NAG symbols
#assert(nag-symbol("1") == "!" and nag-symbol("5") == "!?" and nag-symbol("16") == "\u{00B1}", message: "nag map")
#assert(nag-symbol("999") == "$999", message: "unknown NAG passes through")

= Comment interpreter OK
