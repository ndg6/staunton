// Asserting test: a move-quality badge's glyph stays INSIDE its disc.
//
// All six symbols render at one font size (`r * 1.2`). Two-glyph symbols used to
// shrink to `r * 0.85`, which was unnecessary and made "!!"/"??" read lighter
// than "!"/"?" — an emphasis difference the glyphs do not mean. This sheet pins
// the property that justified removing the shrink: every symbol fits at the
// single size, with margin.
//
// `_mq-fits` exists so this is checkable at all: the badge is drawn into a
// `place`, and a rendered board is not queryable (`query(selector(rect))` errors
// on non-locatable elements), so measuring the text is the only machine-readable
// seam.
#import "/src/board.typ": _mq-fits

#let syms = ("!", "?", "!!", "??", "!?", "?!")

#context {
  for s in syms {
    let f = _mq-fits(26pt, s)
    // Hard requirement: inside the disc at all.
    assert(f.width-frac < 1.0,
      message: "badge \"" + s + "\" is wider than its disc: " + str(calc.round(f.width-frac * 100, digits: 1)) + "%")
    assert(f.corner-frac < 1.0,
      message: "badge \"" + s + "\" box corner escapes the disc: " + str(calc.round(f.corner-frac * 100, digits: 1)) + "%")
    // Margin requirement: comfortably inside, not merely touching. Measured
    // worst case is "??" at ~52% width / ~65% corner, so 80% leaves real slack
    // for font substitution (the suite renders with --ignore-system-fonts).
    assert(f.width-frac < 0.80,
      message: "badge \"" + s + "\" has lost its margin: width " + str(calc.round(f.width-frac * 100, digits: 1)) + "% of the disc")
    assert(f.corner-frac < 0.90,
      message: "badge \"" + s + "\" has lost its margin: corner " + str(calc.round(f.corner-frac * 100, digits: 1)) + "% of the radius")
  }
}

// Scale-invariance: the fit is a ratio, so it must not depend on board size.
#context {
  let small = _mq-fits(6pt, "??")
  let large = _mq-fits(60pt, "??")
  assert(calc.abs(small.width-frac - large.width-frac) < 0.02,
    message: "badge fit must be scale-invariant: " + str(small.width-frac) + " vs " + str(large.width-frac))
}

= Move-quality badge fit OK

All six symbols fit inside the disc at the single badge font size, with margin,
independently of board size.
