// ===========================================================================
// Human-readable move notation.
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

#import "san.typ": _split-movetext
#import "pgn.typ": movetext
#import "i18n.typ": notation-langs, lang-piece-chars
#import "game.typ": mainline, game-result
#import "annotations.typ": interpret-comment, nag-symbol
#import "style.typ": default-pgn-style, pgn-style-state

// The only uppercase letters that denote a piece in SAN -> kind. Files (a-h),
// ranks, "x", "+", "#", "O-O" and NAGs are never piece letters and pass through.
#let _letter-to-kind = (K: "king", Q: "queen", R: "rook", B: "bishop", N: "knight")

// Figurine glyphs are colour-aware: White's moves use the OUTLINE ("white")
// chess symbols U+2654..2658, Black's the SOLID ("black") ones U+265A..265E, so
// the side to move reads off the figurine itself (not just the move number).
// (Some fonts render the outline glyphs lighter than the solid ones.)
#let _fig-white = (king: "\u{2654}", queen: "\u{2655}", rook: "\u{2656}", bishop: "\u{2657}", knight: "\u{2658}")
#let _fig-black = (king: "\u{265A}", queen: "\u{265B}", rook: "\u{265C}", bishop: "\u{265D}", knight: "\u{265E}")

// "12w" -> ply 23 ; "12b" -> ply 24 (same convention as game.typ locators).
#let _ply-of(loc) = {
  assert(type(loc) == str and loc.len() >= 2, message: "notation: bad move locator: " + repr(loc))
  let color = loc.slice(loc.len() - 1)
  let num = int(loc.slice(0, loc.len() - 1))
  if color == "w" { 2 * num - 1 } else if color == "b" { 2 * num }
  else { panic("notation: move locator must end in 'w' or 'b': " + loc) }
}

// One piece letter rendered as the language letter, or the colour-aware figurine
// glyph (`white` selects the outline vs solid set).
#let _piece-out(letter, chars, figurine, white) = {
  let kind = _letter-to-kind.at(letter)
  if figurine { (if white { _fig-white } else { _fig-black }).at(kind) }
  else { chars.at(kind) }
}

// Transform one canonical (English) SAN token: substitute the leading piece
// letter and any promotion letter (after "="); leave everything else untouched.
// `white` is the side that played the move (for colour-aware figurines).
#let _localize-san(san, chars, figurine, white) = {
  if san == "" { return "" }
  let cs = san.clusters()
  let out = ""
  let i = 0
  if _letter-to-kind.keys().contains(cs.at(0)) {
    out += _piece-out(cs.at(0), chars, figurine, white)
    i = 1
  }
  while i < cs.len() {
    let ch = cs.at(i)
    if ch == "=" and i + 1 < cs.len() and _letter-to-kind.keys().contains(cs.at(i + 1)) {
      out += "=" + _piece-out(cs.at(i + 1), chars, figurine, white)
      i += 2
    } else {
      out += ch
      i += 1
    }
  }
  out
}

// Wrap a SAN string into a minimal move node (no nags/comments).
#let _bare-node(san) = (san: san, nags: (), comment-after: none)

// Resolve a source + from/to into (nodes, lo, hi) inclusive node indices. A game
// yields its real move nodes (carrying nags/comments); a SAN string/array yields
// bare nodes (so nags/comments are simply empty there).
#let _resolve-line(source, from, to) = {
  for loc in (from, to) {
    if loc != none and type(loc) != str {
      panic("notation: variation-line ranges are not supported yet; use mainline locators like \"12w\"")
    }
  }
  let nodes = if type(source) == str { _split-movetext(source).map(_bare-node) }
    else if type(source) == array { source.map(_bare-node) }
    else if type(source) == content and source.func() == raw { _split-movetext(source.text).map(_bare-node) }
    else if type(source) == dictionary and "movetext-raw" in source { movetext(source) }
    else if type(source) == dictionary and "squares" in source {
      panic("notation: a position has no move history; pass a game or a SAN source (string/array)")
    } else {
      panic("notation: source must be a game, a SAN move-text string, or a SAN array")
    }
  if nodes.len() == 0 { return (nodes: (), lo: 0, hi: -1) }
  let lo = if from == none { 0 } else { _ply-of(from) - 1 }
  let hi = if to == none { nodes.len() - 1 } else { _ply-of(to) - 1 }
  assert(lo >= 0 and lo < nodes.len(), message: "notation: `from` locator out of range")
  assert(hi >= lo and hi < nodes.len(), message: "notation: `to` locator out of range, or before `from`")
  (nodes: nodes, lo: lo, hi: hi)
}

// Render indices [lo, hi] of `nodes`: move numbers, resolved piece letters, and
// (when on) NAG symbols and the residual comment prose.
#let _render(nodes, lo, hi, figurine, chars, move-numbers, nags, comments, tail) = {
  let parts = ()
  let first = true
  for idx in range(lo, hi + 1) {
    let node = nodes.at(idx)
    let ply = idx + 1
    let white = calc.odd(ply)
    let movenum = int((ply + 1) / 2)
    let tok = _localize-san(node.san, chars, figurine, white)
    if nags {
      for ng in node.at("nags", default: ()) { tok += nag-symbol(ng) }
    }
    if comments {
      let t = interpret-comment(node.at("comment-after", default: none)).text
      if t != "" { tok += " " + t }
    }
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
/// (`auto` -> the document language via `set-lang`; a code like "de"; or the
/// string "auto" to follow `#set text(lang: ..)`; unknown -> en),
/// `move-numbers`, `result` (append the game result). `nags` / `comments`
/// (default `auto`) render move NAGs / comment prose; `auto` consults the
/// document `set-pgn-defaults` (both off by default). When everything resolves
/// without document state the result is a plain string; otherwise it is content.
#let notation(source, from: none, to: none, figurine: false, lang: auto, nags: auto, comments: auto, move-numbers: true, result: false) = {
  let r = _resolve-line(source, from, to)
  let tail = if result and type(source) == dictionary and "movetext-raw" in source { game-result(source) } else { none }
  // `lang: auto` (the VALUE) consults the document `set-lang` setting; `lang:
  // "auto"` follows `#set text(lang:)`; an explicit code needs no document state.
  let lang-needs-state = lang == auto or lang == "auto"
  let needs-state = lang-needs-state or nags == auto or comments == auto
  if needs-state {
    context {
      let pg = default-pgn-style + pgn-style-state.get()
      let rn = if nags != auto { nags } else { pg.nags }
      let rc = if comments != auto { comments } else { pg.comments }
      let chars = lang-piece-chars(lang)
      _render(r.nodes, r.lo, r.hi, figurine, chars, move-numbers, rn, rc, tail)
    }
  } else {
    let chars = notation-langs.at(lang, default: notation-langs.en)
    _render(r.nodes, r.lo, r.hi, figurine, chars, move-numbers, nags, comments, tail)
  }
}

/// Standard western chess notation -- the variant-named sugar over `notation`.
#let chess-notation(source, ..args) = {
  if type(source) == dictionary and source.at("variant", default: "standard") != "standard" {
    panic("chess-notation: expected standard chess; got variant " + repr(source.variant))
  }
  notation(source, ..args.named())
}
