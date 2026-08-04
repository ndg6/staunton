// Asserting test: LAST-MOVE marking (2.0.0 arrow rework, prompt 54). The
// `last-move`/`last-move-color` board-style keys auto-mark the move that
// produced a position drawn from a GAME via `at:`. `_apply-origin` (lib.typ) is
// the pure, context-free seam where the resolved move context turns into
// `arrows`/`highlight` entries -- rendered output is not queryable
// (`query(selector(rect))` errors on non-locatable elements), so everything
// here goes through `_apply-origin` and `_resolve-draw` (the one production
// seam that calls it -- see its header comment in lib.typ) directly, exactly
// as `pgn/move_record/move_record.typ` does for the badge/annotation fold.
#import "/lib.typ": game, position, apply, legal-moves, move-at, _apply-origin, _resolve-draw
#import "/src/game.typ": _position-after

#let g = game(```
[White "A"][Black "B"]
1. e4 e5 2. Nf3 Nc6 *
```)
#let mv = move-at(g, at: "2w")
#assert.eq((mv.from, mv.to), ("g1", "f3"), message: "fixture move must be Nf3 (g1-f3) for the assertions below to mean anything")

// ---- (1) no move behind the position -> last-move adds nothing -------------
// Enumerated by NAME, not by count: every one of these has `mv-context == none`
// under `_resolve-at-source`, so `last-move: "arrow"` must leave the resolved
// overlay dict completely unchanged. A suite that only checked a bare FEN would
// still pass if the "no move" branch were broken for every OTHER shape, so each
// shape gets its own case.
#let plain-fen = "4k3/8/8/8/8/8/8/4K3 w - - 0 1"
#let plain-pos = position(plain-fen)
#let applied = apply(plain-pos, legal-moves(plain-pos).first())
// Ply 0 (before any move) is a documented `move-at` case that returns `none`,
// not a panic (see `pgn/move_record/move_record.typ`). Verify that fixture fact
// again here, independently, before relying on it.
#let ply0-mv = move-at(g, at: "0b")
#assert.eq(ply0-mv, none, message: "ply 0 (before any move) must have no move behind it")

#let no-move-cases = (
  ("a bare FEN string", _resolve-draw(plain-fen, none, (:), true, last-move: "arrow").ov),
  ("a hand-built position", _resolve-draw(plain-pos, none, (:), true, last-move: "arrow").ov),
  ("an apply() result", _resolve-draw(applied, none, (:), true, last-move: "arrow").ov),
  // Ply 0 addressed directly through `_apply-origin` -- `move-at` itself
  // already returns `none` for ply 0, so this exercises exactly the branch a
  // ply-0 board would hit.
  ("ply 0, direct", _apply-origin((:), ply0-mv, true, last-move: "arrow")),
  // Ply 0 addressed through the REAL production seam: a real game, resolved at
  // its own ply-0 locator -- the closest reachable stand-in for "a game with no
  // move behind the position" (a game handed to `_resolve-draw` with `at: none`
  // is rejected upstream by `_resolve-at-source`'s own assert, so that spelling
  // is not a "degrades to none" case at all -- it is a distinct error path,
  // untouched by this change and not re-tested here).
  ("a game at its own ply-0 locator", _resolve-draw(g, "0b", (:), true, last-move: "arrow").ov),
)
#for (name, ov) in no-move-cases {
  assert.eq(ov, (:), message: name + ": last-move must add nothing when there is no move behind the position, got " + repr(ov))
}

// ---- (2) the paired positive case -------------------------------------------
// Without this half, every assertion in (1) would still pass even if
// `last-move` were entirely dead code -- this is what catches that.
#let pos-arrow = _resolve-draw(g, "2w", (:), true, last-move: "arrow").ov
#assert.eq(pos-arrow.at("arrows", default: none), ((from: mv.from, to: mv.to, color: auto),),
  message: "last-move: \"arrow\" must add exactly one arrow carrying the move's from/to, got " + repr(pos-arrow.at("arrows", default: none)))

// `last-move-color` is threaded straight through as the entry's `color:`.
#let pos-arrow-colored = _resolve-draw(g, "2w", (:), true, last-move: "arrow", last-move-color: red).ov
#assert.eq(pos-arrow-colored.arrows, ((from: mv.from, to: mv.to, color: red),),
  message: "last-move-color must be threaded through as the arrow's color")

// Caller-supplied arrows are never displaced -- last-move appends after them,
// same convention as the %cal fold.
#let pos-order = _resolve-draw(g, "2w", (arrows: (("a1", "a2", "G"),)), false, last-move: "arrow").ov
#assert.eq(pos-order.arrows, (("a1", "a2", "G"), (from: mv.from, to: mv.to, color: auto)),
  message: "last-move's arrow must append after caller-supplied arrows, never replace them")
// The same call also proves last-move is NOT gated by `annotations`/`process`
// (`process: false` above) -- a property of the move itself, like the quality
// badge, not of %cal/%csl comment processing.

// ---- (3) "squares" -> exactly two highlight entries, no `shape` key --------
// `shape` must be ABSENT (not `none`), not merely falsy -- that is what lets the
// document's `highlight-shape` default apply. Assert the absence explicitly.
#let pos-squares = _resolve-draw(g, "2w", (:), true, last-move: "squares").ov
#assert.eq(pos-squares.at("highlight", default: none), ((square: mv.from, color: auto), (square: mv.to, color: auto)),
  message: "last-move: \"squares\" must highlight exactly the from/to squares, got " + repr(pos-squares.at("highlight", default: none)))
#for entry in pos-squares.highlight {
  assert("shape" not in entry, message: "a last-move \"squares\" entry must not carry a `shape` key (found in " + repr(entry) + "), or the document's highlight-shape default is silently overridden")
}
// "squares" must not also add an arrow. `arrows` itself is present (empty) here
// because `process: true` always folds in the move's own %cal arrows, even when
// there are none -- what matters is the last-move contribution specifically.
#assert.eq(pos-squares.at("arrows", default: ()), (), message: "last-move: \"squares\" must not also add an arrow")

// ---- (4) last-move: none (the default) -> neither, even with a real move ---
// `process: false` here isolates last-move's own effect from the (unrelated)
// %cal/%csl fold, which inserts `arrows`/`highlight` keys (empty, since this
// game's moves carry no comments) whenever it runs at all.
#let pos-none = _resolve-draw(g, "2w", (:), false).ov
#assert("arrows" not in pos-none, message: "last-move: none (the default) must add no arrow, even though a real move is present")
#assert("highlight" not in pos-none, message: "last-move: none (the default) must add no highlight, even though a real move is present")

#set page(width: auto, height: auto, margin: 4mm)
Last-move marking: the no-move degrade cases, the paired positive case, the
"squares" form, and the off-by-default case all pass.
