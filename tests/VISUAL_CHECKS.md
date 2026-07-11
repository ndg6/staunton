# Visual checks before a release

Most tests **assert** — a wrong result fails `tests/run.sh` automatically. But a
handful only **render**: the runner just confirms they *compile*, so a drawing
that is wrong-but-valid (e.g. a highlight on the wrong square) passes silently.
This list is the manual eyeball pass for those sheets.

First render everything (expected-pass tests write their PDF, mirrored under
`tests/out/`). Use `--system-fonts`: the default run passes `--ignore-system-fonts`
for speed, which draws these sheets with fallback fonts — the eyeball pass needs
the real ones:

```sh
bash tests/run.sh --system-fonts
```

Then open the PDFs below and check the noted property. (The expected-*fail* tests
— the `// EXPECT:` ones — need no visual review; their error message is asserted.)

## Board drawing

- [ ] `board/highlight/highlight.pdf` — each **cross** is a complete X confined to
      its own square (both diagonals overlap), the round-cap tips ~10% from the
      corners (a short "×", not a full-diagonal line); each
      **circle** sits just inside its square border (small ~3% margin — it no
      longer touches the border) without spilling; filled squares sit under the
      pieces. Strokes are ~15% of the square. The **Proportional strokes** section
      shows a circle+cross+arrow at 2/4/6 cm squares — the marks should read the
      **same weight** at every size (not heavy when small / thin when large); the
      overrides row shows a fat `20%` cross and a fixed `1pt` circle.
      *(This sheet hid a cross-on-the-wrong-square bug that compiled green.)*
- [ ] `board/arrows/arrows.pdf` — arrows run centre-to-centre, scale with the
      board (shaft ~15% of the square), and flip with it; colors/widths as labelled.
- [ ] `board/labeling/label_modes.pdf`, `border_themes.pdf`, `onsquare_corners.pdf`,
      `onsquare_fullwidth.pdf` — files/ranks in the right gutter/corner, themed
      bands correct, labels legible and not clashing with pieces.
- [ ] `board/orientation/flip.pdf` — a1 in the correct corner both ways; labels
      flip with the board. Second section: the highlights (filled e4 / circle e5 /
      cross d5) stay on their named squares (mirrored screen position), and the
      arrows flip too — the blue `e2→e4` arrow points **up** by default and **down**
      when flipped (tip always at e4), and `f3→e5` / `c4→f7` keep their tips at
      e5 / f7 in both orientations.
- [ ] `board/size/sizes.pdf` — cells stay square at every size; nothing clipped.
- [ ] `board/grid/grid.pdf` — 1pt grid lines sit between squares at every size.
- [ ] `board/colors/colors.pdf` — light/dark themes render as intended.
- [ ] `board/piece_sets/existing/all_piece_sets.pdf`, `custom_user_set.pdf`,
      `unicode_fallback.pdf` — every piece glyph present, centred, correct color
      (including the Unicode glyph fallback).
- [ ] `board/piece_sets/existing/loader_function.pdf`,
      `loader_bytes_dict.pdf`, `loader_settable_default.pdf` — pieces render from a
      user-supplied loader (a function; a bytes dictionary; and a `svg-piece-set`
      loader set once as the document default across two boards): all pieces
      present, centred, sized like the bundled sets. (All three self-assert the
      image count, so a dropped piece fails the run; the eyeball is only for
      sizing/centring.)
- [ ] `board/piece_sets/fairy/mixed_board.pdf` — a mixed fairy board: standard
      king/pawn (from cburnett via `with-fallback`) sit alongside the three fairy
      pieces **alfil** (a1, white), **dabbaba** (d4, black) and **ferz** (f6,
      white). Check each fairy glyph is the right piece, the right color, centred
      and sized like the standard ones. (The sheet self-asserts that all 6 pieces
      render, so a dropped piece fails the run; the eyeball is glyph identity,
      color and sizing.)
- [ ] `board/piece_sets/fairy/glyph_fallback.pdf` — the user-supplied glyph
      fallback: the fairy **alfil** on a1 draws the variant's glyph (`✶`), while the
      standard king on e1 still uses the built-in glyph. Check the `✶` shows on a1
      (font-dependent) and the king renders normally. (The sheet self-asserts glyph
      *precedence* at the unit level and that the render compiles; the eyeball is
      that the custom glyph actually appears and is placed/sized sanely.)
- [ ] `board/piece_sets/fairy/highlights.pdf` — highlights work on a fairy board:
      the **filled** squares (a1 alfil, e1 king) sit *under* their pieces, the
      **circle** rings the dabbaba on d4 without spilling, and the **cross** marks
      the empty f5. (Self-asserts the 4 pieces render; the eyeball is that each
      highlight lands on the right square and layers correctly with custom pieces.)
- [ ] `board/geometry/nonstandard_boards.pdf` — non-8×8 geometry looks sane.
- [ ] `board/markings/markings.pdf` (prompt 27/28) —
      *In-check glow*: a **Lichess-style** red radial that fills most of the square
      — solid near the centre and reaching the **edge midpoints**, with only the four
      **corners** left showing the bare square color — sits **under** the king on
      the checked square, which stays crisp **on top** (the glow must NOT vanish
      under the piece). Present on both the Black-in-check and White-in-check boards; the
      "default" board (no `check:`) shows **no** glow; the custom-color board glows
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
- [ ] `board/style_options/defaults_walkthrough.pdf` — a systematic gallery of the
      *settable* `set-board-defaults(..)` options: each printed call (left) must match
      the board (right), all differing from the top *baseline* in exactly the one
      printed option. Spot-check each group takes effect document-wide: the green
      theme, the label modes/sides/corners, the border themes/outline, the grid, the
      merida set and 0.7 piece-scale, the check glow (blue, and the forced-`e1` one),
      and the Unicode glyph fallback. Note the **highlight/arrow *styling*** sections:
      the fill/circle/cross colors and the teal arrow are set as *defaults*, while the
      `highlight:` / `arrows:` **list** is passed **per call** (it is per-call only).
      The **move-quality** section uses `diagram-after` (not a bare board): with
      `move-quality: true` set as a default the badge is a red `??` disc on c6, then
      recolored fuchsia by `set-board-defaults(move-quality-colors: ..)`, then a `!`
      badge on f7 combined with the auto-located mate glow.

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
      outline entries, and cross-references resolve. Caption wording (0.2.2): a FEN
      diagram reads "White to move" / "Black to move" (no move number); a
      `diagram-after` reads "Position after 24. Nf3" / "Position after 24... Nf6".
      In particular for the
      automatic year: the dated PGN diagram shows "Morphy – Allies (1858)"; the
      no-Date PGN diagram shows "Morphy – Allies" with *no* "(year)"; and the
      manual `year: 2024` override shows "(2024)", not the roster's 1858.
- [ ] `tournament/standings.pdf`, `crosstable_progress.pdf`,
      `realworld_standings.pdf`, `refs/table_refs.pdf` — columns aligned, headers
      and running totals correct, tie-breaks plausible.
- [ ] `i18n/i18n.pdf` — supplements and piece letters match each language.
- [ ] `i18n/localized_captions.pdf` — **verify the translations** of the automatic
      diagram captions ("Position after …" for PGN / "White to move" · "Black to
      move" for FEN) and the tournament-table column headers (rank, player/team, played, points,
      round) for each language. en/de are asserted in code; **es / fr / it / pt / ru
      were proposed by Claude and need a native/expert eye** — check wording,
      grammar, and the short column abbreviations. (Tie-break labels Bh/SB/BP are
      left in their internationally standard form on purpose.)
- [ ] `pgn/good/variation_move.pdf` — the two boards show the correct one-step and
      nested variation positions (side by side).
- [ ] `pgn/chess960/frc_game.pdf` — the Chess960 start board (king on the f-file,
      knights on a/g, bishops on c/d, rooks on b/h) draws correctly, and the
      diagram after `2.O-O O-O` shows **both** kings on g-files with their rooks on
      the f-files (the 960 castling landed king→g / rook→f, not the standard e→g).
- [ ] `pgn/chess960/scharnagl_xfen.pdf` — the diagram (before 11.O-O) shows White
      with rooks on **g1 and h1**, king on **e1**; Black king/rooks on e8/g8 (h-side)
      as in the caption. (The `Gkq` field itself is asserted; this is just the board.)

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
      - *The Board → Piece Sets and Fonts → Using your own downloaded piece set*:
        the new subsection reads cleanly — the `piece-loader` code block is not
        clipped or overflowing, and the lichess link renders.
      - *Games → Drawing Annotations in PGNs*: the new combined example shows the
        PGN's green `f3→e5` arrow and red `e5` highlight **together with** a
        programmatic `b1→c3` arrow and a circle on `d4` on one board.
- [ ] `docs/manual.pdf` — the new *Chess960 / Fischer Random* chapter (after *Games*):
      - *Boards and start positions*: `chess960-diagram(chess960-start(356))` draws a
        valid non-standard back rank (bishops on opposite colors, king between the rooks).
      - *X-FEN castling*: the `to-fen(frc, "10b")` output line reads
        `…/2BNK1RR w Gkq - 4 11` (the `Gkq`, not `KQkq`).
      - *Games*: `game-variant(frc)` prints `chess960`; the `diagram-after(frc, "11w")`
        board shows the white king on g1 and a rook on f1 (with the other rook still on h1).
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
      the `User manual · package version 0.2.2` line.
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
- [ ] `docs/manual.pdf` front-matter figure lists — right after the **Contents**,
      the manual dogfoods the figure outlines: a **List of Diagrams** then a **List
      of Tables**, both flowing on the **same page** (no page break between them, no
      part-style banner or divider rule). Their titles are centered 15pt bold,
      **matching the "Contents" title** above. Confirm there are **no blank/empty-
      caption rows** — only captioned figures are listed, so the Diagram numbers
      legitimately skip the caption-less ones (1, 2, 3, 6, 7, 9, 10, 12, 13). The
      three tables read *Final standings*, *Round-robin cross-table*, *Round-by-round
      progress*. Entries use the default outline look (regular weight), **not** the
      bold chapter-TOC styling.
- [ ] showcase — `typst compile --root . docs/examples/showcase.typ showcase.pdf`,
      then skim it.
- [ ] HTML export — `typst compile --root . --features html --format html
      docs/examples/html_export.typ html_export.html`, then open it in a browser:
      the boards/diagrams render (as inline SVG), the standings table and the
      diagram outline show, and the "See Diagram 1" link jumps to the figure.
      (The presence of these elements is asserted by
      `tests/output_formats/html/`; this check is about them actually *rendering*
      in a browser.)
