#!/usr/bin/env python3
"""Generate staunton's wood material assets (prompt 47).

Pure stdlib -- emits SVG text, no image
library needed. Wood stays VECTOR (unlike marble): its figure is a small number
of coherent, describable curves, which is exactly what vector authoring is good
at. Marble's figure is stochastic and multi-scale, which is why only marble
needed a raster.

ALGORITHM
* Squares: roughly-vertical bezier grain lines, plus one "cathedral" cluster --
  the nested-arch signature of flat-sawn timber. Line positions, widths and
  opacities are drawn from a seeded RNG so each variant differs.
* Band: grain as nested rounded rectangles, i.e. CONCENTRIC to the frame. This
  follows the perimeter on all four sides and is robust to `label-border-ratio`
  changes, whereas a mitred frame would only line up at one ratio. (Marble's
  band deliberately does the opposite -- slab-cut veins that traverse the ring
  -- because concentric veining read as a vignette, not stone. The construction
  must match how the material is actually worked.)

COLOR: monochrome by design -- black grain plus a white flank offset a couple of
units to one side. The overlay supplies shading; the theme supplies color. A
colored (brown/tan) overlay was tried and bakes in a hue that fights any theme
that is not brown; black/white is hue-preserving on every theme.

The grain is warped by feDisplacementMap. NOTE the `feColorMatrix` forcing alpha
to 1 before the map: without it, Typst's renderer (resvg) collapses the
premultiplied turbulence RGB to 0 where alpha is 0 and displaces the whole image
off-canvas. Keep the warp scale modest (<=9) or thin strokes fray.
"""

import random
import os

WARP = """    <filter id="warp" x="-25%%" y="-25%%" width="150%%" height="150%%">
      <feTurbulence type="fractalNoise" baseFrequency="%(bf)s" numOctaves="2" seed="%(s)d" result="raw"/>
      <feColorMatrix in="raw" type="matrix" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 0 1" result="n"/>
      <feDisplacementMap in="SourceGraphic" in2="n" scale="%(sc)s" xChannelSelector="R" yChannelSelector="G"/>
    </filter>
"""

TONE = """    <filter id="tone" x="0%%" y="0%%" width="100%%" height="100%%">
      <feTurbulence type="fractalNoise" baseFrequency="0.055 0.006" numOctaves="2" seed="%(s)d" result="n"/>
      <feColorMatrix in="n" type="matrix" values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  .34 .33 .33 0 0"/>
      <feComponentTransfer><feFuncA type="table" tableValues="0 %(a)s %(b)s %(c)s %(b)s %(a)s 0"/></feComponentTransfer>
    </filter>
"""

# name, seed, n_lines, width range, opacity range, flank gain, tonal alpha
SQUARES = [
    ("wood",        9, 12, (1.1, 2.9), (0.26, 0.52), 0.55, 0.17),  # dark squares
    ("wood_light", 41, 11, (1.0, 2.4), (0.14, 0.30), 0.40, 0.10),  # light squares
]
# 13 rings: enough figure to read as timber without striping ("ripple moulding")
BAND = ("wood_band", 17, 13, 1.2, (2.2, 5.6), (0.6, 2.2), (0.10, 0.28), 6)


def square_svg(seed, n, wrange, orange, flank_gain, tone_alpha):
    rnd = random.Random(seed)
    paths = []
    # cathedral cluster: nested arches, the flat-sawn signature
    cx, bulge = rnd.uniform(60, 140), rnd.uniform(28, 46)
    for k in range(rnd.randint(4, 6)):
        x = cx - k * rnd.uniform(7, 10)
        b = bulge - k * rnd.uniform(2, 4)
        paths.append((
            "M%.0f,-10 C%.0f,%.0f %.0f,%.0f %.0f,100 C%.0f,%.0f %.0f,%.0f %.0f,210"
            % (x, x, rnd.uniform(34, 48), x + b, rnd.uniform(70, 80), x + b,
               x + b, rnd.uniform(122, 130), x, rnd.uniform(152, 168), x),
            rnd.uniform(*wrange), rnd.uniform(*orange)))
    # straighter flanking grain.
    # NOTE: all x positions are drawn FIRST, then the per-line deltas. This RNG
    # consumption order is load-bearing -- it is what reproduces the artwork
    # that was visually approved. Inlining the x draw into the loop changes
    # every line's geometry.
    xs = [rnd.uniform(2, 198) for _ in range(n)]
    for x in xs:
        d1, d2 = rnd.uniform(-6, 6), rnd.uniform(-6, 6)
        paths.append((
            "M%.0f,-10 C%.0f,%.0f %.0f,%.0f %.0f,210"
            % (x, x + d1, rnd.uniform(45, 60),
               x + d2, rnd.uniform(140, 155), x + rnd.uniform(-3, 3)),
            rnd.uniform(*wrange), rnd.uniform(*orange)))

    def group(color, wf, of):
        return "".join(
            '    <path d="%s" stroke="%s" stroke-width="%.2f" stroke-opacity="%.3f"/>\n'
            % (d, color, w * wf, o * of) for d, w, o in paths)

    return ('<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200">\n'
            '  <!-- Monochrome: overlay carries shading, theme carries color. -->\n'
            '  <defs>\n'
            + WARP % dict(bf="0.005 0.004", s=seed % 90 + 1, sc=9)
            + TONE % dict(s=(seed * 7) % 90 + 1, a="%.2f" % (tone_alpha * .30),
                          b="%.2f" % (tone_alpha * .70), c="%.2f" % tone_alpha)
            + '  </defs>\n'
              '  <rect width="200" height="200" filter="url(#tone)"/>\n'
              '  <g filter="url(#warp)" fill="none" transform="translate(2.4,0)">\n'
            + group("#ffffff", 0.9, flank_gain)
            + '  </g>\n  <g filter="url(#warp)" fill="none">\n'
            + group("#000000", 1.0, 1.0)
            + '  </g>\n</svg>\n')


def band_svg(seed, n, base, gap, wrange, orange, warp_scale):
    rnd = random.Random(seed)
    rings, inset = [], base
    for _ in range(n):
        rings.append((inset, rnd.uniform(*wrange), rnd.uniform(*orange)))
        inset += rnd.uniform(*gap)

    def rect(ins, w, o, color, dx=0.0):
        x = ins + dx
        side = 200 - 2 * x
        if side <= 4:
            return ""
        return ('    <rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" rx="%.1f" '
                'stroke="%s" stroke-width="%.2f" stroke-opacity="%.3f"/>\n'
                % (x, x, side, side, max(2.0, x * 0.5), color, w, o))

    return ('<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200">\n'
            '  <!-- Grain CONCENTRIC to the frame: follows the perimeter on all\n'
            '       four sides and survives any label-border-ratio (a mitred\n'
            '       frame would line up at exactly one ratio). -->\n'
            '  <defs>\n'
            + WARP % dict(bf="0.010 0.011", s=13, sc=warp_scale)
            + '  </defs>\n  <g filter="url(#warp)" fill="none">\n'
            + "".join(rect(i, w * .85, o * .45, "#ffffff", 1.5) for i, w, o in rings)
            + '  </g>\n  <g filter="url(#warp)" fill="none">\n'
            + "".join(rect(i, w, o, "#000000") for i, w, o in rings)
            + '  </g>\n</svg>\n')


def main(outdir):
    os.makedirs(outdir, exist_ok=True)
    for name, seed, n, wr, orr, fg, ta in SQUARES:
        svg = square_svg(seed, n, wr, orr, fg, ta)
        path = os.path.join(outdir, name + ".svg")
        open(path, "w", encoding="utf-8").write(svg)
        print("%-12s %7d bytes" % (name, os.path.getsize(path)))
    name, seed, n, base, gap, wr, orr, warp = BAND
    path = os.path.join(outdir, name + ".svg")
    open(path, "w", encoding="utf-8").write(band_svg(seed, n, base, gap, wr, orr, warp))
    print("%-12s %7d bytes" % (name, os.path.getsize(path)))


if __name__ == "__main__":
    import sys
    main(sys.argv[1] if len(sys.argv) > 1 else "src/assets/patterns")
