// ===========================================================================
// Board renderer.
//
// The board is drawn on a free canvas using `place(dx, dy, ...)`. Every square,
// piece, highlight and label is positioned by ONE function `_screen`, which also
// handles board orientation (white or black at the bottom). The screen y-flip
// lives here and only here.
//
// `render-board(board, flip: false, ..overrides)` resolves a diagram-style
// (built-in ⊕ document state ⊕ per-call overrides) and draws it. Orientation is
// NOT a style field: it is decided by the per-call `flip` argument, so it cannot
// be set as a document default.
//
// Board labeling (`label-mode` field) has three modes:
//   * "on-square" (default): tiny file letters in the bottom-left corner of the
//     file-side edge squares, rank digits in the top-right corner of the
//     rank-side edge squares, each in the OPPOSITE colour of its square. Drawn
//     inside the board, so there is no gutter.
//   * "outside": label strips in a gutter outside the board (the classic look).
//   * "border": a band of `label-border-ratio` width around the board, filled in
//     the dark square colour, with labels in the light square colour.
// `labels: false` suppresses all of them. Board labels always use a fixed
// sans-serif font, independent of the document / diagram font. When "on-square"
// labels would render at or below `_on-square-min-size`, that diagram falls back
// to "border" labeling automatically (small boards stay legible).
//
// Size handling (`size` field):
//   * auto / none / <= 0  -> default size, clamped to available width;
//   * a length or ratio   -> that size, clamped so the whole figure (board plus
//                            any label gutter) fits the available width AND
//                            height of the insertion context (read via layout()).
// ===========================================================================

#import "coords.typ": file-letters, parse-square, is-dark-square
#import "pieces.typ": square-piece
#import "style.typ": default-style, style-state

#let default-light = default-style.light
#let default-dark = default-style.dark
#let default-board-size = 6.4cm

// Board labels use their own sans-serif, independent of the main/diagram font.
#let board-label-font = ("Helvetica", "Arial", "Liberation Sans", "DejaVu Sans")
#let _label-text(body, size, fill) = text(font: board-label-font, size: size, fill: fill, body)

// Label sizing (fractions of a square side). On-square labels are small and sit
// tucked into the corner; the "outside"/"border" labels live in a gutter so can
// be larger.
#let _on-square-label-frac = 0.22   // on-square label size (item 1: a bit smaller)
#let _on-square-pad-frac = 0.07     // on-square label inset from the corner (item 1: further in)
#let _strip-label-frac = 0.40       // "outside"/"border" label size
// When on-square labels would render at or below this size they are illegible,
// so an "on-square" diagram falls back to "border" labeling automatically.
#let _on-square-min-size = 4pt

// (col,row) -> (dx,dy) for a square of side `sq`, honouring orientation.
#let _screen(col, row, sq, orientation) = {
  if orientation == "black" {
    (dx: (7 - col) * sq, dy: row * sq)
  } else {
    (dx: col * sq, dy: (7 - row) * sq)
  }
}

// Resolve a colour spec used by arrows / highlights (item 6/8):
//   * `auto`         -> the supplied fallback colour;
//   * a string (a PGN %cal/%csl letter like "G") -> annotation-colors lookup;
//   * a colour value -> used as-is.
#let _resolve-anno-color(c, anno-map, fallback) = {
  if c == auto { fallback }
  else if type(c) == str { anno-map.at(c, default: fallback) }
  else { c }
}

// A straight arrow (item 6): a shaft plus a filled triangular head, from
// (fx,fy) to (tx,ty) in board-canvas coordinates. Drawn by `place`ing at the
// origin and giving absolute vertex coordinates, so it composes with the rest of
// the canvas. Sizes scale with the square `sq`. A zero-length arrow is skipped.
#let _arrow-shape(fx, fy, tx, ty, sq, color) = {
  let dx = (tx - fx) / 1pt
  let dy = (ty - fy) / 1pt
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { return }
  let ux = dx / len
  let uy = dy / len
  let head-len = sq * 0.36
  let head-hw = sq * 0.20
  let shaft-w = sq * 0.13
  let bx = tx - ux * head-len   // base of the head (shaft stops here)
  let by = ty - uy * head-len
  let px = -uy                  // unit perpendicular
  let py = ux
  place(dx: 0pt, dy: 0pt, line(start: (fx, fy), end: (bx, by), stroke: shaft-w + color))
  place(dx: 0pt, dy: 0pt, polygon(
    fill: color,
    (tx, ty),
    (bx + px * head-hw, by + py * head-hw),
    (bx - px * head-hw, by - py * head-hw),
  ))
}

// `extra-ratio` is the fraction of the board added by the label gutter on the
// CONSTRAINED dimension (one side for "outside", two for "border").
#let _resolve-size(size, available, extra-ratio) = {
  let avail-w = available.width
  let avail-h = available.height
  let raw = size
  if raw == auto or raw == none {
    raw = default-board-size
  } else if type(raw) == ratio {
    raw = avail-w * raw
  } else if type(raw) == length {
    if raw <= 0pt { raw = default-board-size }
  } else {
    panic("size must be a length, ratio, or auto; got: " + repr(size))
  }
  let factor = 1 + extra-ratio
  let s = calc.min(raw, avail-w / factor)
  if avail-h > 1pt { s = calc.min(s, avail-h / factor) }
  s
}

/// Render a board (square name -> (kind, color)) to content. `flip: true` puts
/// black at the bottom. Accepts style fields as named overrides (see style.typ).
#let render-board(squares, flip: false, ..overrides) = {
  assert(type(squares) == dictionary, message: "render-board expects a squares dict (square -> (kind, color)); got " + repr(type(squares)))

  context {
    let st = default-style + style-state.get() + overrides.named()
    assert(st.file-side == bottom or st.file-side == top, message: "file-side must be `top` or `bottom`")
    assert(st.rank-side == left or st.rank-side == right, message: "rank-side must be `left` or `right`")
    let modes = ("on-square", "outside", "border")
    assert(modes.contains(st.label-mode), message: "label-mode must be one of " + repr(modes) + "; got " + repr(st.label-mode))

    let labels = st.labels
    let orient = if flip { "black" } else { "white" }

    layout(available => {
      // Decide the effective label mode. "on-square" falls back to "border" when
      // its corner labels would be illegibly small at the resolved board size.
      let mode = st.label-mode
      if labels and mode == "on-square" {
        let s0 = _resolve-size(st.size, available, 0.0)
        if (s0 / 8) * _on-square-label-frac <= _on-square-min-size { mode = "border" }
      }

      // gutter as a fraction of the board, by mode (0 = labels live on the board)
      let g-ratio = if not labels { 0.0 }
        else if mode == "outside" { 0.09 }
        else if mode == "border" { st.label-border-ratio }
        else { 0.0 }
      // "border" adds the gutter on BOTH sides of each dimension.
      let extra = if mode == "border" { 2 * g-ratio } else { g-ratio }

      let s = _resolve-size(st.size, available, extra)
      let sq = s / 8
      let g = s * g-ratio
      let label-size = sq * _strip-label-frac

      let board-canvas = box(width: s, height: s, {
        // checker
        for row in range(8) {
          for col in range(8) {
            let o = _screen(col, row, sq, orient)
            place(dx: o.dx, dy: o.dy, rect(
              width: sq, height: sq,
              fill: if is-dark-square(col, row) { st.dark } else { st.light },
              stroke: none,
            ))
          }
        }
        // highlights (under the pieces, over the checker). Each entry is either
        // a square name (uses highlight-fill) or a (square, color) / (square,
        // letter) pair -- the latter for per-square PGN %csl colors (item 8).
        for h in st.highlight {
          let hname = if type(h) == str { h } else { h.at(0) }
          let hcol = if type(h) == str { st.highlight-fill } else { _resolve-anno-color(h.at(1), st.annotation-colors, st.highlight-fill) }
          let p = parse-square(hname)
          let o = _screen(p.col, p.row, sq, orient)
          place(dx: o.dx, dy: o.dy, rect(width: sq, height: sq, fill: hcol, stroke: none))
        }
        // optional grid lines between squares: a fixed 0.5pt black, at every
        // size (item 2). Drawn over the checker/highlights, under the pieces.
        if st.grid {
          for k in range(1, 8) {
            place(dx: k * sq, dy: 0pt, line(start: (0pt, 0pt), end: (0pt, s), stroke: 0.5pt + black))
            place(dx: 0pt, dy: k * sq, line(start: (0pt, 0pt), end: (s, 0pt), stroke: 0.5pt + black))
          }
        }
        // pieces -- the renderer no longer knows about baselines: square-piece
        // returns a square-sized cell positioned correctly for its piece set.
        for (name, piece) in squares {
          let p = parse-square(name)
          let o = _screen(p.col, p.row, sq, orient)
          place(dx: o.dx, dy: o.dy, square-piece(
            piece.kind, piece.color, sq,
            piece-set: st.piece-set,
            white-fill: st.white-fill, black-fill: st.black-fill, font: st.piece-font,
            piece-scale: st.piece-scale, baseline-inset: st.baseline-inset,
          ))
        }
        // on-square labels: drawn on top, in the corner, in the opposite colour
        // of the square they sit on. The edge rank/file follows file-side /
        // rank-side AND orientation, so labels move with a flip.
        if labels and mode == "on-square" {
          let pad = sq * _on-square-pad-frac
          let corner-size = sq * _on-square-label-frac
          let file-row = if st.file-side == bottom { if orient == "white" { 0 } else { 7 } } else { if orient == "white" { 7 } else { 0 } }
          let rank-col = if st.rank-side == right { if orient == "white" { 7 } else { 0 } } else { if orient == "white" { 0 } else { 7 } }
          for col in range(8) {
            let o = _screen(col, file-row, sq, orient)
            let on-dark = is-dark-square(col, file-row)
            place(dx: o.dx, dy: o.dy, box(width: sq, height: sq, inset: pad,
              align(left + bottom, _label-text(file-letters.at(col), corner-size, if on-dark { st.light } else { st.dark }))))
          }
          for row in range(8) {
            let o = _screen(rank-col, row, sq, orient)
            let on-dark = is-dark-square(rank-col, row)
            place(dx: o.dx, dy: o.dy, box(width: sq, height: sq, inset: pad,
              align(right + top, _label-text(str(row + 1), corner-size, if on-dark { st.light } else { st.dark }))))
          }
        }
        // arrows (item 6): on top of the pieces. Each entry is a dict
        // (from:, to:, color:) or a tuple ("f3","e5") / ("f3","e5", color).
        for a in st.arrows {
          let fsq = if type(a) == dictionary { a.from } else { a.at(0) }
          let tsq = if type(a) == dictionary { a.to } else { a.at(1) }
          let rawcol = if type(a) == dictionary { a.at("color", default: auto) } else if a.len() > 2 { a.at(2) } else { auto }
          let acol = _resolve-anno-color(rawcol, st.annotation-colors, st.arrow-color)
          let fp = parse-square(fsq)
          let tp = parse-square(tsq)
          let fo = _screen(fp.col, fp.row, sq, orient)
          let to = _screen(tp.col, tp.row, sq, orient)
          _arrow-shape(fo.dx + sq / 2, fo.dy + sq / 2, to.dx + sq / 2, to.dy + sq / 2, sq, acol)
        }
        if st.border != none {
          place(rect(width: s, height: s, fill: none, stroke: st.border))
        }
      })

      if not labels or mode == "on-square" { return board-canvas }

      if mode == "border" {
        // a band of width `g` around the board, in the dark-square colour (item 3);
        // labels are in the light square colour. A thin black line always
        // separates the band from the board, regardless of the `border` outline.
        let total = s + 2 * g
        let band-fill = st.dark
        box(width: total, height: total, {
          place(rect(width: total, height: total, fill: band-fill, stroke: none))
          place(dx: g, dy: g, board-canvas)
          place(dx: g, dy: g, rect(width: s, height: s, fill: none, stroke: 0.5pt + black))
          let file-dy = if st.file-side == bottom { g + s } else { 0pt }
          for col in range(8) {
            place(dx: g + _screen(col, 0, sq, orient).dx, dy: file-dy,
              box(width: sq, height: g, align(center + horizon,
                _label-text(file-letters.at(col), label-size, st.light))))
          }
          let rank-dx = if st.rank-side == right { g + s } else { 0pt }
          for row in range(8) {
            place(dx: rank-dx, dy: g + _screen(0, row, sq, orient).dy,
              box(width: g, height: sq, align(center + horizon,
                _label-text(str(row + 1), label-size, st.light))))
          }
        })
      } else {
        // "outside": label strips in a one-sided gutter (the classic look).
        let file-strip = box(width: s, height: g, {
          for col in range(8) {
            place(
              dx: _screen(col, 0, sq, orient).dx, dy: 0pt,
              box(width: sq, height: g, align(center + horizon,
                _label-text(file-letters.at(col), label-size, st.label-color))),
            )
          }
        })
        let rank-strip = box(width: g, height: s, {
          for row in range(8) {
            place(
              dx: 0pt, dy: _screen(0, row, sq, orient).dy,
              box(width: g, height: sq, align(center + horizon,
                _label-text(str(row + 1), label-size, st.label-color))),
            )
          }
        })

        let board-dx = if st.rank-side == left { g } else { 0pt }
        let board-dy = if st.file-side == top { g } else { 0pt }
        box(width: s + g, height: s + g, {
          place(dx: board-dx, dy: board-dy, board-canvas)
          place(dx: board-dx, dy: if st.file-side == top { 0pt } else { board-dy + s }, file-strip)
          place(dx: if st.rank-side == left { 0pt } else { board-dx + s }, dy: board-dy, rank-strip)
        })
      }
    })
  }
}
