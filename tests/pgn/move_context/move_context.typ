// Asserting test: MOVE CONTEXT (Phase D of the 2.0.0 provenance rework). A move's
// derived data — its %cal/%csl annotations, its move-quality badge, its SAN,
// locator and the game's roster tags — is now reachable ONLY by handing the
// GAME itself (never a bare position) to `board`/`diagram` together with `at:`.
// Positions are uniform: `position-after(g, L)` and `_position-at(g, L)` return
// the exact same value for every locator, and NO position ever carries the old
// `_origin` payload — that is the whole point of this release. The mechanism
// this sheet replaces (a position that "remembers" its move) is gone by design;
// see git history for `tests/pgn/provenance/provenance.typ` if the old shape is
// ever needed for reference.
//
// Everything here is asserted through PURE helpers on purpose. The rendered board
// is not queryable (`query(selector(rect))` errors on non-locatable elements), and
// a `diagrams: true` notation result is a context closure whose equality ignores
// captured values — so `_move-context` / `_apply-origin` / `_resolve-draw` are the
// only seams where this behaviour is machine-checkable. The visible result is
// eyeballed via board/markings and notation/embed_diagrams (VISUAL_CHECKS).
#import "/lib.typ": game, position, with-nags, apply, legal-moves, diagram, _apply-origin, _resolve-draw
#import "/src/game.typ": position-after, _position-at, _move-context

#let g = game(```
[White "Morphy"] [Black "Allies"] [Date "1858.11.02"]
1. e4 e5 2. Nf3! {[%cal Gf3e5,Bf1c4] [%csl Re5]} Nc6 3. Bb5?? a6 *
```)

// ---- _move-context: the derived payload ------------------------------------
#let mv = _move-context(g, "2w")
#assert.eq(mv.locator, "2w")
// D2 (2.0.0 Phase A): the quality suffix glyph is now stripped from `san` at
// parse time and converted to a NAG, so `san` is the plain move and the grade
// is reachable via `quality` below (and `nags`, movetext(g).at(4).nags).
#assert.eq(mv.san, "Nf3")
#assert.eq(mv.arrows, (("f3", "e5", "G"), ("f1", "c4", "B")))
#assert.eq(mv.highlights, (("e5", "R"),))
#assert.eq(mv.tags.at("White"), "Morphy")

// The payload stays FLAT and small — it must NOT embed the game, or `repr(mv)`
// would explode into the whole movetext tree and wreck assert messages, panics
// and the line-based `// EXPECT:` fixtures in run.sh.
#assert.eq(mv.keys().sorted(), ("arrows", "highlights", "locator", "quality", "san", "tags"))
#assert(not repr(mv).contains("movetext"), message: "move context must not carry the game")

// ---- quality rides in the payload -----------------------------------------
// One case each way is enough HERE: this sheet is about the payload's shape and
// routing, not about badge derivation. The full matrix (six symbols, three input
// forms, NAG-vs-literal precedence) belongs to board/markings/move_quality.typ.
#assert.eq(mv.quality, (square: "f3", symbol: "!"))          // populated
#assert.eq(_move-context(g, "1w").quality, none)             // absent when unmarked

// ---- positions are uniform: no history rides on the value ------------------
// `position-after` and the internal lookup must return IDENTICAL values for
// every locator — that uniformity is the whole point of this release. If either
// function still special-cased provenance onto its result, this would fail.
#for loc in ("0b", "1w", "1b", "2w", "2b", "3w", "3b") {
  assert.eq(position-after(g, loc), _position-at(g, loc),
    message: "position-after and _position-at must agree at " + loc)
}

// No position — from a game, a FEN, or `apply` — ever carries `_origin`: the
// mechanism that used to attach it is gone.
#assert("_origin" not in position-after(g, "2w"), message: "position-after carries no history")
#assert("_origin" not in position("4k3/8/8/8/8/8/8/4K3 w - - 0 1"), message: "a FEN has no history")
#let p = position-after(g, "2w")
#assert("_origin" not in apply(p, legal-moves(p).first()), message: "apply never attaches history")

// ---- _apply-origin: the merge, which the rendered board cannot show --------
#let caller = (arrows: (("a1", "a2", "G"),), highlight: (("h8", "Y"),))

// annotations ON: caller's first, the move's appended. Both survive; neither is
// dropped and neither is duplicated.
#let on = _apply-origin(caller, mv, true)
#assert.eq(on.arrows, (("a1", "a2", "G"), ("f3", "e5", "G"), ("f1", "c4", "B")))
#assert.eq(on.highlight, (("h8", "Y"), ("e5", "R")))

// annotations OFF: the move's comment data is withheld, the caller's is not.
#let off = _apply-origin(caller, mv, false)
#assert.eq(off.arrows, caller.arrows)
#assert.eq(off.highlight, caller.highlight)

// The badge is NOT gated by `annotations` — that switch governs %cal/%csl comment
// processing, while a quality mark is a property of the move itself.
#assert.eq(on.at("move-quality-mark"), (square: "f3", symbol: "!"))
#assert.eq(off.at("move-quality-mark"), (square: "f3", symbol: "!"))
#assert("move-quality-mark" not in _apply-origin(caller, _move-context(g, "1w"), true),
  message: "no mark on the move -> no key inserted")

// Drawn from a bare override dict, the move's data appears exactly ONCE. This is
// the regression guard for `notation`'s embedded diagrams, which used to derive
// the same annotations locally AND pass them in — the move context now being the
// single source means a second derivation would show up here as doubled arrows.
#assert.eq(_apply-origin((:), mv, true).arrows, mv.arrows)
#assert.eq(_apply-origin((:), mv, true).highlight, mv.highlights)

// No move context -> the overrides are returned untouched.
#assert.eq(_apply-origin(caller, none, true), caller)

// ---- _resolve-draw: the ONE seam the production drawing path uses ---------
// `_resolve-draw(source, at, ov, process)` resolves `source`/`at` AND folds the
// move context into `ov` in a single atomic call — it is what `_board-internal`
// (and therefore `board`/`diagram`) actually calls, so asserting against it is
// asserting the real path, not a parallel helper that could silently disagree
// with production. A game with BOTH a quality glyph and a %cal/%csl comment
// (`g` above) exercises badge and annotations at once.

// (a) POSITIVE: a game handed in with `at:` yields all three derived keys.
#let pos-a = _resolve-draw(g, "2w", (:), true)
#assert("move-quality-mark" in pos-a.ov, message: "game + at: must derive the badge")
#assert("arrows" in pos-a.ov, message: "game + at: must derive %cal arrows")
#assert("highlight" in pos-a.ov, message: "game + at: must derive %csl highlight")
#assert.eq(pos-a.ov.at("move-quality-mark"), (square: "f3", symbol: "!"))
#assert.eq(pos-a.ov.arrows, (("f3", "e5", "G"), ("f1", "c4", "B")))
#assert.eq(pos-a.ov.highlight, (("e5", "R"),))

// (b) NEGATIVE — the most important one: the SAME move, addressed as a plain
// `position-after` position with `at: none`, must derive NONE of the three keys.
// This is the behaviour change of the whole release: a plain position no longer
// draws a badge or its move's annotations. A suite that only asserted (a) would
// still pass even if the game path were wired to nothing — this is what catches
// that. It cannot pass by accident: `_resolve-draw` with `at: none` takes the
// `else` branch of `_resolve-at-source`, which returns `mv-context: none`, and
// `_apply-origin` returns `ov` completely untouched when `mv-context` is `none` —
// so this assertion is exercising exactly the code path Phase D introduced.
#let pos-b = _resolve-draw(position-after(g, "2w"), none, (:), true)
#assert("move-quality-mark" not in pos-b.ov, message: "a plain position must not carry a badge")
#assert("arrows" not in pos-b.ov, message: "a plain position must not carry derived arrows")
#assert("highlight" not in pos-b.ov, message: "a plain position must not carry a derived highlight")

// (c) The `annotations` gate governs %cal/%csl ONLY — the badge still comes
// through even with `process: false`.
#let pos-c = _resolve-draw(g, "2w", (:), false)
#assert("move-quality-mark" in pos-c.ov, message: "the badge is not gated by `annotations`")
#assert("arrows" not in pos-c.ov, message: "`annotations: false` withholds %cal arrows")
#assert("highlight" not in pos-c.ov, message: "`annotations: false` withholds %csl highlight")

// (d) Ordering preserved: caller-supplied arrows come FIRST, derived ones appended.
#let pos-d = _resolve-draw(g, "2w", (arrows: (("a1", "a2", "G"),)), true)
#assert.eq(pos-d.ov.arrows, (("a1", "a2", "G"), ("f3", "e5", "G"), ("f1", "c4", "B")),
  message: "caller arrows must precede derived arrows, never the reverse")

#set page(width: auto, height: auto, margin: 4mm)
Move context: derivation, gating, merge, positional uniformity and `_resolve-draw` all pass.

// End-to-end proof that a plain position, even one hand-built with a forged
// `_origin`-shaped key, renders a plain board — nothing here needs eyeballing.
// This is not a regression guard for a REAL forgery path (there is none left:
// no position field feeds the renderer's badge/annotation lookup any more), just
// a sanity check that stray dict keys on a position are inert.
#let forged = position("4k3/8/8/8/8/8/8/4K3 w - - 0 1")
#let forged = { let f = forged; f.insert("_origin", (arrows: (), highlights: (), quality: none)); f }
#diagram(forged, size: 2cm)
