// Unicode figurine input to `normalize-san`: figurines resolve to the
// canonical ENGLISH SAN letter for every language, INCLUDING "en", and this
// resolution must be terminal -- it must never fall through into the
// per-language letter pass, because English letters collide across
// languages (Spanish/French/Italian/Portuguese "R" is a king, not a rook).
#import "/src/i18n.typ": normalize-san, notation-langs
#import "/src/notation.typ": _fig-white, _fig-black
#import "/lib.typ": game, mainline, to-fen

// ---- the central cross-language collision: same output char, opposite
// meaning depending on whether it came from a figurine or a language letter.
#assert.eq(normalize-san("\u{2656}a1", "es"), "Ra1", message: "es: figurine rook stays a rook")
#assert.eq(normalize-san("Ra1", "es"), "Ka1", message: "es: the LETTER R still means king, unchanged")
#assert.eq(normalize-san("\u{2656}a1", "fr"), "Ra1", message: "fr: figurine rook stays a rook")
#assert.eq(normalize-san("Ra1", "fr"), "Ka1", message: "fr: the LETTER R still means king, unchanged")
#assert.eq(normalize-san("\u{2656}a1", "it"), "Ra1", message: "it: figurine rook stays a rook")
#assert.eq(normalize-san("Ra1", "it"), "Ka1", message: "it: the LETTER R still means king, unchanged")
#assert.eq(normalize-san("\u{2656}a1", "pt"), "Ra1", message: "pt: figurine rook stays a rook")
#assert.eq(normalize-san("Ra1", "pt"), "Ka1", message: "pt: the LETTER R still means king, unchanged")

// ---- both colour sets accepted, colour ignored ----
#assert.eq(normalize-san("\u{2658}f3", "en"), "Nf3", message: "white knight figurine -> N")
#assert.eq(normalize-san("\u{265E}c6", "en"), "Nc6", message: "black knight figurine -> N")
#assert.eq(normalize-san("\u{265C}xd4+", "en"), "Rxd4+", message: "black rook figurine, capture+check suffix preserved")

// ---- pawn glyphs are STRIPPED, not translated ----
#assert.eq(normalize-san("\u{2659}e4", "en"), "e4", message: "white pawn figurine stripped")
#assert.eq(normalize-san("\u{265F}e4", "en"), "e4", message: "black pawn figurine stripped")

// ---- promotion after "=" ----
#assert.eq(normalize-san("e8=\u{2655}", "en"), "e8=Q", message: "promotion figurine after =")
#assert.eq(normalize-san("e8=\u{265B}", "en"), "e8=Q", message: "promotion figurine after = (black set)")

// ---- a full game with figurine tokens: mainline() and to-fen() both work ----
#let g = game("[White \"A\"][Black \"B\"] 1. e4 e5 2. \u{2658}f3 \u{265E}c6 3. \u{2657}b5 *")
#assert.eq(mainline(g), ("e4", "e5", "Nf3", "Nc6", "Bb5"), message: "figurine movetext normalizes to English SAN")
// to-fen must succeed (before this change: "unexpected character in SAN").
#let _ = to-fen(g, at: "3w")

// ---- mixed figurine/letter input in ONE game (German: "S" and a knight
// figurine both denote a knight, and both must land on "N") ----
#let gm = game("[White \"A\"][Black \"B\"][SetUp \"0\"] 1. e4 e5 2. Sf3 \u{265E}c6 *", lang: "de")
#assert.eq(mainline(gm), ("e4", "e5", "Nf3", "Nc6"), message: "mixed German letter + figurine knight both normalize to N")

// ---- regression guard: the plain-letter paths are unchanged by this feature ----
#assert.eq(normalize-san("Sf3", "de"), "Nf3", message: "German letter S -> N still works")
#let g-en = game("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 *")
#assert.eq(mainline(g-en), ("e4", "e5", "Nf3", "Nc6", "Bb5", "a6"), message: "plain English game is byte-identical to before")

// ---- output/input glyph-set agreement: every glyph notation.typ EMITS via
// figurine output must be accepted by normalize-san on the input side. This
// is what lets staunton read its own figurine output, and it catches the
// drift case where a glyph is added to one side only.
#for (kind, glyph) in _fig-white {
  assert.eq(
    normalize-san(glyph + "f3", "en"), notation-langs.en.at(kind) + "f3",
    message: "white figurine for " + kind + " accepted on input",
  )
}
#for (kind, glyph) in _fig-black {
  assert.eq(
    normalize-san(glyph + "f3", "en"), notation-langs.en.at(kind) + "f3",
    message: "black figurine for " + kind + " accepted on input",
  )
}

= i18n figurine SAN OK
