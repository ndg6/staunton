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
  parse-pgn, with-nags, board, diagram, position-after,
  default-board-style, board-non-default-keys, board-style-keys,
  _origin-in, _apply-origin,
)
#import "/src/game.typ": move-quality-mark, _origin-of
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
  // (a) literal suffix on the SAN: "1. e4!!"
  let lit = parse-pgn(head + "1. e4" + sym + " e5 *").first()
  assert.eq(move-quality-mark(lit, "1w"), (square: "e4", symbol: sym),
    message: "literal suffix " + sym + " must yield that symbol on e4")

  // (b) PGN NAG in the movetext: "1. e4 $3"
  let nag = parse-pgn(head + "1. e4 " + NAG-OF.at(sym) + " e5 *").first()
  assert.eq(move-quality-mark(nag, "1w"), (square: "e4", symbol: sym),
    message: NAG-OF.at(sym) + " must yield " + sym)

  // (c) programmatic, via with-nags
  let prog = with-nags(parse-pgn(head + "1. e4 e5 *").first(), ("1w": sym))
  assert.eq(move-quality-mark(prog, "1w"), (square: "e4", symbol: sym),
    message: "with-nags " + sym + " must yield that symbol")
}

// ---------------------------------------------------------------------------
// 2. Both at once: a move carrying a literal suffix AND a NAG.
//    The NAG wins — `move-quality-mark` scans NAGs first and only falls back to
//    the SAN suffix when none is a quality NAG. Pinned here because the two can
//    legitimately disagree in real PGN files (a tool adds $2 to a move an author
//    already wrote as "!"), and silently picking the other one would relabel a
//    blunder as brilliant.
// ---------------------------------------------------------------------------
#let both = parse-pgn(head + "1. e4! $2 e5 *").first()
#assert.eq(move-quality-mark(both, "1w"), (square: "e4", symbol: "?"),
  message: "NAG must win over a literal suffix when a move carries both")

// Agreeing sources are simply consistent.
#let agree = parse-pgn(head + "1. e4! $1 e5 *").first()
#assert.eq(move-quality-mark(agree, "1w").symbol, "!")

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
// every category named above is a real key of the default colour map
#for sym in SYMBOLS {
  assert(_mq-category(sym) in default-board-style.move-quality-colors,
    message: "category for " + sym + " must exist in move-quality-colors")
}

// ---------------------------------------------------------------------------
// 4. Both drawing entry points get the badge, by the same route.
//    Since prompt 49 the mark rides on the POSITION's provenance, so `board` and
//    `diagram` are fed identically — `diagram` adds only the figure wrapper. This
//    is the assertion that would fail if the badge ever became figure-only again.
// ---------------------------------------------------------------------------
#let g = parse-pgn(head + "1. e4 e5 2. Nf3!! Nc6 *").first()
#let pos = position-after(g, "2w")
#assert.eq(_origin-in(pos).quality, (square: "f3", symbol: "!!"),
  message: "a game-derived position carries the badge data")

// The fold that both entry points share inserts the style key the renderer reads.
#assert.eq(_apply-origin((:), _origin-of(g, "2w"), false).at("move-quality-mark"),
  (square: "f3", symbol: "!!"), message: "the badge reaches the renderer's override dict")

// Neither call errors on a provenanced position (the drawing itself is visual).
#let _b = board(pos, move-quality: true, size: 2cm)
#let _d = diagram(pos, move-quality: true, size: 2cm)

// A position with NO history carries nothing, so neither entry point can badge it.
#import "/src/fen.typ": parse-fen
#assert.eq(_origin-in(parse-fen("4k3/8/8/8/8/8/8/4K3 w - - 0 1")), none)

// ---------------------------------------------------------------------------
// 5. The `move-quality` switch is an ordinary style option; the MARK is not.
//    The switch is settable per call and document-wide (it is a plain board-style
//    key). The mark is position-specific and rejected as a document default —
//    that guard has its own expected-fail sheets.
// ---------------------------------------------------------------------------
#assert.eq(default-board-style.move-quality, false, message: "badges are opt-in")
#assert(board-style-keys.contains("move-quality"), message: "the switch is a board-style key")
#assert(not board-non-default-keys.contains("move-quality"),
  message: "the switch IS settable document-wide")
#assert(board-non-default-keys.contains("move-quality-mark"),
  message: "the mark is position-specific and must NOT be a document default")

#set page(width: auto, height: auto, margin: 4mm)
Move-quality badges: 6 symbols x 3 input forms, precedence, categories, routing.
