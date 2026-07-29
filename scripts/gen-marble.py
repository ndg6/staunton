#!/usr/bin/env python3
"""Generate staunton's marble material assets (prompt 47).

Requires Pillow only (no numpy): every step
is a whole-image C-level op, never a per-pixel Python loop.

ALGORITHM -- the classic procedural marble, which is a PERIODIC FUNCTION whose
argument is WARPED BY TURBULENCE:

    vein(x, y) = ridge( sawtooth(angle-rotated ramp) + amplitude * fbm(x, y) )

The turbulence term alone (what the old SVG `feTurbulence` assets had) produces
only formless noise; the periodic term is what makes it read as *veining*. That
missing term is the root cause the whole design round turned on.

Implementation notes that were learned the hard way -- change these at your peril:

* fBm must be LOW-FREQUENCY ONLY (octaves to 32 cells, not 128). High-frequency
  octaves make the phase vary pixel-to-pixel, which shatters veins into granite
  speckle.
* Ramp angles must be NON-ORTHOGONAL. Using 0/90 degrees crosses the layers into
  an obvious rectangular lattice, which reads as crazing, not stone.
* Each vein layer is multiplied by a second smooth noise ("fade mask") so veins
  fade in and out instead of running edge-to-edge at constant strength.

OUTPUT is a SHADING layer, not a colored texture: mode "LA", where L is constant
(255 = white veins for dark squares, 0 = black veins for light squares) and the
ALPHA channel carries vein strength. Because it carries no hue, it composites
correctly over ANY theme color -- the overlay supplies light, the theme supplies
color. This is what makes "works with arbitrary colors" a property of the design
rather than something fought with alpha reductions.
"""

from PIL import Image, ImageChops, ImageFilter
import random
import os

# --- tuned parameters (do not drift without re-eyeballing on green themes) ----

# (cycles, angle_deg, warp_amp, ridge_sharpness, gain)
# primaries -> secondaries -> capillaries; angles deliberately non-orthogonal.
VEIN_SPEC = [
    (1.3, 17, 165, 12, 1.00),
    (1.9, 71, 145, 17, 0.66),
    (2.6, 128, 130, 22, 0.42),
    (4.2, 44, 110, 30, 0.22),
]

FBM_OCTAVES = ((2, 1.0), (4, 0.55), (8, 0.30), (16, 0.15), (32, 0.07))

SQUARE_PX = 384   # squares render ~0.8cm; 384 is ample even on a 20cm board
BAND_PX = 768     # the band's visible ring is only ~6% of the image (see s9)

# name, seed, size, alpha strength, ink (255 = white veins, 0 = black veins)
ASSETS = [
    ("marble_dark1",  11, SQUARE_PX, 0.46, 255),
    ("marble_dark2",  67, SQUARE_PX, 0.46, 255),
    ("marble_light1", 53, SQUARE_PX, 0.26, 0),
    ("marble_light2", 101, SQUARE_PX, 0.26, 0),
    ("marble_band",   29, BAND_PX,   0.72, 255),
]


def fbm(size, seed, blur_div=256.0):
    """Fractal noise by upscaling small random images -- Pillow's BICUBIC resize
    interpolates, so a tiny random grid becomes smooth value noise. Summing
    octaves gives fBm. All C-speed; no per-pixel Python."""
    rnd = random.Random(seed)
    acc, wsum = None, 0.0
    for cells, weight in FBM_OCTAVES:
        small = Image.frombytes(
            "L", (cells, cells), bytes(rnd.randrange(256) for _ in range(cells * cells))
        )
        octave = small.resize((size, size), Image.BICUBIC)
        if acc is None:
            acc, wsum = octave, weight
        else:
            wsum += weight
            acc = Image.blend(acc, octave, weight / wsum)
    return acc.filter(ImageFilter.GaussianBlur(size / blur_div))


def ramp(size, angle):
    """A linear gradient rotated to `angle`. Built oversized then centre-cropped
    so the rotation's empty corners never enter the result."""
    big = int(size * 1.6)
    g = (Image.linear_gradient("L")
         .resize((big, big), Image.BILINEAR)
         .rotate(angle, resample=Image.BICUBIC))
    off = (big - size) // 2
    return g.crop((off, off, off + size, off + size))


def vein_layer(size, seed, cycles, angle, amp, sharpness):
    """One family of veins: sawtooth phase, warped by fBm, ridged by a LUT."""
    saw = ramp(size, angle).point(lambda i: int(i * cycles) % 256)
    turb = fbm(size, seed).point(lambda i: int(i * amp / 100.0) % 256)
    # add_modulo (not add) so the phase WRAPS instead of clipping
    arg = ImageChops.add_modulo(saw, turb)
    # bright thin ridge at mid-phase; higher sharpness => thinner vein
    lut = [int(255 * (max(0.0, 1.0 - abs(i / 255.0 - 0.5) * 2)) ** sharpness)
           for i in range(256)]
    veins = arg.point(lut)
    fade = fbm(size, seed + 977, blur_div=128.0).point(
        lambda i: min(255, int((i / 255.0) ** 1.5 * 340))
    )
    return ImageChops.multiply(veins, fade)


def marble(size, seed):
    acc = Image.new("L", (size, size), 0)
    for cycles, angle, amp, sharpness, gain in VEIN_SPEC:
        layer = vein_layer(size, seed + int(cycles * 13 + angle),
                           cycles, angle, amp, sharpness)
        if gain != 1.0:
            layer = layer.point(lambda i, g=gain: min(255, int(i * g)))
        acc = ImageChops.lighter(acc, layer)   # veins union, they don't sum
    return acc.filter(ImageFilter.GaussianBlur(0.5))


def main(outdir):
    os.makedirs(outdir, exist_ok=True)
    for name, seed, size, strength, ink in ASSETS:
        alpha = marble(size, seed).point(lambda i, s=strength: int(i * s))
        img = Image.merge("LA", (Image.new("L", (size, size), ink), alpha))
        path = os.path.join(outdir, name + ".png")
        img.save(path, optimize=True)
        print("%-18s %4d px  %7d bytes" % (name, size, os.path.getsize(path)))


if __name__ == "__main__":
    import sys
    main(sys.argv[1] if len(sys.argv) > 1 else "src/assets/patterns")
