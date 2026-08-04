// arrows. `arrows` is a board-style key; each entry is a dict
// (from:, to:, color:) or a tuple ("from","to") / ("from","to", color). A
// missing color uses the settable `arrow-color` default. Arrows flip with the
// board and scale with the square.
#import "/lib.typ": board, default-board-style, set-board-defaults, board-non-default-keys
#import "/tests/board/_fixture.typ": test-fen

#assert(default-board-style.keys().contains("arrows"), message: "arrows is a board key")
#assert(default-board-style.arrows == (), message: "no arrows by default")
// width settable (auto -> proportional), transparency 35% (thin lines stay
// clearly visible), and the default arrow color is the same base as the default
// highlight fill.
#assert(default-board-style.arrow-width == auto, message: "arrow-width auto by default")
#assert(default-board-style.arrow-transparency == 35%, message: "arrow transparency 35%")
#assert(default-board-style.arrow-color == default-board-style.highlight-fill, message: "arrow color defaults to the highlight base")

// ---- 2.0.0 arrow rework: the changed default + the new policy keys --------
// The default tip changed from the old triangle to a barbed "hook" -- the
// user-visible breaking change of this release. Name it explicitly so a silent
// revert is caught here, not just noticed on a rendered page.
#assert.eq(default-board-style.arrow-tip, "hook", message: "arrow-tip must default to \"hook\" (2.0.0 arrow rework)")
#assert.eq(default-board-style.arrow-fade, none, message: "arrow-fade must be off by default")
#assert.eq(default-board-style.last-move, none, message: "last-move must be off by default")
#assert.eq(default-board-style.last-move-color, auto, message: "last-move-color must default to auto")

// `arrow-tip`/`arrow-fade`/`last-move`/`last-move-color` are POLICY keys (board-
// wide, not position-specific), unlike `arrows`/`highlight`/`move-quality-mark`
// -- they must stay settable via `set-board-defaults`, not be rejected the way
// those three are.
#for k in ("arrow-tip", "arrow-fade", "last-move", "last-move-color") {
  assert(not board-non-default-keys.contains(k), message: k + " must remain settable via set-board-defaults, not be treated as position-specific")
}
#set-board-defaults(last-move: "arrow")
// Inert here (the boards below are drawn from a bare FEN, which has no move
// behind it -- see board/arrows/last_move.typ for the data-level proof), but
// confirms the call itself is accepted, not rejected as position-specific.
#set-board-defaults(last-move: none)

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Arrows

Tuple and dict forms, default and explicit colors:

#board(test-fen, size: 5cm, labels: false, arrows: (
  ("e2", "e4"),                                   // tuple, default color
  ("g1", "f3", rgb(0, 70, 160, 200)),             // tuple, explicit blue
  (from: "f1", to: "c4", color: rgb(136, 32, 32, 200)), // dict, red
))

#v(8pt)
Arrows follow a flip (same arrows, Black's view):

#grid(columns: 2, column-gutter: 16pt,
  board(test-fen, size: 4cm, labels: false, arrows: (("e2", "e4"), ("b8", "c6"))),
  board(test-fen, size: 4cm, labels: false, flip: true, arrows: (("e2", "e4"), ("b8", "c6"))),
)

#v(8pt)
Document-default arrow color via `set-board-defaults`:

#set-board-defaults(arrow-color: rgb(224, 110, 0, 220))
#board(test-fen, size: 4cm, labels: false, arrows: (("d2", "d4"), ("c1", "g5")))

#v(8pt)
Settable shaft width (`arrow-width`): auto (proportional) vs a fixed 8pt:

#grid(columns: 2, column-gutter: 16pt,
  board(test-fen, size: 4cm, labels: false, arrows: (("e2", "e4"), ("g1", "f3"))),
  board(test-fen, size: 4cm, labels: false, arrow-width: 8pt, arrows: (("e2", "e4"), ("g1", "f3"))),
)

#v(8pt)
Arrow tip (2.0.0): the default `"hook"` (barbed head) vs the old `"triangle"`,
board-wide via `arrow-tip`, and per-arrow via a dict entry's `tip:` (the third
arrow below overrides back to hook on an otherwise-triangle board):

#grid(columns: 3, column-gutter: 12pt,
  [`"hook"` (default)
  #board(test-fen, size: 4cm, labels: false, arrows: (("e2", "e4"), ("g1", "f3")))],
  [`arrow-tip: "triangle"`
  #board(test-fen, size: 4cm, labels: false, arrow-tip: "triangle", arrows: (("e2", "e4"), ("g1", "f3")))],
  [per-arrow `tip:` override
  #board(test-fen, size: 4cm, labels: false, arrow-tip: "triangle", arrows: (
    ("e2", "e4"),
    (from: "g1", to: "f3", tip: "hook"),
  ))],
)

#v(8pt)
Arrow fade (2.0.0): `arrow-fade` fades the shaft toward its TAIL, relative to
the head; board-wide and per-arrow (the third arrow overrides to a deeper fade
than the board default):

#grid(columns: 3, column-gutter: 12pt,
  [no fade (default)
  #board(test-fen, size: 4cm, labels: false, arrows: (("e2", "e4"), ("g1", "f3")))],
  [`arrow-fade: 20%`
  #board(test-fen, size: 4cm, labels: false, arrow-fade: 20%, arrows: (("e2", "e4"), ("g1", "f3")))],
  [per-arrow `fade:` override
  #board(test-fen, size: 4cm, labels: false, arrow-fade: 20%, arrows: (
    ("e2", "e4"),
    (from: "g1", to: "f3", fade: 60%),
  ))],
)
