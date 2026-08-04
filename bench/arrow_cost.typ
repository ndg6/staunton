// Prompt 54 -- drawing-cost probe for the agreed arrow style.
// Three arms, same 96 distinct arrows, so the only variable is HOW an arrow is
// drawn. `--input arm=a|b|c` selects the arm.
//
//   a = today's style      : 1 stroked line + 1 triangle polygon      (2 shapes)
//   b = segmented fade     : 48 quad polygons + 1 barbed polygon     (49 shapes)
//   c = gradient-stroke fade: 1 gradient-stroked line + 1 barbed polygon (2 shapes)
//
// Endpoints are all distinct, so Typst's argument-value memoisation cannot
// collapse the work (see the benchmark gotcha: a corpus that repeats itself
// silently measures far less than it claims).

#import "/lib.typ": board

#let ARM = sys.inputs.at("arm", default: "a")
#set page(paper: "a4", margin: 1cm)

#let FILES = ("a", "b", "c", "d", "e", "f", "g", "h")
#let ctr(name, S) = {
  let cs = S / 8
  let fi = FILES.position(c => c == lower(name.at(0)))
  let r = int(name.at(1))
  (fi * cs + cs / 2, (8 - r) * cs + cs / 2)
}
#let unit(p0, p1) = {
  let dx = (p1.at(0) - p0.at(0)) / 1pt
  let dy = (p1.at(1) - p0.at(1)) / 1pt
  let len = calc.sqrt(dx * dx + dy * dy)
  if len == 0 { (0, 0, 0) } else { (dx / len, dy / len, len) }
}
#let along(p, ux, uy, d) = (p.at(0) + ux * d, p.at(1) + uy * d)
#let lerp(a, b, t) = a + (b - a) * t

#let head-tri(tip, ux, uy, hl, hw, col) = {
  let b = along(tip, ux, uy, -hl)
  let (px, py) = (-uy, ux)
  place(dx: 0pt, dy: 0pt, polygon(fill: col, stroke: none,
    tip, (b.at(0) + px * hw, b.at(1) + py * hw), (b.at(0) - px * hw, b.at(1) - py * hw)))
}
#let head-hook(tip, ux, uy, hl, hw, col, notch: 0.42) = {
  let b = along(tip, ux, uy, -hl)
  let n = along(tip, ux, uy, -hl * notch)
  let (px, py) = (-uy, ux)
  place(dx: 0pt, dy: 0pt, polygon(fill: col, stroke: none,
    tip, (b.at(0) + px * hw, b.at(1) + py * hw), n, (b.at(0) - px * hw, b.at(1) - py * hw)))
}

// ---- arm a: today ----------------------------------------------------------
#let arrow-a(from, to, S, col) = {
  let cs = S / 8
  let p0 = ctr(from, S)
  let tip = ctr(to, S)
  let (ux, uy, len) = unit(p0, tip)
  if len == 0 { return }
  let hl = cs * 0.36
  let base = along(tip, ux, uy, -hl)
  place(dx: 0pt, dy: 0pt, line(start: p0, end: base, stroke: (cs * 15%) + col))
  head-tri(tip, ux, uy, hl, cs * 0.20, col)
}

// ---- arm b: segmented fade -------------------------------------------------
#let seg(p0, p1, w, col) = {
  let (ux, uy, len) = unit(p0, p1)
  if len == 0 { return }
  let (px, py) = (-uy, ux)
  place(dx: 0pt, dy: 0pt, polygon(fill: col, stroke: none,
    (p0.at(0) + px * w, p0.at(1) + py * w), (p1.at(0) + px * w, p1.at(1) + py * w),
    (p1.at(0) - px * w, p1.at(1) - py * w), (p0.at(0) - px * w, p0.at(1) - py * w)))
}
#let arrow-b(from, to, S, col, steps: 48, fade: 20%, fade-len: 0.55) = {
  let cs = S / 8
  let p0 = ctr(from, S)
  let tip = ctr(to, S)
  let (ux, uy, len) = unit(p0, tip)
  if len == 0 { return }
  let hl = cs * 0.36
  let notch = 0.42
  let stop = along(tip, ux, uy, -hl * notch)
  let (sx, sy, slen) = unit(p0, stop)
  let hw = cs * 15% / 2
  for i in range(steps) {
    let t0 = i / steps
    let t1 = (i + 1) / steps
    let a0 = along(p0, sx, sy, slen * t0 * 1pt)
    let a1 = along(p0, sx, sy, calc.min(slen, slen * t1 + 0.35) * 1pt)
    let t = (t0 + t1) / 2
    let al = if t >= fade-len { 100.0 } else { lerp(fade / 1%, 100.0, t / fade-len) }
    seg(a0, a1, hw, col.transparentize(100% - al * 1%))
  }
  head-hook(tip, ux, uy, hl, cs * 0.20, col)
}

// ---- arm c: gradient stroke ------------------------------------------------
#let arrow-c(from, to, S, col, fade: 20%, fade-len: 0.55) = {
  let cs = S / 8
  let p0 = ctr(from, S)
  let tip = ctr(to, S)
  let (ux, uy, len) = unit(p0, tip)
  if len == 0 { return }
  let hl = cs * 0.36
  let notch = 0.42
  let stop = along(tip, ux, uy, -hl * notch)
  // The gradient axis must run along the shaft: its angle is the shaft's own.
  let ang = calc.atan2(ux, uy)
  let g = gradient.linear(
    (col.transparentize(100% - fade), 0%),
    (col, fade-len * 100%),
    (col, 100%),
    angle: ang,
    space: rgb,
  )
  place(dx: 0pt, dy: 0pt, line(start: p0, end: stop, stroke: (cs * 15%) + g))
  head-hook(tip, ux, uy, hl, cs * 0.20, col)
}

// ---- workload --------------------------------------------------------------
// 32 boards x 3 arrows = 96 arrows, every one a distinct (from, to) pair.
#let S = 3.2cm
#let COLS = ("#15781b", "#003088", "#882020").map(rgb)
#let SQ = FILES.map(f => range(1, 9).map(r => f + str(r))).flatten()

// arm d: barbed head, SOLID shaft -- isolates the head's cost from the fade's.
#let arrow-d(from, to, S, col) = {
  let cs = S / 8
  let p0 = ctr(from, S)
  let tip = ctr(to, S)
  let (ux, uy, len) = unit(p0, tip)
  if len == 0 { return }
  let hl = cs * 0.36
  let stop = along(tip, ux, uy, -hl * 0.42)
  place(dx: 0pt, dy: 0pt, line(start: p0, end: stop, stroke: (cs * 15%) + col))
  head-hook(tip, ux, uy, hl, cs * 0.20, col)
}

// arm e: as c, but the gradient angle is ROUNDED to a whole degree. Board
// arrows join grid points, so there are only a few dozen distinct directions;
// if Typst shares identical gradient values, rounding makes them collide.
#let arrow-e(from, to, S, col, fade: 20%, fade-len: 0.55) = {
  let cs = S / 8
  let p0 = ctr(from, S)
  let tip = ctr(to, S)
  let (ux, uy, len) = unit(p0, tip)
  if len == 0 { return }
  let hl = cs * 0.36
  let stop = along(tip, ux, uy, -hl * 0.42)
  let ang = calc.round(calc.atan2(ux, uy) / 1deg) * 1deg
  let g = gradient.linear(
    (col.transparentize(100% - fade), 0%), (col, fade-len * 100%), (col, 100%),
    angle: ang, space: rgb,
  )
  place(dx: 0pt, dy: 0pt, line(start: p0, end: stop, stroke: (cs * 15%) + g))
  head-hook(tip, ux, uy, hl, cs * 0.20, col)
}

// arm q: DIAGNOSTIC ONLY -- every arrow gets the identical gradient (fixed
// angle). Visually wrong; it exists to show the floor if sharing were perfect.
#let arrow-q(from, to, S, col, fade: 20%, fade-len: 0.55) = {
  let cs = S / 8
  let p0 = ctr(from, S)
  let tip = ctr(to, S)
  let (ux, uy, len) = unit(p0, tip)
  if len == 0 { return }
  let hl = cs * 0.36
  let stop = along(tip, ux, uy, -hl * 0.42)
  let g = gradient.linear(
    (col.transparentize(100% - fade), 0%), (col, fade-len * 100%), (col, 100%),
    angle: 45deg, space: rgb,
  )
  place(dx: 0pt, dy: 0pt, line(start: p0, end: stop, stroke: (cs * 15%) + g))
  head-hook(tip, ux, uy, hl, cs * 0.20, col)
}

#let draw(i, from, to, col) = {
  if ARM == "0" { }                                    // boards only: baseline
  else if ARM == "e" { arrow-e(from, to, S, col) }
  else if ARM == "q" { arrow-q(from, to, S, col) }
  else if ARM == "a" { arrow-a(from, to, S, col) }
  else if ARM == "b" { arrow-b(from, to, S, col) }
  else if ARM == "d" { arrow-d(from, to, S, col) }
  else { arrow-c(from, to, S, col) }
}

// Arrows per board. Raise it to make the ARROW work dominate the board work,
// which is what has to be resolvable if the question is "what do arrows cost".
#let K = int(sys.inputs.at("n", default: "3"))

#grid(columns: 5, column-gutter: 4pt, row-gutter: 4pt,
  ..range(32).map(i => box(width: S, height: S, {
    place(top + left, board("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR", size: S, labels: false))
    place(top + left, box(width: S, height: S, {
      for j in range(K) {
        let a = SQ.at(calc.rem(i * 7 + j * 13, 64))
        let b = SQ.at(calc.rem(i * 11 + j * 29 + 5, 64))
        if a != b { draw(i, a, b, COLS.at(calc.rem(j, COLS.len()))) }
      }
    }))
  }))
)
