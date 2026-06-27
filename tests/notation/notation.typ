// §prompt 14 - chess-notation / notation: human-readable move notation from a
// game, a move-text string, or a SAN array. Figurines, language-aware piece
// letters (auto follows #set text(lang:)), and from/to mainline ranges.
#import "/lib.typ": parse-pgn, notation, chess-notation

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let g = parse-pgn("[White \"A\"][Black \"B\"][Result \"1-0\"]
1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O 1-0").first()

// --- English (default) ---
#assert(chess-notation(g) == "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O", message: "en mainline")

// --- German letters: N->S, B->L (files/castling untouched) ---
#assert(notation(g, lang: "de") == "1. e4 e5 2. Sf3 Sc6 3. Lb5 a6 4. La4 Sf6 5. O-O", message: "de letters")

// --- Russian (multi-char king "Кр", knight "К") localizes N/B, keeps files ---
#let ru = notation(g, lang: "ru")
#assert(ru != notation(g) and ru.contains("f3") and not ru.contains("Nf3"), message: "ru localizes piece letters, keeps coords")

// --- figurines: colour-aware. White's Nf3 -> outline knight U+2658, Black's
// Nc6 -> solid knight U+265E; no Latin piece letters remain. ---
#let fig = notation(g, figurine: true)
#assert(fig.contains("\u{2658}"), message: "white knight figurine (outline) for White's move")
#assert(fig.contains("\u{265E}"), message: "black knight figurine (solid) for Black's move")
#assert(fig.contains("\u{2657}") and not fig.contains("N") and not fig.contains("B"), message: "white bishop figurine; no Latin piece letters")

// --- ranges (inclusive, board-after locators) ---
#assert(notation(g, to: "2b") == "1. e4 e5 2. Nf3 Nc6", message: "start -> 2b")
#assert(notation(g, from: "3w") == "3. Bb5 a6 4. Ba4 Nf6 5. O-O", message: "3w -> end")
#assert(notation(g, from: "2b", to: "3b") == "2... Nc6 3. Bb5 a6", message: "Black-start slice numbers as 2...")

// --- result option appends a real result (but never "*") ---
#assert(notation(g, result: true) == "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 4. Ba4 Nf6 5. O-O 1-0", message: "with result")

// --- engine-free SAN sources: move-text string AND array, same output ---
#assert(notation("1. e4 e5 2. Nf3") == "1. e4 e5 2. Nf3", message: "string source")
#assert(notation(("e4", "e5", "Nf3")) == "1. e4 e5 2. Nf3", message: "array source")
#assert(notation("e4 e5", move-numbers: false) == "e4 e5", message: "move-numbers off")

// --- promotion letter is localized too ---
#assert(notation("d8=Q", lang: "de") == "1. d8=D", message: "promotion localized")

= Notation output

English: #chess-notation(g) \
German: #notation(g, lang: "de") \
Russian: #notation(g, lang: "ru") \
Figurine: #notation(g, figurine: true) \
Slice (2b–3b): #notation(g, from: "2b", to: "3b")

#set text(lang: "de")
Auto (document lang = de): #notation(g, lang: "auto")
