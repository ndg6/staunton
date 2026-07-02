# Visual checks before a release

Most tests **assert** — a wrong result fails `tests/run.sh` automatically. But a
handful only **render**: the runner just confirms they *compile*, so a drawing
that is wrong-but-valid (e.g. a highlight on the wrong square) passes silently.
This list is the manual eyeball pass for those sheets.

First render everything (expected-pass tests write their PDF, mirrored under
`tests/out/`):

```sh
bash tests/run.sh
```

Then open the PDFs below and check the noted property. (The expected-*fail* tests
— the `// EXPECT:` ones — need no visual review; their error message is asserted.)

## Board drawing

- [ ] `board/highlight/highlight.pdf` — each **cross** is a complete X confined to
      its own square (both diagonals overlap); each **circle**'s outer edge touches
      its square border without spilling; filled squares sit under the pieces.
      *(This sheet hid a cross-on-the-wrong-square bug that compiled green.)*
- [ ] `board/arrows/arrows.pdf` — arrows run centre-to-centre, scale with the
      board, and flip with it; colours/widths as labelled.
- [ ] `board/labeling/label_modes.pdf`, `border_themes.pdf`, `onsquare_corners.pdf`,
      `onsquare_fullwidth.pdf` — files/ranks in the right gutter/corner, themed
      bands correct, labels legible and not clashing with pieces.
- [ ] `board/orientation/flip.pdf` — a1 in the correct corner both ways; labels
      and any marks flip with the board.
- [ ] `board/size/sizes.pdf` — cells stay square at every size; nothing clipped.
- [ ] `board/grid/grid.pdf` — 1pt grid lines sit between squares at every size.
- [ ] `board/colors/colors.pdf` — light/dark themes render as intended.
- [ ] `board/piece_sets/existing/all_piece_sets.pdf`, `custom_user_set.pdf`,
      `unicode_fallback.pdf` — every piece glyph present, centred, correct colour
      (including the Unicode glyph fallback).
- [ ] `board/geometry/nonstandard_boards.pdf` — non-8×8 geometry looks sane.

## Diagrams, notation, tables

- [ ] `notation/embed_diagrams.pdf` — boards are spliced at the markers; with
      annotations on, each spliced board carries that move's arrows/highlights.
- [ ] `notation/notation.pdf` — figurines, localized piece letters, NAG glyphs,
      and `from`/`to` slices read correctly.
- [ ] `pgn/realworld/two_knights_variations.pdf` — inline variations numbered
      correctly; the *block* rendering parenthesises and indents each variation by
      nesting depth (a variation ending on a nested line closes with `)` alone).
- [ ] `diagram/auto_captions/auto_captions.pdf`, `free_captions/free_captions.pdf`,
      `outlines/outline.pdf`, `refs/diagram_refs.pdf` — game-info line, captions,
      outline entries, and cross-references resolve.
- [ ] `tournament/standings.pdf`, `crosstable_progress.pdf`,
      `realworld_standings.pdf`, `refs/table_refs.pdf` — columns aligned, headers
      and running totals correct, tie-breaks plausible.
- [ ] `i18n/i18n.pdf` — supplements and piece letters match each language.
- [ ] `pgn/good/variation_move.pdf`, `nested_variation.pdf` — the board shows the
      correct (nested) variation position.

## The showcase and the manual

These are not under `tests/out/`; build them separately.

- [ ] `docs/manual.pdf` — every framed example's board matches its code (rebuild:
      `typst compile --root . docs/manual.typ docs/manual.pdf`).
- [ ] showcase — `typst compile --root . docs/examples/showcase.typ showcase.pdf`,
      then skim it.
