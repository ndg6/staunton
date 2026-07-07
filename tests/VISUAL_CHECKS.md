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
- [ ] `board/markings/markings.pdf` (prompt 27/28) —
      *In-check glow*: a **Lichess-style** red radial that fills most of the square
      — solid near the centre and reaching the **edge midpoints**, with only the four
      **corners** left showing the bare square colour — sits **under** the king on
      the checked square, which stays crisp **on top** (the glow must NOT vanish
      under the piece). Present on both the Black-in-check and White-in-check boards; the
      "default" board (no `check:`) shows **no** glow; the custom-colour board glows
      blue. The reference-play board (`3. Qh5#`) glows the Black king. The glow stays
      roughly circular and does not bleed into neighbouring squares.
      *Move-quality badge* (all now sourced from a game): the six glyphs read as
      discs on each move's destination square, at the **upper-right**, pulled toward
      the piece's square — good `!`/`!!` blue, bad `?`/`??` red, interesting `!?`/`?!`
      green, white text, legible (incl. the two-char `!!`/`??`). Each disc sits on an
      **occupied** square, clears its piece, and spills slightly into the neighbours.
      On the a8 corner pair (`Nxa8!!`) the disc spills **above/right of the board**
      and stays screen-upper-right after `flip: true`.
      *Wired through a game*: the left diagram (mate `4.Qxf7#`) shows both the glow
      on the Black king **and** a blue `!` badge on f7; the right diagram shows a red
      `??` badge on f6. Badge and glow never overlap the wrong square.

## Diagrams, notation, tables

- [ ] `notation/embed_diagrams.pdf` — boards are spliced at the markers; with
      annotations on, each spliced board carries that move's arrows/highlights.
- [ ] `notation/notation.pdf` — figurines, localized piece letters, NAG glyphs,
      and `from`/`to` slices read correctly.
- [ ] `pgn/realworld/two_knights_variations.pdf` — inline variations numbered
      correctly; the *block* rendering parenthesises and indents each variation by
      nesting depth (a variation ending on a nested line closes with `)` alone).
- [ ] `notation/variations/variations.pdf` — `bold-mainline` now defaults **on**:
      in the two "with the document default" renders at the bottom, mainline moves
      read **bold** while moves inside variations stay normal weight.
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
- [ ] `docs/manual.pdf` — specific examples revised for the 0.1.0 findings pass:
      - *The Board → Flip*: two boards side by side, both with `"border"` labels and
        the `"brown"` theme (dark-brown band, creme labels). Left is normal
        orientation, right is `flip: true`; confirm `a1` moves from lower-left to
        upper-right so the coordinate flip is obvious.
      - *The Board → Labels*: the three `border-theme` looks read as described —
        `"square"` blends with the board, `"brown"` is dark-brown + creme, `"dark"`
        is charcoal + light-grey (only the `"brown"` one is rendered inline; the
        prose describes the others).
      - *The Board → Piece Sets and Fonts*: the sentence starting "The renderer
        accepts *any* set name…" no longer has stretched, widely-spaced words — the
        `piece_sets/<name>/…` path now sits on its own display-code line.
      - *Games → Drawing Annotations in PGNs*: the new combined example shows the
        PGN's green `f3→e5` arrow and red `e5` highlight **together with** a
        programmatic `b1→c3` arrow and a circle on `d4` on one board.
- [ ] `docs/manual.pdf` structure & cross-refs — the *Document-Wide Defaults* chapter
      (formerly "Document-Wide Style") covers the five default buckets; the canonical
      **PGN Handling** switch table now lives in the *Games* chapter, not the defaults
      chapter. The in-prose `see Section N.M` cross-refs (piece sets, annotations,
      outlines, board-options ↔ defaults, PGN handling) point to the right sections
      and read naturally.
- [ ] `docs/manual.pdf` API reference (`tidy`-generated) — the front-matter outline
      splits into two columns, **Guide** and **API Reference**. The reference part
      opens with the **Common Parameters** chapter (argument value shapes + option
      lists); the **Main functions** and **Behind the scenes** chapters render each
      function as a signature followed by a parameter list (type + default per
      parameter). The `tidy` output uses the manual's *compact* style: parameter
      blocks are lightly tinted (`#f0f0ec`, matching inline code) and the gap between
      successive functions is tight (~1.6em, not the stock 4.8em). Skim that the
      entries look well-formed (no empty descriptions, no stray raw-syntax leaking),
      the spacing reads evenly, the tidy-generated headings carry **no numbers**, and
      the curated grouping matches the section titles.
- [ ] `docs/manual.pdf` front matter — the **cover page** shows the hatched pencil
      pawns (`docs/img/pawns-duo.svg`: a white Staunton pawn in front, a black pawn
      diagonally behind-right) above the title block, with **no** header, footer or
      page number. Rugged graphite look; the two pieces read as clearly separated.
      Below the tagline sits the repo link `https://github.com/ndg6/staunton`, then
      the `User manual · package version 0.1.0` line.
      (`docs/img/cover-pawn.svg` is the single-pawn variant, kept as an alternate.)
- [ ] `docs/manual.pdf` running chrome — on every page *after* the cover: header
      shows `staunton` (left) and the current level-1 chapter title (right); footer
      shows the page position **centered** as `<current>/<total>` (e.g. `5/28`) with
      no copyright line. The **Table of Contents** page (page 2) has an **empty**
      header right side — the outline's own "Guide"/"API Reference" titles must not
      appear there. The first page after the cover is numbered **2** (pagination
      skips the cover). In **both** outline columns the level-1 (chapter) entries are
      **bold**, with a little extra space above each so a chapter groups with its
      indented level-2 children; level-2 entries stay regular weight.
- [ ] showcase — `typst compile --root . docs/examples/showcase.typ showcase.pdf`,
      then skim it.
- [ ] HTML export — `typst compile --root . --features html --format html
      docs/examples/html_export.typ html_export.html`, then open it in a browser:
      the boards/diagrams render (as inline SVG), the standings table and the
      diagram outline show, and the "See Diagram 1" link jumps to the figure.
      (The presence of these elements is asserted by
      `tests/output_formats/html/`; this check is about them actually *rendering*
      in a browser.)
