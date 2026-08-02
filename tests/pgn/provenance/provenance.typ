// Asserting test: POSITION PROVENANCE (prompt 49). A position returned by
// `position-after` remembers the move it came from, which is what lets a plain
// `board(position-after(g, l))` draw that move's %cal/%csl annotations and its
// move-quality badge — and what makes "this really came from a game move" a
// property of the VALUE rather than of which function the caller used.
//
// Everything here is asserted through PURE helpers on purpose. The rendered board
// is not queryable (`query(selector(rect))` errors on non-locatable elements), and
// a `diagrams: true` notation result is a context closure whose equality ignores
// captured values — so `_origin-of` / `_origin-in` / `_apply-origin` are the only
// seams where this behaviour is machine-checkable. The visible result is eyeballed
// via board/markings and notation/embed_diagrams (VISUAL_CHECKS).
#import "/lib.typ": game, position, with-nags, apply, legal-moves, diagram, _origin-in, _apply-origin
#import "/src/game.typ": position-after, _position-at, _origin-of

#let g = game(```
[White "Morphy"] [Black "Allies"] [Date "1858.11.02"]
1. e4 e5 2. Nf3! {[%cal Gf3e5,Bf1c4] [%csl Re5]} Nc6 3. Bb5?? a6 *
```)

// ---- _origin-of: the derived payload ---------------------------------------
#let o = _origin-of(g, "2w")
#assert.eq(o.locator, "2w")
// D2 (2.0.0 Phase A): the quality suffix glyph is now stripped from `san` at
// parse time and converted to a NAG, so `san` is the plain move and the grade
// is reachable via `quality` below (and `nags`, movetext(g).at(4).nags).
#assert.eq(o.san, "Nf3")
#assert.eq(o.arrows, (("f3", "e5", "G"), ("f1", "c4", "B")))
#assert.eq(o.highlights, (("e5", "R"),))
#assert.eq(o.tags.at("White"), "Morphy")

// The payload stays FLAT and small — it must NOT embed the game, or `repr(pos)`
// would explode into the whole movetext tree and wreck assert messages, panics
// and the line-based `// EXPECT:` fixtures in run.sh.
#assert.eq(o.keys().sorted(), ("arrows", "highlights", "locator", "quality", "san", "tags"))
#assert(not repr(o).contains("movetext"), message: "provenance must not carry the game")

// ---- quality rides in the payload -----------------------------------------
// One case each way is enough HERE: this sheet is about the payload's shape and
// routing, not about badge derivation. The full matrix (six symbols, three input
// forms, NAG-vs-literal precedence) belongs to board/markings/move_quality.typ.
#assert.eq(o.quality, (square: "f3", symbol: "!"))          // populated
#assert.eq(_origin-of(g, "1w").quality, none)               // absent when unmarked

// ---- who carries provenance, and who must not ------------------------------
#assert("_origin" in position-after(g, "2w"), message: "position-after attaches it")
#assert("_origin" not in _position-at(g, "2w"), message: "the internal lookup stays plain")
#assert("_origin" not in position("4k3/8/8/8/8/8/8/4K3 w - - 0 1"), message: "a FEN has no history")

// `apply` rebuilds the position dict from a literal, so provenance does not ride
// along — a position the user advanced themselves has no move to badge. This is
// load-bearing, not incidental: it is what stops a badge leaking onto a later
// position that never had a quality mark.
#let p = position-after(g, "2w")
#assert("_origin" not in apply(p, legal-moves(p).first()), message: "apply drops provenance")

// Ply 0 addresses the position BEFORE any move — in range, but with no move
// behind it. It must come back plain, not blow up in `move-node`.
#assert("_origin" not in position-after(g, "0b"), message: "ply 0 has no move to remember")
#assert.eq(position-after(g, "0b").turn, "w", message: "ply 0 is still the start position")

// ---- _origin-in: forged/partial provenance degrades, never panics ----------
#assert.eq(_origin-in("4k3/8/8/8/8/8/8/4K3 w - - 0 1"), none, message: "a string has none")
#assert.eq(_origin-in((squares: (:), _origin: "nonsense")), none, message: "non-dict rejected")
#assert.eq(_origin-in((squares: (:), _origin: (quality: (square: "e4", symbol: "!")))), none,
  message: "a partial origin must not badge")
#assert(_origin-in(p) != none, message: "a real one is accepted")

// The guard must cover every key a CONSUMER reads, not just the ones the merge
// reads: `diagram` takes `tags` and the caption takes `locator`/`san`. A dict
// that satisfies only the merge used to slip through and then die on a missing
// key downstream — so drop one key at a time and require each to be rejected.
#let full = _origin-of(g, "2w")
#for k in full.keys() {
  let partial = (:)
  for (kk, vv) in full { if kk != k { partial.insert(kk, vv) } }
  assert.eq(_origin-in((squares: (:), _origin: partial)), none,
    message: "origin missing `" + k + "` must be rejected")
}

// ---- _apply-origin: the merge, which the rendered board cannot show --------
#let caller = (arrows: (("a1", "a2", "G"),), highlight: (("h8", "Y"),))

// annotations ON: caller's first, the move's appended. Both survive; neither is
// dropped and neither is duplicated.
#let on = _apply-origin(caller, o, true)
#assert.eq(on.arrows, (("a1", "a2", "G"), ("f3", "e5", "G"), ("f1", "c4", "B")))
#assert.eq(on.highlight, (("h8", "Y"), ("e5", "R")))

// annotations OFF: the move's comment data is withheld, the caller's is not.
#let off = _apply-origin(caller, o, false)
#assert.eq(off.arrows, caller.arrows)
#assert.eq(off.highlight, caller.highlight)

// The badge is NOT gated by `annotations` — that switch governs %cal/%csl comment
// processing, while a quality mark is a property of the move itself.
#assert.eq(on.at("move-quality-mark"), (square: "f3", symbol: "!"))
#assert.eq(off.at("move-quality-mark"), (square: "f3", symbol: "!"))
#assert("move-quality-mark" not in _apply-origin(caller, _origin-of(g, "1w"), true),
  message: "no mark on the move -> no key inserted")

// Drawn from a bare override dict, the move's data appears exactly ONCE. This is
// the regression guard for `notation`'s embedded diagrams, which used to derive
// the same annotations locally AND pass them in — provenance now being the single
// source means a second derivation would show up here as doubled arrows.
#assert.eq(_apply-origin((:), o, true).arrows, o.arrows)
#assert.eq(_apply-origin((:), o, true).highlight, o.highlights)

// No provenance -> the overrides are returned untouched.
#assert.eq(_apply-origin(caller, none, true), caller)

#set page(width: auto, height: auto, margin: 4mm)
`position-after` provenance: derivation, gating and merge all pass.

// End-to-end proof that a forged origin degrades instead of crashing. Asserting
// on `_origin-in` alone is NOT enough: the keys `diagram` reads (`tags`, and
// `locator`/`san` for the caption) are read OUTSIDE the merge, so a dict that
// satisfied only the merge used to pass the guard and then die downstream on a
// missing key. This must render a plain board — nothing here needs eyeballing.
#let forged = position("4k3/8/8/8/8/8/8/4K3 w - - 0 1")
#let forged = { let f = forged; f.insert("_origin", (arrows: (), highlights: (), quality: none)); f }
#diagram(forged, size: 2cm)
