// Labeling - all three modes, each at a few file-side / rank-side positions
// so the labels move to the requested edges. On-square labels keep a fixed font
// fraction at every size (no automatic switch to "border").
#import "/lib.typ": board, default-board-style, set-board-defaults
#import "/tests/board/_fixture.typ": test-fen

// `label-font` is a settable board-style option. The default leads with Arial
// (Windows & macOS) and falls back to Typst's embedded "DejaVu Sans Mono", so a
// stock install draws labels without "unknown font family" warnings.
#assert("label-font" in default-board-style, message: "label-font is a board-style option")
#assert(default-board-style.label-font == ("Arial", "DejaVu Sans Mono"), message: "default label-font fallback list")

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
