// ===========================================================================
// staunton - chess diagrams for Typst.
//
// Public API. Layers underneath (see src/):
//   position model  : fen.typ
//   rules engine    : engine.typ  (pseudo-legal -> legality filter)
//   SAN             : san.typ
//   PGN parsing     : pgn.typ     (Phase A: cheap, no engine)
//   navigation      : game.typ    (Phase B: engine on demand)
//   presentation    : style.typ + board.typ
// All front doors (FEN strings, manual pieces, PGN games) funnel into one
// renderer + one #figure wrapper.
// ===========================================================================

#import "src/coords.typ": parse-square, square-name, file-letter, file-letters, is-dark-square
#import "src/pieces.typ": piece-content, fen-piece, piece-kinds, piece-colors, default-piece-set, known-piece-sets
#import "src/variants.typ": variants, variant-spec, char-to-piece
#import "src/fen.typ": parse-fen, starting-fen
#import "src/engine.typ": legal-moves, apply, in-check
#import "src/san.typ": san-to-move, play-san
#import "src/pgn.typ": parse-pgn
#import "src/game.typ": mainline, position-after, game-result, game-start, line, move-san, move-node

// NOTE on reading external files: there is intentionally no `read-pgn(path)`
// wrapper. Typst's `read` resolves paths relative to the file the call appears
// in, so a wrapper here would resolve relative to this library, not your
// document. Read in your own file instead:  parse-pgn(read("game.pgn")).
#import "src/style.typ": (
  default-style, style-keys, set-chess-defaults, set-piece-set, chess-style,
  default-board-style, default-diagram-style, board-style-keys, diagram-style-keys,
  diagram-style-state, set-board-defaults, set-diagram-defaults,
)
#import "src/board.typ": render-board, default-light, default-dark, default-board-size

// Distinct figure kind so chess diagrams get their own counter and can be
// collected with  #outline(target: figure.where(kind: "chess")).
#let chess-kind = "chess"

// Parse the "string" position form into (squares, cols, rows). Accepts a single
// multi-line string, a raw block (```...```), or an array of row strings. The
// FIRST line is the TOP rank (read top-down, like FEN); "." is an empty square;
// upper case = white, lower case = black (resolved via the variant). All
// non-blank rows must have the same length (rectangular boards only).
#let _parse-position-string(input, variant) = {
  let lines = if type(input) == array { input }
    else if type(input) == str { input.split("\n") }
    else if type(input) == content and input.func() == raw { input.text.split("\n") }
    else { panic("position(): string form expects a string, a raw block, or row strings") }
  lines = lines.map(l => l.trim()).filter(l => l != "")
  assert(lines.len() > 0, message: "position(): empty position string")
  let rows = lines.len()
  let cols = lines.first().clusters().len()
  let squares = (:)
  for (i, ln) in lines.enumerate() {
    let cells = ln.clusters()
    assert(cells.len() == cols, message: "position(): row " + str(i + 1) + " has " + str(cells.len()) + " columns, expected " + str(cols) + " (board must be rectangular)")
    let row = rows - 1 - i   // first line is the top rank
    for (col, ch) in cells.enumerate() {
      if ch == "." { continue }
      squares.insert(square-name(col, row), char-to-piece(ch, variant: variant))
    }
  }
  (squares: squares, cols: cols, rows: rows)
}

/// Build a position from one of several forms (manual placement and friends):
///   * an array of (kind, color, square) tuples or dicts;
///   * a squares dict already in (square -> (kind, color)) form;
///   * the "string" form: a multi-line string, a raw block, or several row
///     strings -- e.g. position("....r...", "p.......", ...) or
///     position(```  ....r... \n ... ```).
/// Named options: `variant` (default "standard"), `turn`, `castling`,
/// `en-passant`, `halfmove`, `fullmove`, and `cols`/`rows` (default: derived
/// from the variant for non-string forms, counted for the string form).
/// Returns a position dict: (variant, cols, rows, squares, turn, castling,
/// en-passant, halfmove, fullmove).
#let position(..args) = {
  let opts = args.named()
  let variant = opts.at("variant", default: "standard")
  let spec = variant-spec(variant)
  let pos = args.pos()
  assert(pos.len() >= 1, message: "position(): expected at least one positional argument")

  let squares = (:)
  let cols = opts.at("cols", default: auto)
  let rows = opts.at("rows", default: auto)

  // string form: either several positional row strings, or one string/raw/
  // array-of-strings positional.
  let str-input = if pos.len() > 1 { pos }
    else if type(pos.first()) == str or (type(pos.first()) == content and pos.first().func() == raw) { pos.first() }
    else if type(pos.first()) == array and pos.first().len() > 0 and type(pos.first().first()) == str { pos.first() }
    else { none }

  if str-input != none {
    let r = _parse-position-string(str-input, variant)
    squares = r.squares
    if cols == auto { cols = r.cols }
    if rows == auto { rows = r.rows }
  } else {
    let p = pos.first()
    if type(p) == array {
      for entry in p {
        let (kind, color, square) = if type(entry) == array { (entry.at(0), entry.at(1), entry.at(2)) } else { (entry.kind, entry.color, entry.square) }
        let _ = parse-square(square, cols: spec.cols, rows: spec.rows) // validate
        squares.insert(lower(square), (kind: kind, color: color))
      }
    } else if type(p) == dictionary {
      squares = if "squares" in p { p.squares } else { p }
    } else {
      panic("position(): expected an array, a squares dict, a string, a raw block, or row strings; got " + repr(type(p)))
    }
    if cols == auto { cols = spec.cols }
    if rows == auto { rows = spec.rows }
  }

  (
    variant: variant, cols: cols, rows: rows, squares: squares,
    turn: opts.at("turn", default: "w"),
    castling: opts.at("castling", default: (:)),
    en-passant: opts.at("en-passant", default: none),
    halfmove: opts.at("halfmove", default: 0),
    fullmove: opts.at("fullmove", default: 1),
  )
}

// Normalise the many accepted `source` forms into a squares dict for rendering.
#let _to-squares(source) = {
  if type(source) == str { parse-fen(source).squares }
  else if type(source) == dictionary and "squares" in source { source.squares }
  else if type(source) == dictionary { source }
  else { panic("board(): source must be a FEN string, a position, or a squares dict") }
}

/// Draw a bare chess board (no figure, no caption). `source` is a FEN string, a
/// position dict, or a squares dict. `flip: true` shows it from Black's side.
/// Named style overrides (size, light, dark, labels, label-mode, file-side,
/// rank-side, piece-set, highlight, ...) behave exactly as for `chess-diagram`.
/// This is the drawing primitive that `chess-diagram` / `fen-diagram` wrap.
#let board(source, flip: false, ..overrides) = render-board(
  _to-squares(source), flip: flip, ..overrides.named(),
)

/// Alias for `board` reading as "standard chess board". (Variant-specific board
/// aliases like `xiangqi-board` are reserved for when those variants land.)
#let chess-board = board

// Above-diagram "game info" line: "<White> – <Black> (<Year>)". Drawn only when
// BOTH players are known; the year is appended in parentheses when present. The
// auto line is bold by default (diagram-style `info-bold`); a user-supplied
// `game-info:` is left untouched.
#let _game-info-line(white, black, year, bold: true) = {
  if white == none or black == none { return none }
  let yr = if year == none { none } else if type(year) == int { str(year) } else { year }
  let txt = if yr == none { [#white #sym.dash.en #black] } else { [#white #sym.dash.en #black (#yr)] }
  if bold { strong(txt) } else { txt }
}

// Below-diagram default caption for a FEN source: position + side to move.
#let _fen-caption(pos) = {
  let who = if pos.turn == "w" { "White" } else { "Black" }
  "Position at move " + str(pos.fullmove) + ", " + who + " to play"
}

// Below-diagram default caption for a PGN source: the last move played.
#let _pgn-caption(game, locator) = {
  let at = if type(locator) == str { locator } else { locator.at("at") }
  let color = at.slice(at.len() - 1)
  let num = at.slice(0, at.len() - 1)
  let prefix = if color == "w" { num + ". " } else { num + "... " }
  "Position after move " + prefix + move-san(game, locator)
}

// Year extracted from a PGN "Date" tag ("1972.07.11" -> "1972").
#let _year-of(game) = {
  let d = game.tags.at("Date", default: none)
  if d == none { return none }
  let m = d.match(regex("^(\d{4})"))
  if m != none { m.captures.at(0) } else { none }
}

// Parse PGN drawing annotations out of a move comment (item 8):
//   {[%cal Gf3e5,Bc6e5]}  -> arrows  (("f3","e5","G"), ("c6","e5","B"))
//   {[%csl Re5,Yc6]}      -> highlights (("e5","R"), ("c6","Y"))
// The colour letters resolve later through the board's `annotation-colors` map.
// Returns (arrows, highlight).
#let _pgn-annotations(game, locator) = {
  let node = move-node(game, locator)
  let c = node.at("comment-after", default: none)
  if c == none { return ((), ()) }
  let arrows = ()
  let highlight = ()
  let mcal = c.match(regex("\[%cal\s+([^\]]+)\]"))
  if mcal != none {
    for tok in mcal.captures.at(0).split(",") {
      let t = tok.trim()
      if t.len() >= 5 { arrows.push((t.slice(1, 3), t.slice(3, 5), t.slice(0, 1))) }
    }
  }
  let mcsl = c.match(regex("\[%csl\s+([^\]]+)\]"))
  if mcsl != none {
    for tok in mcsl.captures.at(0).split(",") {
      let t = tok.trim()
      if t.len() >= 3 { highlight.push((t.slice(1, 3), t.slice(0, 1))) }
    }
  }
  (arrows, highlight)
}

// Split a mixed named-argument dict three ways: board-style overrides, diagram-
// style overrides, and leftover #figure arguments.
#let _split-args(named) = {
  let board-ov = (:)
  let diagram-ov = (:)
  let fig-args = (:)
  for (k, v) in named {
    if board-style-keys.contains(k) { board-ov.insert(k, v) }
    else if diagram-style-keys.contains(k) { diagram-ov.insert(k, v) }
    else { fig-args.insert(k, v) }
  }
  (board-ov, diagram-ov, fig-args)
}

/// Main entry point: a chess diagram wrapped in a #figure.
///
/// `source` may be a FEN string, a position dict (from `position`/`parse-fen`),
/// or a bare board dict. Labeling (subtask 3.4):
///   * ABOVE the board: if both players are known, an automatic
///     "<White> – <Black> (<Year>)" line; override with `game-info`.
///   * BELOW the board (the figure caption): for a FEN string source, a default
///     "Position at move N, X to play"; for a position/board dict, no default.
///     Override either with `caption`.
/// `flip: true` shows the board from Black's side (per-diagram only). Remaining
/// named arguments are split: style fields (size, light, dark, labels,
/// label-mode, file-side, rank-side, piece-set, highlight, ...) go to the
/// renderer; anything else is forwarded to `figure` (e.g. `placement: top`).
#let chess-diagram(
  source,
  white: none,
  black: none,
  event: none,
  year: none,
  caption: auto,
  game-info: auto,
  flip: false,
  ..args,
) = {
  let (board-ov, diagram-ov, fig-args) = _split-args(args.named())
  let below = if caption != auto { caption } else if type(source) == str { _fen-caption(parse-fen(source)) } else { none }
  let drawn = board(source, flip: flip, ..board-ov)
  // The diagram-style state needs `context`, but the #figure itself must NOT be a
  // context element (otherwise it cannot be referenced). So we read the state
  // inside the figure body and supplement, leaving the figure a real element.
  let body = context {
    let dst = default-diagram-style + diagram-style-state.get() + diagram-ov
    let above = if game-info != auto { game-info } else { _game-info-line(white, black, year, bold: dst.info-bold) }
    if above != none { align(center, stack(dir: ttb, spacing: dst.info-gap, above, drawn)) } else { drawn }
  }
  let supp = context { (default-diagram-style + diagram-style-state.get() + diagram-ov).supplement }
  figure(body, kind: chess-kind, supplement: supp, caption: below, ..fig-args)
}

/// Convenience alias mirroring the FEN-centric workflow.
#let fen-diagram(fen-string, ..args) = chess-diagram(fen-string, ..args)

/// A chess diagram for the position at `locator` within a parsed `game`
/// (mainline "30w"/"30b" or a variation path). The players/year default to the
/// game's roster tags (so the above-line is drawn automatically) and the caption
/// defaults to "Position after move <last move>". Override any of them, or pass
/// `flip` / style fields, exactly as in `chess-diagram`.
///
/// When `pgn-annotations` is true (default), `%cal` / `%csl` drawing annotations
/// in the move's comment are turned into arrows / highlights and MERGED with any
/// `arrows` / `highlight` passed explicitly. Their colour letters resolve through
/// the board's `annotation-colors` map.
#let board-after(game, locator, white: auto, black: auto, year: auto, caption: auto, pgn-annotations: true, ..args) = {
  let pos = position-after(game, locator)
  let cap = if caption != auto { caption } else { _pgn-caption(game, locator) }
  let w = if white != auto { white } else { game.tags.at("White", default: none) }
  let b = if black != auto { black } else { game.tags.at("Black", default: none) }
  let y = if year != auto { year } else { _year-of(game) }

  let named = args.named()
  let (anno-arrows, anno-highlight) = if pgn-annotations { _pgn-annotations(game, locator) } else { ((), ()) }
  let merged-arrows = named.at("arrows", default: ()) + anno-arrows
  let merged-highlight = named.at("highlight", default: ()) + anno-highlight
  let rest = (:)
  for (k, v) in named { if k != "arrows" and k != "highlight" { rest.insert(k, v) } }

  chess-diagram(
    pos, white: w, black: b, year: y, caption: cap,
    arrows: merged-arrows, highlight: merged-highlight, ..rest,
  )
}

/// An outline listing only chess diagrams (figures with `kind: chess-kind`).
/// Extra named arguments are forwarded to `outline` (e.g. `depth`, `indent`).
#let chess-outline(title: [List of Chess Diagrams], ..args) = outline(
  title: title,
  target: figure.where(kind: chess-kind),
  ..args,
)
