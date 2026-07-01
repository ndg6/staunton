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

// One move's text: number prefix + localized SAN + (NAG glyphs) + (comment prose).
// `ply` is 1-based (ply 1 = White's 1st move); `force` re-shows the move number
// even for a Black move (after a run start, a variation, or a comment).
#let _move-token(node, ply, force, opts) = {
  let white = calc.odd(ply)
  let num = ""
  if opts.move-numbers {
    let movenum = int((ply + 1) / 2)
    if white { num = str(movenum) + ". " }
    else if force { num = str(movenum) + "... " }
  }
  let tok = num + _localize-san(node.san, opts.chars, opts.figurine, white)
  if opts.nags {
    for ng in node.at("nags", default: ()) { tok += nag-symbol(ng) }
  }
  if opts.comments {
    let t = interpret-comment(node.at("comment-after", default: none)).text
    if t != "" { tok += " " + t }
  }
  tok
}

// Inline renderer: a run of nodes from `start-ply`, with variations (when
// `opts.variations`) spliced in parentheses. A variation attached to a node is an
// alternative to THAT move, so it starts at the same ply. Returns a string.
#let _render-inline(nodes, start-ply, opts) = {
  let parts = ()
  let force = true
  let ply = start-ply
  for node in nodes {
    parts.push(_move-token(node, ply, force, opts))
    force = false
    let vars = node.at("variations", default: ())
    if opts.variations and vars.len() > 0 {
      for sub in vars { parts.push("(" + _render-inline(sub, ply, opts) + ")") }
      force = true   // resumed move re-shows its number
    }
    ply += 1
  }
  parts.join(" ")
}

// Block renderer: variations break onto their own line, indented one level per
// nesting depth. Returns an array of (level, text) lines.
#let _render-block(nodes, start-ply, level, opts) = {
  let lines = ()
  let buf = ()
  let force = true
  let ply = start-ply
  for node in nodes {
    buf.push(_move-token(node, ply, force, opts))
    force = false
    let vars = node.at("variations", default: ())
    if opts.variations and vars.len() > 0 {
      lines.push((level, buf.join(" ")))
      buf = ()
      for sub in vars { lines += _render-block(sub, ply, level + 1, opts) }
      force = true
    }
    ply += 1
  }
  if buf.len() > 0 { lines.push((level, buf.join(" "))) }
  lines
}

// Render indices [lo, hi] of `nodes` per `opts`; `tail` is an optional result
// token. `variation-style: "inline"` yields a string; `"block"` yields content.
#let _render(nodes, lo, hi, opts, tail) = {
  let has-tail = tail != none and tail != "" and tail != "*"
  if hi < lo { return if has-tail { tail } else { "" } }
  let slice = nodes.slice(lo, hi + 1)
  if opts.variation-style == "block" {
    let lines = _render-block(slice, lo + 1, 0, opts)
    if has-tail and lines.len() > 0 {
      let (lvl, txt) = lines.last()
      lines.at(lines.len() - 1) = (lvl, txt + " " + tail)
    }
    return stack(dir: ttb, spacing: 0.5em,
      ..lines.map(((lvl, txt)) => pad(left: lvl * opts.indent, txt)))
  }
  let body = _render-inline(slice, lo + 1, opts)
  if has-tail { body = body + " " + tail }
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
#let notation(source, from: none, to: none, figurine: false, lang: auto, nags: auto, comments: auto, variations: auto, variation-style: "inline", move-numbers: true, result: false) = {
  assert(variation-style in ("inline", "block"), message: "notation: variation-style must be \"inline\" or \"block\"; got " + repr(variation-style))
  let r = _resolve-line(source, from, to)
  let tail = if result and type(source) == dictionary and "movetext-raw" in source { game-result(source) } else { none }
  let mk-opts = (chars, rn, rc, rv) => (
    figurine: figurine, chars: chars, move-numbers: move-numbers,
    nags: rn, comments: rc, variations: rv,
    variation-style: variation-style, indent: 1.2em,
  )
  // `lang: auto` (the VALUE) consults the document `set-lang` setting; `lang:
  // "auto"` follows `#set text(lang:)`; an explicit code needs no document state.
  // `nags`/`comments`/`variations: auto` consult `set-pgn-defaults`.
  let lang-needs-state = lang == auto or lang == "auto"
  let needs-state = lang-needs-state or nags == auto or comments == auto or variations == auto
  if needs-state {
    context {
      let pg = default-pgn-style + pgn-style-state.get()
      let rn = if nags != auto { nags } else { pg.nags }
      let rc = if comments != auto { comments } else { pg.comments }
      let rv = if variations != auto { variations } else { pg.variations }
      let chars = lang-piece-chars(lang)
      _render(r.nodes, r.lo, r.hi, mk-opts(chars, rn, rc, rv), tail)
    }
  } else {
    let chars = notation-langs.at(lang, default: notation-langs.en)
    _render(r.nodes, r.lo, r.hi, mk-opts(chars, nags, comments, variations), tail)
  }
}

/// Standard western chess notation -- the variant-named sugar over `notation`.
#let chess-notation(source, ..args) = {
  if type(source) == dictionary and source.at("variant", default: "standard") != "standard" {
    panic("chess-notation: expected standard chess; got variant " + repr(source.variant))
  }
  notation(source, ..args.named())
}

// ---- programmatic NAGs ----------------------------------------------------
// `with-nags(game, overrides)` returns a NEW game whose addressed MAINLINE moves
// carry the given NAGs, so `notation(.., nags: true)` renders them without
// editing the PGN. `overrides` maps a mainline locator ("12w"/"12b") to a NAG
// value (or an array of them). A value is the canonical "$n" form, or one of the
// six suffix glyphs (! ? !! ?? !? ?!) -- sugar for $1..$6. The mapping REPLACES
// any NAGs already on that move; the source game is never mutated. (Variations
// are not addressable: notation renders the mainline only.)
//
// Mechanism: stash the patched node tree on the returned game; `movetext` honours
// it (see pgn.typ), so the override flows through every consumer transparently.
#let _glyph-to-code = ("!": "1", "?": "2", "!!": "3", "??": "4", "!?": "5", "?!": "6")
#let _norm-nag(v) = {
  if type(v) == str and v.starts-with("$") and v.len() > 1 { v.slice(1) }
  else if type(v) == str and v in _glyph-to-code { _glyph-to-code.at(v) }
  else { panic("with-nags: a NAG must be \"$n\" or one of ! ? !! ?? !? ?!; got " + repr(v)) }
}
#let with-nags(game, overrides) = {
  assert(
    type(game) == dictionary and "movetext-raw" in game,
    message: "with-nags: first argument must be a parsed game (from parse-pgn)",
  )
  let nodes = movetext(game)
  for (loc, val) in overrides {
    let idx = _ply-of(loc) - 1
    assert(idx >= 0 and idx < nodes.len(), message: "with-nags: locator out of range: " + loc)
    let codes = if type(val) == array { val.map(_norm-nag) } else { (_norm-nag(val),) }
    let node = nodes.at(idx)
    node.nags = codes
    nodes.at(idx) = node
  }
  let g = game
  g.insert("movetext-nodes", nodes)
  g
}
