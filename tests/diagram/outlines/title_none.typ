// `title: none` must truly drop the outline title: no title heading is emitted,
// so a caller can render its own title (or none). Previously `_outline-title`
// wrapped its result in an unconditional context and left an empty title heading
// behind. Asserting test — no rendering to eyeball.
#import "/lib.typ": diagram-outline, table-outline, diagram, starting-fen

#set page(width: 12cm, height: auto, margin: 1cm)

#diagram-outline(title: none)
#table-outline(title: none)
#diagram(starting-fen, size: 2cm, caption: [Listed])

#context {
  // The only heading-bearing element here is nothing: neither outline emitted a
  // title, and a diagram is a figure, not a heading.
  let heads = query(heading)
  assert(heads.len() == 0, message: "title: none must emit no title heading; got " + str(heads.len()))
}
