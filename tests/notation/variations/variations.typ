// Variation move-text output: notation(.., variations: true) splices RAVs into
// the mainline in parentheses, correctly numbered and side-aware -- a white-first
// variation is "N. ...", a black-first one "N... ...", and the resumed mainline
// move re-shows its number (a Black move as "N..."). Nesting recurses.
#import "/lib.typ": parse-pgn, notation, chess-notation, set-pgn-defaults, default-pgn-style, pgn-style-state

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

// All options explicit -> the plain-string fast path (assertable).
#let s(src, ..a) = notation(src, ..((diagrams: false, bold-mainline: false, nags: false, comments: false, lang: "en", variations: true) + a.named()))

// --- default OFF is byte-identical to the mainline (regression) -------------
#let g1 = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4 Bc5) a6 *").first()
#assert(
  notation(g1, diagrams: false, bold-mainline: false, nags: false, comments: false, variations: false, lang: "en")
    == "1.e4 e5 2.Nf3 Nc6 3.Bb5 a6",
  message: "variations off -> mainline only, unchanged",
)

// --- white-first variation: "3. Bc4 ...", resumed black move re-numbered ----
#assert(
  s(g1) == "1.e4 e5 2.Nf3 Nc6 3.Bb5 (3.Bc4 Bc5) 3...a6",
  message: "white-first variation + resumed 3... a6",
)

// --- black-first variation: "2... d6 3. d4 ..." -----------------------------
#let g2 = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 (2... d6 3. d4 exd4) 3. Bb5 *").first()
#assert(
  s(g2) == "1.e4 e5 2.Nf3 Nc6 (2...d6 3.d4 exd4) 3.Bb5",
  message: "black-first variation numbered 2... / 3.",
)

// --- nested variation (a RAV inside a RAV) ----------------------------------
#let g3 = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 (1. d4 d5 (1... Nf6 2. c4)) e5 *").first()
#assert(
  s(g3) == "1.e4 (1.d4 d5 (1...Nf6 2.c4)) 1...e5",
  message: "nested variation + resumed 1... e5",
)

// --- two variations at the same move ----------------------------------------
#let g4 = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 (1. d4) (1. c4) e5 *").first()
#assert(s(g4) == "1.e4 (1.d4) (1.c4) 1...e5", message: "two RAVs at one move")

// --- variations honour figurine + lang inside the parens --------------------
#assert(
  s(g2, lang: "de") == "1.e4 e5 2.Sf3 Sc6 (2...d6 3.d4 exd4) 3.Lb5",
  message: "German piece letters apply inside variations",
)

// --- NAGs / comments render inside variations when on ------------------------
#let g5 = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 (1. d4 $1 {solid} d5) e5 *").first()
#assert(
  notation(g5, diagrams: false, bold-mainline: false, nags: true, comments: true, variations: true, lang: "en")
    == "1.e4 (1.d4! solid d5) 1...e5",
  message: "NAGs + comments inside a variation",
)

// --- line: address one specific variation, correctly offset-numbered --------
#let gw = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4 Bc5 4. c3) a6 *").first()
#assert(s(gw, line: ((at: "3w", into: 0),)) == "3.Bc4 Bc5 4.c3", message: "line: white-first variation (hops)")
#assert(s(gw, line: (line: ((at: "3w", into: 0),), at: "3w")) == "3.Bc4 Bc5 4.c3", message: "line: dict form (at ignored)")
#let gbk = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 (2... d6 3. d4 exd4) 3. Bb5 *").first()
#assert(s(gbk, line: ((at: "2b", into: 0),)) == "2...d6 3.d4 exd4", message: "line: black-first variation")
#assert(s(g3, line: ((at: "1w", into: 0), (at: "1b", into: 0))) == "1...Nf6 2.c4", message: "line: nested variation")
// the addressed sub-line's OWN nested variations follow the `variations` flag:
#assert(s(g3, line: ((at: "1w", into: 0),)) == "1.d4 d5 (1...Nf6 2.c4)", message: "line: outer, nested spliced (variations on)")
#assert(
  notation(g3, line: ((at: "1w", into: 0),), variations: false, bold-mainline: false, lang: "en", nags: false, comments: false)
    == "1.d4 d5",
  message: "line: outer, nested suppressed (variations off)",
)

// --- bold-mainline: mainline moves rendered strong -> content ----------------
#assert(type(s(g1)) == str, message: "bold-mainline off -> plain string")
#assert(type(s(g1, bold-mainline: true)) == content, message: "bold-mainline on -> content (strong mainline)")
// bold-mainline defaults ON: a bare call (default resolves through set-pgn-defaults)
// therefore yields content, not a plain string.
#assert(default-pgn-style.bold-mainline == true, message: "bold-mainline defaults on")
#assert(type(chess-notation(g1, lang: "en")) == content, message: "default bold-mainline -> content")

// --- document-wide switch via set-pgn-defaults ------------------------------
// A call relying on the document default resolves through `context` (so returns
// content, not a string); assert the switch is set, and eyeball the render below.
#set-pgn-defaults(variations: true)
#context assert((default-pgn-style + pgn-style-state.get()).variations, message: "set-pgn-defaults(variations: true) sets the switch")

= Variations — inline and block
// with the document default now on, a bare call splices variations:
#chess-notation(g1)

#chess-notation(g3, variations: true, variation-style: "block")
