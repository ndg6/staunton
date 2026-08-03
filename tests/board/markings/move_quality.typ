// Asserting test: MOVE-QUALITY BADGES, end to end.
//
// resolution.typ covers the derivation core with a few spot cases; this sheet is
// the systematic matrix behind it — every recognised symbol, from every input
// form, plus the precedence rule when a move carries two of them, the symbol →
// colour-category mapping, and the switch that gates the whole feature.
//
// What is asserted here vs eyeballed: the badge DATA and its routing are pure
// functions, so they belong in the suite. Whether the disc is actually drawn (and
// in which colour) cannot be queried out of a rendered board — see
// move_quality_render.typ + VISUAL_CHECKS for that half.
#import "/lib.typ": (
  game, position, with-nags, board, diagram, chess-kind,
  board-non-default-keys, board-style-keys,
  _apply-origin, _resolve-draw,
)
#import "/src/game.typ": move-quality-mark, move-at, _position-after
#import "/src/board.typ": _mq-category

#let SYMBOLS = ("!", "?", "!!", "??", "!?", "?!")
// PGN quality NAGs, in the same order: $1..$6.
#let NAG-OF = ("!": "$1", "?": "$2", "!!": "$3", "??": "$4", "!?": "$5", "?!": "$6")

// ---------------------------------------------------------------------------
// 1. All six symbols, from all three input forms, produce the SAME result.
//    A mark written as text, parsed from a PGN NAG, or set programmatically must
//    be indistinguishable downstream — that equivalence is the whole point.
// ---------------------------------------------------------------------------
#let head = "[White \"a\"][Black \"b\"] "

#for sym in SYMBOLS {
  // (a) a literal suffix glyph typed in the PGN text: "1. e4!!". Since the
  // D2 fix, `game`/`games` convert this to the equivalent quality NAG AT PARSE
  // TIME (src/pgn.typ's `_split-quality-suffix`/`_finalize-quality-nag`), so
  // by the time `move-quality-mark` runs there is no SAN suffix left to see --
  // it reads the NAG, exactly like case (b) below. This case exists to prove
  // that the end-to-end result (source text -> badge symbol) is unaffected by
  // where the conversion happens, not to exercise a separate SAN-suffix path.
  let lit = game(head + "1. e4" + sym + " e5 *")
  assert.eq(move-quality-mark(lit, "1w"), (square: "e4", symbol: sym),
    message: "literal suffix " + sym + " must yield that symbol on e4")

  // (b) PGN NAG in the movetext: "1. e4 $3"
  let nag = game(head + "1. e4 " + NAG-OF.at(sym) + " e5 *")
  assert.eq(move-quality-mark(nag, "1w"), (square: "e4", symbol: sym),
    message: NAG-OF.at(sym) + " must yield " + sym)

  // (c) programmatic, via with-nags
  let prog = with-nags(game(head + "1. e4 e5 *"), nags: ("1w": sym))
  assert.eq(move-quality-mark(prog, "1w"), (square: "e4", symbol: sym),
    message: "with-nags " + sym + " must yield that symbol")
}

// ---------------------------------------------------------------------------
// 2. Both at once: a move carrying a literal suffix AND an explicit NAG.
//    The explicit NAG wins and the suffix glyph is discarded (never doubled) --
//    this is now decided at PARSE time, by `_finalize-quality-nag` in
//    src/pgn.typ (the suffix-derived code is inserted only if no explicit
//    quality NAG is already present). `move-quality-mark` itself no longer has
//    a SAN-suffix fallback to choose between -- it just reads whichever NAG
//    survived parsing. Pinned here because the two can legitimately disagree
//    in real PGN files (a tool adds $2 to a move an author already wrote as
//    "!"), and silently picking the other one would relabel a blunder as
//    brilliant.
// ---------------------------------------------------------------------------
#let both = game(head + "1. e4! $2 e5 *")
#assert.eq(move-quality-mark(both, "1w"), (square: "e4", symbol: "?"),
  message: "NAG must win over a literal suffix when a move carries both")

// Agreeing sources are simply consistent.
#let agree = game(head + "1. e4! $1 e5 *")
#assert.eq(move-quality-mark(agree, "1w").symbol, "!")

// Several quality NAGs on one move: the FIRST wins ($3 = "!!" before $1 = "!").
#let gm = game(head + "1. e4 $3 $1 e5 *")
#assert.eq(move-quality-mark(gm, "1w").symbol, "!!")

// Absence, and the near-miss: a move with no annotation at all, and one carrying
// a NON-quality NAG ($14 = "⩲", a position evaluation). Neither is a badge —
// evaluating a position is not grading the move that reached it.
#assert.eq(move-quality-mark(game(head + "1. e4 e5 *"), "1w"), none)
#let ge = game(head + "1. e4 $14 e5 *")
#assert.eq(move-quality-mark(ge, "1w"), none,
  message: "a non-quality NAG must not produce a badge")

// ---------------------------------------------------------------------------
// 3. Symbol -> colour category. Three categories, six symbols, and the pairing
//    is what makes "!!" and "!" share a colour.
// ---------------------------------------------------------------------------
#assert.eq(_mq-category("!"), "good")
#assert.eq(_mq-category("!!"), "good")
#assert.eq(_mq-category("?"), "bad")
#assert.eq(_mq-category("??"), "bad")
#assert.eq(_mq-category("!?"), "interesting")
#assert.eq(_mq-category("?!"), "interesting")
// (That these three categories are real keys of `move-quality-colors`, and that
// the switch defaults to false, is options.typ's business — not repeated here.)

// ---------------------------------------------------------------------------
// 4. Both drawing entry points get the badge, by the same route.
//    Since Phase D the mark is reachable only via a game handed to `board`/
//    `diagram` with `at:` — a plain position (even from `_position-after`) has
//    no history to badge. `board` and `diagram` are fed identically -- `diagram`
//    adds only the figure wrapper. This is the assertion that would fail if the
//    badge ever became figure-only again.
// ---------------------------------------------------------------------------
#let g = game(head + "1. e4 e5 2. Nf3!! Nc6 *")
#assert.eq(move-at(g, at: "2w").quality, (square: "f3", symbol: "!!"),
  message: "the move carries the badge data")

// The fold that both entry points share inserts the style key the renderer reads.
#assert.eq(_apply-origin((:), move-at(g, at: "2w"), false).at("move-quality-mark"),
  (square: "f3", symbol: "!!"), message: "the badge reaches the renderer's override dict")

// A plain position (from `_position-after`) has no history to badge: fed
// through the same seam, it carries no `move-quality-mark`.
#assert(
  "move-quality-mark" not in _resolve-draw(_position-after(g, at: "2w"), none, (:), true).ov,
  message: "a plain position must not carry a badge",
)

// Both entry points accept a game + `at:`. The badge DRAWING is visual,
// but the structural difference between them is not: `diagram` must wrap its
// board in a locatable chess figure and `board` must not. Asserting it here is
// what stops move_quality_render.typ's side-by-side section from silently
// comparing `board` with `board` -- which is how that section was first written,
// with `caption: none, game-info: none` hiding every visible sign of the figure.
// Exactly one chess figure below proves both halves at once: if `board` also
// wrapped, this would be 2; if `diagram` stopped wrapping, 0.
#board(g, at: "2w", move-quality: true, size: 2cm)
#diagram(g, at: "2w", move-quality: true, size: 2cm)
#context assert.eq(query(figure.where(kind: chess-kind)).len(), 1,
  message: "diagram must wrap in a chess figure and board must not")

// A position with NO history carries nothing, so neither entry point can badge it.
#assert(
  "move-quality-mark" not in _resolve-draw(position("4k3/8/8/8/8/8/8/4K3 w - - 0 1"), none, (:), true).ov,
)

// ---------------------------------------------------------------------------
// 5. The `move-quality` switch is an ordinary style option; the MARK is not.
//    The switch is settable per call and document-wide (it is a plain board-style
//    key). The mark is position-specific and rejected as a document default —
//    that guard has its own expected-fail sheets.
// ---------------------------------------------------------------------------
#assert(board-style-keys.contains("move-quality"), message: "the switch is a board-style key")
#assert(not board-non-default-keys.contains("move-quality"),
  message: "the switch IS settable document-wide")
#assert(board-non-default-keys.contains("move-quality-mark"),
  message: "the mark is position-specific and must NOT be a document default")

#set page(width: auto, height: auto, margin: 4mm)
Move-quality badges: 6 symbols x 3 input forms, precedence, categories, routing.
