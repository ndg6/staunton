// §2.3 Labeling - all three modes, each at a few file-side / rank-side positions
// so the labels move to the requested edges. (The on-square -> border auto
// fallback at tiny sizes is covered separately in onsquare_fallback.typ.)
#import "/lib.typ": board
#import "/tests/board/_fixture.typ": test-fen

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

#let sides = (
  ("bottom/right", (file-side: bottom, rank-side: right)),
  ("top/right",    (file-side: top,    rank-side: right)),
  ("bottom/left",  (file-side: bottom, rank-side: left)),
  ("top/left",     (file-side: top,    rank-side: left)),
)

#let mode-row(mode) = {
  [== label-mode: #mode]
  grid(
    columns: sides.len(),
    column-gutter: 10pt,
    ..sides.map(((name, ov)) => stack(dir: ttb, spacing: 5pt,
      align(center, emph(name)),
      board(test-fen, size: 3.6cm, label-mode: mode, ..ov))),
  )
}

= Label modes x label positions

#mode-row("on-square")
#mode-row("outside")
#mode-row("border")
