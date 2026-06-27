// ===========================================================================
// Human-readable move notation (prompt 14).
//
// Games carry SAN strings verbatim from the PGN (canonical English: "Nf3",
// "O-O", "exd5", "e8=Q+"). So figurine output and language-aware piece letters
// are a pure STRING TRANSFORM on existing SAN -- no engine needed. (Generating
// SAN from positions/moves would need a move->SAN encoder, which does not exist
// yet; this module only FORMATS SAN we already hold.)
//
// `notation` is the variant-agnostic formatter; `chess-notation` is the standard
// sugar (mirroring board/diagram, play-moves). A future `xiangqi-notation` would
// be a different formatter entirely.
//
// Source forms (consistent with `play-moves`):
//   * a parsed game            -> its mainline SAN;
//   * a move-text string       -> tokenised with `_split-movetext`;
//   * a SAN array              -> used directly.
// `from`/`to` are board-after-style mainline locators ("12w"/"12b"), inclusive;
// defaults are first/last move. (Variation-line ranges are not supported yet.)
// ===========================================================================

#import "pieces.typ": piece-glyphs
#import "san.typ": _split-movetext
#import "game.typ": mainline, game-result
#import "i18n.typ": notation-langs

// The only uppercase letters that denote a piece in SAN -> kind. Files (a-h),
// ranks, "x", "+", "#", "O-O" and NAGs are never piece letters and pass through.
#let _letter-to-kind = (K: "king", Q: "queen", R: "rook", B: "bishop", N: "knight")

// "12w" -> ply 23 ; "12b" -> ply 24 (same convention as game.typ locators).
#let _ply-of(loc) = {
  assert(type(loc) == str and loc.len() >= 2, message: "notation: bad move locator: " + repr(loc))
  let color = loc.slice(loc.len() - 1)
  let num = int(loc.slice(0, loc.len() - 1))
  if color == "w" { 2 * num - 1 } else if color == "b" { 2 * num }
  else { panic("notation: move locator must end in 'w' or 'b': " + loc) }
}

// One piece letter rendered as the language letter, or the figurine glyph.
#let _piece-out(letter, chars, figurine) = {
  let kind = _letter-to-kind.at(letter)
  if figurine { piece-glyphs.at(kind) } else { chars.at(kind) }
}

// Transform one canonical (English) SAN token: substitute the leading piece
// letter and any promotion letter (after "="); leave everything else untouched.
#let _localize-san(san, chars, figurine) = {
  if san == "" { return "" }
  let cs = san.clusters()
  let out = ""
  let i = 0
  if _letter-to-kind.keys().contains(cs.at(0)) {
    out += _piece-out(cs.at(0), chars, figurine)
    i = 1
  }
  while i < cs.len() {
    let ch = cs.at(i)
    if ch == "=" and i + 1 < cs.len() and _letter-to-kind.keys().contains(cs.at(i + 1)) {
      out += "=" + _piece-out(cs.at(i + 1), chars, figurine)
      i += 2
    } else {
      out += ch
      i += 1
    }
  }
  out
}

// Resolve a source + from/to into (sans, lo, hi) inclusive node indices.
#let _resolve-line(source, from, to) = {
  for loc in (from, to) {
    if loc != none and type(loc) != str {
      panic("notation: variation-line ranges are not supported yet; use mainline locators like \"12w\"")
    }
  }
  let sans = if type(source) == str { _split-movetext(source) }
    else if type(source) == array { source }
    else if type(source) == content and source.func() == raw { _split-movetext(source.text) }
    else if type(source) == dictionary and "movetext" in source { mainline(source) }
    else if type(source) == dictionary and "squares" in source {
      panic("notation: a position has no move history; pass a game or a SAN source (string/array)")
    } else {
      panic("notation: source must be a game, a SAN move-text string, or a SAN array")
    }
  if sans.len() == 0 { return (sans: (), lo: 0, hi: -1) }
  let lo = if from == none { 0 } else { _ply-of(from) - 1 }
  let hi = if to == none { sans.len() - 1 } else { _ply-of(to) - 1 }
  assert(lo >= 0 and lo < sans.len(), message: "notation: `from` locator out of range")
  assert(hi >= lo and hi < sans.len(), message: "notation: `to` locator out of range, or before `from`")
  (sans: sans, lo: lo, hi: hi)
}

// Render indices [lo, hi] of `sans` with move numbers and the resolved letters.
#let _render(sans, lo, hi, figurine, chars, move-numbers, tail) = {
  let parts = ()
  let first = true
  for idx in range(lo, hi + 1) {
    let ply = idx + 1
    let white = calc.odd(ply)
    let movenum = int((ply + 1) / 2)
    let tok = _localize-san(sans.at(idx), chars, figurine)
    let s = ""
    if move-numbers {
      if white { s = str(movenum) + ". " }
      else if first { s = str(movenum) + "... " }   // Black move numbered only when it leads the run
    }
    parts.push(s + tok)
    first = false
  }
  let body = parts.join(" ")
  if tail != none and tail != "" and tail != "*" { body = body + " " + tail }
  body
}

/// Render move notation from a game (mainline), a move-text string, or a SAN
/// array. `from`/`to` are inclusive mainline locators ("12w"/"12b"); omit for the
/// whole line. Options: `figurine` (glyphs instead of letters), `lang`
/// ("en" | "auto" | code; "auto" follows `#set text(lang: ..)`, unknown -> en),
/// `move-numbers`, `result` (append the game result, for a game source).
#let notation(source, from: none, to: none, figurine: false, lang: "en", move-numbers: true, result: false) = {
  let r = _resolve-line(source, from, to)
  let tail = if result and type(source) == dictionary and "movetext" in source { game-result(source) } else { none }
  if lang == "auto" {
    context {
      let chars = notation-langs.at(text.lang, default: notation-langs.en)
      _render(r.sans, r.lo, r.hi, figurine, chars, move-numbers, tail)
    }
  } else {
    let chars = notation-langs.at(lang, default: notation-langs.en)
    _render(r.sans, r.lo, r.hi, figurine, chars, move-numbers, tail)
  }
}

/// Standard western chess notation -- the variant-named sugar over `notation`.
#let chess-notation(source, ..args) = {
  if type(source) == dictionary and source.at("variant", default: "standard") != "standard" {
    panic("chess-notation: expected standard chess; got variant " + repr(source.variant))
  }
  notation(source, ..args.named())
}
