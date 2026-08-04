// Asserting test: THE MOVE RECORD (`move-at`, 2.0.0 Phase D/E). A move's derived
// data — its SAN/nags/comments/variations (the movetext half) AND its resolved
// from/to/piece/color/capture/kind/promotion (the engine half), plus what's
// derived from those (quality badge, %cal/%csl arrows/highlights) — is now
// reachable as ONE flat record, `move-at(game, at: locator)`, replacing the old
// split between a movetext node (SAN, no squares) and an engine move (squares,
// no annotations). `_move-context` (the old private builder) is gone; `move-at`
// is its public replacement and closes that split — see git history for the
// pre-Phase-E shape if it is ever needed for reference.
//
// `tags` is deliberately NOT part of the record — a roster belongs to the game,
// not to a move; a caller that needs it reads `game.tags` directly.
//
// Positions are uniform: `_position-after(g, L)` returns an ORDINARY position,
// indistinguishable from one built any other way, and NO position ever carries
// the old `_origin` payload — that is still the whole point of this release.
//
// Everything here is asserted through PURE helpers on purpose. The rendered board
// is not queryable (`query(selector(rect))` errors on non-locatable elements), and
// a `diagrams: true` notation result is a context closure whose equality ignores
// captured values — so `move-at` / `_apply-origin` / `_resolve-draw` are the
// only seams where this behaviour is machine-checkable. The visible result is
// eyeballed via board/markings and notation/embed_diagrams (VISUAL_CHECKS).
#import "/lib.typ": (
  game, position, play, game-start, with-nags, apply, legal-moves, diagram,
  _apply-origin, _resolve-draw, move-at,
)
// `move-node` is the INTERNAL tree accessor (dropped from the public API in
// 2.0.0 -- `move-at` is the one public way to ask about a move). This sheet
// still reaches for it deliberately, to cross-check that `move-at`'s node
// half agrees with the tree it is built from.
#import "/src/game.typ": _position-after, move-node
#import "/src/san.typ": san-to-move

#let g = game(```
[White "Morphy"] [Black "Allies"] [Date "1858.11.02"]
1. e4 e5 2. Nf3! {[%cal Gf3e5,Bf1c4] [%csl Re5]} Nc6 3. Bb5?? a6 *
```)

// ---- move-at: the derived payload -------------------------------------------
#let mv = move-at(g, at: "2w")
#assert.eq(mv.locator, "2w")
// D2 (2.0.0 Phase A): the quality suffix glyph is now stripped from `san` at
// parse time and converted to a NAG, so `san` is the plain move and the grade
// is reachable via `quality` below (and `nags`, movetext(g).at(4).nags).
#assert.eq(mv.san, "Nf3")
#assert.eq(mv.arrows, (("f3", "e5", "G"), ("f1", "c4", "B")))
#assert.eq(mv.highlights, (("e5", "R"),))
// `tags` is NOT on the record -- read the roster from the game itself.
#assert.eq(g.tags.at("White"), "Morphy")

// (a) The record's exact key set, pinned by NAME: a field silently appearing or
// vanishing (e.g. a partial revert restoring the old small `_move-context` shape,
// or dropping the new engine half) fails here immediately. Both halves plus the
// derived trio are present; `tags` stays off it as documented above.
#assert.eq(mv.keys().sorted(), (
  "arrows", "capture", "color", "comment-after", "comment-before", "from",
  "highlights", "kind", "locator", "nags", "piece", "promotion", "quality",
  "san", "to", "variations",
), message: "move-at's key set: got " + repr(mv.keys().sorted()))
#assert(not repr(mv).contains("movetext"), message: "the move record must not carry the game")

// ---- (b) the two halves genuinely meet --------------------------------------
// This is the point of the whole change: `move-at` is not just gluing two
// derivations side by side, it must report the SAME thing each derivation would
// report on its own.
//
// NODE half: san/nags/comment-after/variations must match `move-node` directly.
#let node = move-node(g, at: "2w")
#assert.eq(mv.san, node.san, message: "move-at's san must match move-node's")
#assert.eq(mv.nags, node.at("nags", default: ()), message: "move-at's nags must match move-node's")
#assert.eq(mv.comment-after, node.at("comment-after", default: none),
  message: "move-at's comment-after must match move-node's")
#assert.eq(mv.variations, node.at("variations", default: ()),
  message: "move-at's variations must match move-node's")

// ENGINE half: from/to/piece/capture/kind/promotion must match what the engine
// itself resolves for the same SAN against the position just before the move --
// independently, via `san-to-move`, not through `move-at`'s own machinery.
#let before-2w = _position-after(g, at: "1b")
#let engine-mv = san-to-move(before-2w, mv.san)
#assert.eq(mv.from, engine-mv.from, message: "move-at's from must match the engine's")
#assert.eq(mv.to, engine-mv.to, message: "move-at's to must match the engine's")
#assert.eq(mv.piece, engine-mv.piece, message: "move-at's piece must match the engine's")
#assert.eq(mv.color, engine-mv.color, message: "move-at's color must match the engine's")
#assert.eq(mv.capture, engine-mv.capture, message: "move-at's capture must match the engine's")
#assert.eq(mv.kind, engine-mv.kind, message: "move-at's kind must match the engine's")
#assert.eq(mv.promotion, engine-mv.promotion, message: "move-at's promotion must match the engine's")

// ---- quality rides in the payload -----------------------------------------
// One case each way is enough HERE: this sheet is about the payload's shape and
// routing, not about badge derivation. The full matrix (six symbols, three input
// forms, NAG-vs-literal precedence) belongs to board/markings/move_quality.typ.
#assert.eq(mv.quality, (square: "f3", symbol: "!"))          // populated
#assert.eq(move-at(g, at: "1w").quality, none)                // absent when unmarked

// ---- (c) move kinds resolve correctly through move-at -----------------------
// Each line is a real, verified-legal line (checked with `legal-moves`/by
// compiling before writing the assertion down), not one recalled from memory.

// Capture: exd5, kind "normal", capture is the captured kind.
#let g-cap = game("1. e4 d5 2. exd5 *")
#let mv-cap = move-at(g-cap, at: "2w")
#assert.eq(mv-cap.kind, "normal", message: "a plain capture keeps kind \"normal\"")
#assert.eq(mv-cap.capture, "pawn", message: "capture names the captured piece's kind")
#assert.eq((mv-cap.from, mv-cap.to), ("e4", "d5"))

// Castling: kingside, from/to are the KING's squares, kind "castle-k".
#let g-castle = game("1. e4 e5 2. Nf3 Nc6 3. Bc4 Bc5 4. O-O *")
#let mv-castle = move-at(g-castle, at: "4w")
#assert.eq(mv-castle.kind, "castle-k")
#assert.eq((mv-castle.from, mv-castle.to), ("e1", "g1"),
  message: "castling's from/to are the KING's squares, not the rook's")

// En passant: kind "en-passant", capture is "pawn".
#let g-ep = game("1. e4 Nf6 2. e5 d5 3. exd6 *")
#let mv-ep = move-at(g-ep, at: "3w")
#assert.eq(mv-ep.kind, "en-passant")
#assert.eq(mv-ep.capture, "pawn")
#assert.eq((mv-ep.from, mv-ep.to), ("e5", "d6"))

// Promotion: `promotion` is the promoted-to kind. Built from a custom FEN start
// (`[SetUp "1"]`) rather than a long realistic mainline, since only the last
// move matters here.
#let g-promo = game("[FEN \"8/4P3/8/8/8/8/8/4K2k w - - 0 1\"] [SetUp \"1\"]\n1. e8=Q *")
#let mv-promo = move-at(g-promo, at: "1w")
#assert.eq(mv-promo.kind, "promotion")
#assert.eq(mv-promo.promotion, "queen")
#assert.eq((mv-promo.from, mv-promo.to), ("e7", "e8"))

// ---- (d) a variation-path locator works --------------------------------------
#let g-var = game("1. e4 e5 (1... c5 2. Nf3) 2. Nf3 *")
#let vloc = (line: ((at: "1b", into: 0),), at: "2w")
#let mv-var = move-at(g-var, at: vloc)
#assert.eq(mv-var.san, "Nf3", message: "variation-path locator resolves the right move")
#assert.eq((mv-var.from, mv-var.to), ("g1", "f3"))
#assert.eq(mv-var.locator, vloc, message: "the record carries the ORIGINAL locator, path form included")

// ---- (e) ply 0 is a legal thing to address, not a panic ---------------------
// "0b" is ply 0 -- the position before any move -- valid per `_ply-of`/
// `_position-after`'s own range check (`target >= 0`). There is no move behind
// it, so `move-at` returns `none` rather than erroring.
#assert.eq(move-at(g, at: "0b"), none, message: "ply 0 (before any move) must yield none, not panic")
#assert.eq(_position-after(g, at: "0b"), game-start(g),
  message: "ply 0's position is the game's own start")

// ---- (f) E1: legal-moves/apply speak square-name STRINGS, not (col,row) -----
// Pins the representation so a partial revert to the old tuple shape cannot
// silently pass: `from`/`to` are strings, and a specific known value confirms
// they are square NAMES ("e2"), not some other stringified shape.
#let start-pos = _position-after(g, at: "0b")
#let first-legal = legal-moves(start-pos).first()
#assert.eq(str(type(first-legal.from)), "string", message: "legal-moves' `from` must be a string")
#assert.eq(str(type(first-legal.to)), "string", message: "legal-moves' `to` must be a string")
#assert(first-legal.from.len() == 2 and first-legal.from.at(0) in "abcdefgh",
  message: "`from` must be a square NAME like \"e2\", got " + repr(first-legal.from))
// `apply` accepts that exact shape (a dict with string from/to), unaltered.
#assert(apply(start-pos, first-legal) != none, message: "apply must accept legal-moves' move shape directly")

// ---- positions are uniform: no history rides on the value ------------------
// A game-derived position must be an ORDINARY position — indistinguishable from
// one reached by a different route. Any extra field riding on the value
// (provenance, or the `apply` leak fixed in Phase A) breaks this while leaving
// the squares identical, which is exactly how both of those defects hid.
//
// The independent route is `play` from the game's own start, NOT a FEN
// round-trip: `to-fen` is deliberately lossy about en passant (strict X-FEN —
// it records the target square only when a capture is actually available,
// src/fen.typ), so `position(to-fen(p)) != p` for any position sitting on a
// live-but-uncapturable e.p. square, such as the one right after `1. e4`.
// Do not "fix" this by asserting a FEN round-trip here.
#let sans = ("1. e4", "1. e4 e5", "1. e4 e5 2. Nf3", "1. e4 e5 2. Nf3 Nc6", "1. e4 e5 2. Nf3 Nc6 3. Bb5")
#for (i, loc) in ("1w", "1b", "2w", "2b", "3w").enumerate() {
  let p = _position-after(g, at: loc)
  assert.eq(p, play(game-start(g), moves: sans.at(i)),
    message: "game-derived position differs from the replayed one at " + loc + ": " + repr(p.keys()))
  assert.eq(p.keys().sorted(),
    ("castling", "cols", "en-passant", "fullmove", "halfmove", "rows", "squares", "turn", "variant"),
    message: "unexpected keys on a game-derived position at " + loc)
}

// No position — from a game, a FEN, or `apply` — ever carries `_origin`: the
// mechanism that used to attach it is gone.
#assert("_origin" not in _position-after(g, at: "2w"), message: "_position-after carries no history")
#assert("_origin" not in position("4k3/8/8/8/8/8/8/4K3 w - - 0 1"), message: "a FEN has no history")
#let p = _position-after(g, at: "2w")
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
#assert("move-quality-mark" not in _apply-origin(caller, move-at(g, at: "1w"), true),
  message: "no mark on the move -> no key inserted")

// Drawn from a bare override dict, the move's data appears exactly ONCE. This is
// the regression guard for `notation`'s embedded diagrams, which used to derive
// the same annotations locally AND pass them in — the move record now being the
// single source means a second derivation would show up here as doubled arrows.
#assert.eq(_apply-origin((:), mv, true).arrows, mv.arrows)
#assert.eq(_apply-origin((:), mv, true).highlight, mv.highlights)

// No move record -> the overrides are returned untouched.
#assert.eq(_apply-origin(caller, none, true), caller)

// ---- _resolve-draw: the ONE seam the production drawing path uses ---------
// `_resolve-draw(source, at, ov, process)` resolves `source`/`at` AND folds the
// move record into `ov` in a single atomic call — it is what `_board-internal`
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
// `_position-after` position with `at: none`, must derive NONE of the three keys.
// This is the behaviour change of the whole release: a plain position no longer
// draws a badge or its move's annotations. A suite that only asserted (a) would
// still pass even if the game path were wired to nothing — this is what catches
// that. It cannot pass by accident: `_resolve-draw` with `at: none` takes the
// `else` branch of `_resolve-at-source`, which returns `mv-context: none`, and
// `_apply-origin` returns `ov` completely untouched when `mv-context` is `none` —
// so this assertion is exercising exactly the code path Phase D introduced.
#let pos-b = _resolve-draw(_position-after(g, at: "2w"), none, (:), true)
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
Move record: shape, node/engine agreement, kinds, variations, ply 0, the string
representation, derivation, gating, merge and `_resolve-draw` all pass.

// End-to-end proof that a plain position, even one hand-built with a forged
// `_origin`-shaped key, renders a plain board — nothing here needs eyeballing.
// This is not a regression guard for a REAL forgery path (there is none left:
// no position field feeds the renderer's badge/annotation lookup any more), just
// a sanity check that stray dict keys on a position are inert.
#let forged = position("4k3/8/8/8/8/8/8/4K3 w - - 0 1")
#let forged = { let f = forged; f.insert("_origin", (arrows: (), highlights: (), quality: none)); f }
#diagram(forged, size: 2cm)
