// A caption-less diagram stays referenceable but UNLISTED: its `outlined`
// flag (which drives diagram-outline membership) must default to whether it
// carries a caption, so bare positions don't leave blank rows in the outline. An
// explicit `outlined:` still wins. Asserting test — no rendering to eyeball.
#import "/lib.typ": diagram, starting-fen

#set page(width: 12cm, height: auto, margin: 1cm)

#diagram(starting-fen, size: 2cm, caption: [Listed])              // -> outlined
#diagram(starting-fen, size: 2cm)                                 // FEN auto-caption -> outlined
#diagram(starting-fen, size: 2cm, caption: none)                  // caption-less -> unlisted
#diagram(starting-fen, size: 2cm, caption: [Kept out], outlined: false)  // override -> unlisted

#context {
  let figs = query(figure.where(kind: "chess"))
  assert(figs.len() == 4, message: "expected 4 chess figures, got " + str(figs.len()))

  // The regression: every caption-less chess figure must be unlisted.
  let capless = figs.filter(f => f.caption == none)
  assert(capless.len() == 1, message: "expected 1 caption-less figure, got " + str(capless.len()))
  assert(capless.all(f => f.outlined == false), message: "a caption-less diagram must not be outlined")

  // Captioned diagrams are outlined by default; an explicit outlined:false wins.
  assert(figs.filter(f => f.outlined).len() == 2, message: "expected 2 outlined (both captioned, non-overridden), got " + str(figs.filter(f => f.outlined).len()))
}
