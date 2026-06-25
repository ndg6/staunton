# Prompt 8 — further board & diagram improvements: design

> Status: **implemented; suite green (39 cases).** Source:
> `prompts/prompt_8__further_board_diagram_improvs.txt`. The prompt numbered two
> items "6" (a typo the user fixed); the PGN one is **item 8** here. All items 1–8
> are built with tests; `src/style.typ`, `src/board.typ`, `src/game.typ` and
> `lib.typ` changed, with new tests under `tests/board/{grid,arrows,highlight,
> style_options}` and `tests/pgn/annotations`, plus README updates.

## Two findings that shrink the work

- **PGN comments are already preserved** by the parser (`comment-before` /
  `comment-after` per move node) and `move-san` already walks the tree to the
  addressed node. Item 8 needs no tokenizer change — just a `move-node` sibling
  and a small `%cal` / `%csl` parser.
- **Items 4 and 7 are largely already implemented.** `_game-info-line` already
  requires both player names with the year optional, and omits the above-slot
  entirely when names are absent; `highlight-fill` is already a settable style
  key. Those two items are confirm-and-extend, not build-from-scratch.

## Decisions (resolved)

1. **(5a)** Keep `set-chess-defaults` as a **back-compat umbrella** that routes
   each key to the board or diagram bucket, *in addition to* the two explicit
   setters `set-board-defaults` / `set-diagram-defaults`. Existing tests and user
   code keep working.
2. **(8a)** PGN annotation colors are a **stylable map**
   (`annotation-colors: (G: …, R: …, Y: …, B: …, O: …)`), so a document can
   re-theme `%cal` / `%csl` without editing the PGN.
3. **(8b)** PGN annotations are **auto-applied** by `board-after` (toggle
   `pgn-annotations: true`, default on); they merge with any explicitly passed
   `arrows` / `highlight`.
4. **(6a)** Arrows are **straight** for v1 (bent knight arrows deferred).
5. **(2a)** Grid line is **fixed 1pt black** for v1 (a settable `grid-stroke`
   can come later).

---

## 1) On-square label tweaks — `board.typ`, `pieces.typ` (small)

- Raise `_on-square-pad-frac` (was `0.02`) and shrink `_on-square-label-frac`
  (`0.26 → 0.22`). The "g too low" symptom is the descender against a
  bottom-aligned label; a larger bottom inset lifts the glyph.
- Shrink pieces: `piece-scale` default `1.0 → 0.95`. Applies in all modes (95% is
  subtle); motivated by on-square collisions.
- Tests: visual only (`label_modes`, `onsquare_fallback`) — regenerate & eyeball.
- Other label modes unchanged (per prompt).

## 2) Grid line — `board.typ` + board-style key (small)

- New board-style key `grid: false` (default). When true, 1pt **black** lines on
  the internal square boundaries, **fixed 1pt at every size**, drawn over the
  squares and under the pieces.
- Test: `tests/board/grid/` (on/off at a couple of sizes) + assert `grid`
  defaults to `false`.

## 3) Border-mode color + separator — `board.typ` (small, no test per prompt)

- Revert `band-fill` from `st.dark.darken(18%)` back to `st.dark`.
- Always draw a **thin (1pt) black** line between the band and the board, inside
  the band, independent of the optional `border` outline.

## 4) Auto-label above — `lib.typ` (tiny)

- Behaviour (both-names-required, year optional, no space when absent) is already
  correct. The change is to render the **auto line bold** — controlled by the new
  diagram-style option `info-bold: true` (item 5). A user-supplied `game-info:`
  keeps its own formatting (not force-bolded).

## 5) Split board vs diagram styling — `style.typ`, `lib.typ`, tests (foundational)

- `default-board-style` — all current style keys (colors, labels, label-mode,
  file-side/rank-side, border, piece-set, piece-scale, baseline-inset,
  label-color, label-border-ratio, white/black-fill, piece-font, highlight,
  highlight-fill, **grid**, **arrows**, **arrow-color**, **annotation-colors**).
- `default-diagram-style` — new, thin: `info-bold: true`, `info-gap: 0.6em`,
  `supplement: [Diagram]`.
- State + setters: `board-style-state` / `diagram-style-state`;
  `set-board-defaults(..)` / `set-diagram-defaults(..)`; `set-chess-defaults(..)`
  remains as an umbrella routing each key to the right bucket (asserting unknown
  keys, still rejecting `flip`).
- `board()` merges board-style; `chess-diagram()` merges diagram-style and
  forwards board overrides to `board()`. `_split-args` routes **three** ways now:
  board overrides / diagram overrides / figure args.
- Key sets: `board-style-keys`, `diagram-style-keys` (replacing `style-keys`;
  keep `style-keys = board-style-keys + diagram-style-keys` for back-compat).
- Test impact: `direct_style.typ` (asserts on `default-style` / `style-keys`)
  and `inheritance.typ` adapt; add coverage for the two new setters and the
  three-way split.

## 6) Arrows — `board.typ` + board-style keys (largest new rendering)

- `arrows: ()` board-style key. Each item is flexible like `position()`:
  `(from: "f3", to: "e5", color: <c>)` or a tuple `("f3","e5")` /
  `("f3","e5", red)`. Missing color → settable `arrow-color` default.
- Rendering: hand-rolled (no external dep) — a square-scaled shaft plus a filled
  triangle head; angle from the from/to screen centres; routed through `_screen`
  so arrows flip with the board. Drawn over pieces.
- Test: `tests/board/arrows/` (visual + style-key assertion).

## 7) Highlight color settable — coverage only

- `highlight-fill` is already settable. Add `tests/board/highlight/`:
  document-default via `set-board-defaults` + per-call override.

## 8) PGN `%cal` / `%csl` — `game.typ`, parser, `lib.typ` (feasible)

- Add `move-node(game, locator)` (twin of `move-san`) returning the addressed
  node, so `board-after` can read its `comment-after`.
- Parse `[%cal Gf3e5,Bc6e5]` → arrows; `[%csl Re5,Yc6]` → highlights. A leading
  colour letter, then `from`+`to` (cal) or one square (csl), comma-separated.
- Colours resolve through `annotation-colors` (decision 8a). Auto-applied by
  `board-after` when `pgn-annotations` is on (8b), merged with explicit
  `arrows` / `highlight`.
- Tests: `tests/pgn/annotations/` — a game with `{[%cal …]}` / `{[%csl …]}`
  rendered, plus a parser-level assertion.

## Sequencing

**5** (foundation) → **1–4** (board/diagram tweaks) → **6 + 7** (arrows +
highlight) → **8** (PGN annotations; depends on 6/7 rendering + the colour map).
Each step lands with its tests per CLAUDE.md; the suite stays green between
steps.
