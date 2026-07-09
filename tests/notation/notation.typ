// chess-notation / notation: human-readable move notation from a
// game, a move-text string, or a SAN array. Figurines, language-aware piece
// letters (auto follows #set text(lang:)), from/to ranges, and NAG
// and comment rendering gated by the pgn-handling bucket.
#import "/lib.typ": parse-pgn, notation, chess-notation, set-pgn-defaults

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let g = parse-pgn("[White \"A\"][Black \"B\"][Result \"1-0\"]
1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O 1-0").first()

// String-returning fast path: lang AND nags/comments/diagrams must be explicit
// (their `auto`/auto-value defaults consult the document buckets -> content).
// Helper defaults them off / to English but lets a test override (e.g. nags: true,
// lang: "de"); the override wins.
#let s(src, ..a) = notation(src, ..((diagrams: false, bold-mainline: false, nags: false, comments: false, variations: false, lang: "en") + a.named()))

// --- English (default) ---
#assert(s(g) == "1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O", message: "en mainline")

// --- German letters: N->S, B->L (files/castling untouched) ---
#assert(s(g, lang: "de") == "1.e4 e5 2.Sf3 Sc6 3.Lb5 a6 4.La4 Sf6 5.O-O", message: "de letters")

// --- Russian (multi-char king "Кр", knight "К") localizes N/B, keeps files ---
#let ru = s(g, lang: "ru")
#assert(ru != s(g) and ru.contains("f3") and not ru.contains("Nf3"), message: "ru localizes piece letters, keeps coords")

// --- figurines: color-aware (White outline U+2658, Black solid U+265E) ---
#let fig = s(g, figurine: true)
#assert(fig.contains("\u{2658}"), message: "white knight figurine for White's move")
#assert(fig.contains("\u{265E}"), message: "black knight figurine for Black's move")
#assert(fig.contains("\u{2657}") and not fig.contains("N") and not fig.contains("B"), message: "white bishop figurine; no Latin piece letters")

// --- ranges (inclusive, diagram-after locators) ---
#assert(s(g, to: "2b") == "1.e4 e5 2.Nf3 Nc6", message: "start -> 2b")
#assert(s(g, from: "3w") == "3.Bb5 a6 4.Ba4 Nf6 5.O-O", message: "3w -> end")
#assert(s(g, from: "2b", to: "3b") == "2...Nc6 3.Bb5 a6", message: "Black-start slice numbers as 2...")
// boundary slices: single move, first only, last only, explicit full == default
#assert(s(g, from: "2w", to: "2w") == "2.Nf3", message: "single-move slice (one White ply)")
#assert(s(g, from: "2b", to: "2b") == "2...Nc6", message: "single-move slice (one Black ply)")
#assert(s(g, to: "1w") == "1.e4", message: "just the first move")
#assert(s(g, from: "5w") == "5.O-O", message: "just the last move")
#assert(s(g, from: "1w", to: "5w") == s(g), message: "explicit full range equals the default")

// --- result option appends a real result (never "*") ---
#assert(s(g, result: true) == "1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O 1-0", message: "with result")

// --- engine-free SAN sources: move-text string AND array ---
#assert(s("1. e4 e5 2. Nf3") == "1.e4 e5 2.Nf3", message: "string source")
#assert(s(("e4", "e5", "Nf3")) == "1.e4 e5 2.Nf3", message: "array source")
#assert(s("e4 e5", move-numbers: false) == "e4 e5", message: "move-numbers off")
#assert(s("d8=Q", lang: "de") == "1.d8=D", message: "promotion localized")

// --- NAGs and comments (opt-in) ---
#let gn = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 $1 e5 $6 2. Nf3 {develops the knight} Nc6 *").first()
// default off: plain movetext, no NAG glyphs, no prose
#assert(s(gn) == "1.e4 e5 2.Nf3 Nc6", message: "nags/comments off")
// nags on: $1 -> "!", $6 -> "?!"
#assert(s(gn, nags: true) == "1.e4! e5?! 2.Nf3 Nc6", message: "nags rendered")
// comments on: residual prose appended
#assert(s(gn, comments: true) == "1.e4 e5 2.Nf3 develops the knight Nc6", message: "comments rendered")
// SAN sources never carry nags/comments
#assert(s("e4 e5", nags: true, comments: true) == "1.e4 e5", message: "SAN source has no nags/comments")

= Notation output

English: #s(g) \
German: #s(g, lang: "de") \
Russian: #s(g, lang: "ru") \
Figurine: #s(g, figurine: true) \
NAGs: #notation(gn, nags: true, comments: false) \
NAGs + comments: #notation(gn, nags: true, comments: true)

#set text(lang: "de")
Auto (document lang = de): #notation(g, lang: "auto", nags: false, comments: false)

// document default via the pgn bucket: subsequent notation shows NAGs
#set-pgn-defaults(nags: true)
After `set-pgn-defaults(nags: true)`: #notation(gn, comments: false)
