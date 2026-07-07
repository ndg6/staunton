// Move-markings (prompt 27) settable options: the new board-style fields exist
// with the documented defaults, and both the document setter and per-call
// overrides accept them (unknown keys would error). Appearance is eyeballed in
// markings.typ; here we assert the option surface.
#import "/lib.typ": board, default-board-style, set-board-defaults

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

// defaults: both indicators OFF by default (prompt 27 requirement)
#assert.eq(default-board-style.check, false)
#assert.eq(default-board-style.move-quality, false)
#assert.eq(default-board-style.check-color, red)
#assert.eq(default-board-style.check-square, none)
#assert.eq(default-board-style.move-quality-mark, none)
// per-category backgrounds present and settable
#assert("good" in default-board-style.move-quality-colors)
#assert("bad" in default-board-style.move-quality-colors)
#assert("interesting" in default-board-style.move-quality-colors)

// the document-level setter accepts every new key (no "unknown board style option")
#set-board-defaults(
  check: true,
  check-color: blue,
  move-quality: true,
  move-quality-colors: (good: green, bad: maroon, interesting: olive),
)

// per-call overrides also accept them, and an explicit check-square is honoured
// (not overwritten by auto-detection). `move-quality-mark` is NOT accepted on a
// bare board (prompt 28: badges come from a game only — see malformed/); the
// `move-quality` switch alone is harmless (nothing to draw without a move).
#board(
  "4k3/8/8/8/8/8/8/4K3 w - - 0 1",
  check: true, check-square: "d4", check-color: purple,
  move-quality: true,
)

= move-markings options
