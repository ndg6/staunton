# Prompt 12 — revamping & extending board visualization: design discussion

> Status: **discussion only (no code).** Builds on
> `docs/prompt11_position_reshaping_discussion.md` (which made the *position
> model* geometry-aware). Scope of this note: the **renderer** — `src/board.typ`
> and the board-style fields in `src/style.typ`. Source:
> `prompts/prompt_12__revamp_board_code.txt`.

## Verdict

Prompt 11 taught the *position model* about geometry (`cols`/`rows`,
`coords.typ` parametrised by board size), but the **renderer never caught up**:
`src/board.typ` is still hard-wired to 8×8, and the geometry never even reaches
it because `_to-squares` (`lib.typ`) discards `cols`/`rows`. So item 1 (non-
standard boards) is the **foundational refactor**; items 2–5 (labels,
highlights, arrows, PGN) layer on top and are largely additive style fields.

Recommended sequencing: **(1) geometry refactor → (2) labeling → (3) highlights
→ (4) arrows**, each landing with its own tests so we can eyeball PNG output
between stages rather than one big bang.

## Resolved decisions (this session)

- **Non-square board sizing:** `size` is the **larger dimension** of the
  bounding box; cells stay square. Effectively `sq = size / max(cols, rows)`,
  board = `cols·sq × rows·sq`.
- **Cross "beveled ends":** Typst stroke caps are `butt | round | square` (there
  is no true *bevel* cap — bevel is a *join*). Use **`round`** caps.
- **Highlight transparency:** a **separate** `highlight-transparency: 75%` field
  (not alpha baked into the color), composed onto `highlight-fill` by the
  renderer. Same composition feeds the arrow color.

## 1. Non-standard boards (item 1)

**The gap.** `src/board.typ` hard-codes 8 everywhere:
- `_screen()` flip uses `7 - col` / `7 - row` (board.typ:57–63);
- checker loops `range(8)`; `sq = s / 8` (board.typ:156, 162–163);
- label loops `range(8)`; rank labels assume `7` is the far edge.

And `_to-squares` (lib.typ:154–159) strips a position dict down to `.squares`,
throwing the geometry away before it can reach the renderer.

**Plan.**
- `render-board` gains `cols` / `rows` params (default 8 / 8 for back-compat).
- `board()` extracts `cols`/`rows` from a position dict; from a bare FEN string
  via `parse-fen`; from a raw squares dict it defaults to 8×8. `_to-squares`
  must return geometry alongside squares (or `board()` reads it before calling).
- `_screen(col, row, sq, orient, cols, rows)` → flip uses `(cols - 1 - col)` and
  `(rows - 1 - row)`.
- `sq = s / max(cols, rows)`; board = `cols·sq × rows·sq` (rectangular). This
  ripples into `_resolve-size`, the border band, and the gutters — all of which
  currently assume a square `s × s`.
- **Uneven columns** are already rejected by `_parse-position-string`
  (lib.typ:55–56, the rectangular assertion). Add a malformed test for it.

**Caveat (cosmetic, deferred):** `is-dark-square` still makes a1 dark on a 9×9
variant board. Fine for now; variant-specific coloring is out of scope.

## 2. Labeling (item 2)

**2a. Remove the auto-fallback.** Delete the on-square→border fallback
(board.typ:142–144) and the `_on-square-min-size` constant. On-square labels
keep the standard font size regardless of board resize. Retire the now-obsolete
test `tests/board/labeling/onsquare_fallback.typ`.

**2b. On-square corner placement (new option).** Today file labels are pinned
`align(left + bottom)` and ranks `align(right + top)` (board.typ:213, 219). The
prompt wants file = lower-left **or** lower-right, rank = upper-right **or**
upper-left (vertical fixed). New style fields:
- `file-label-corner: left | right`  (default `left`)
- `rank-label-corner: right | left`  (default `right`)

These are independent of `file-side` / `rank-side`, which choose which **edge**
carries the labels. New tests under `tests/board/labeling/`.

**2c. Border themes (new option).** `border-theme: "square" | "brown"`:
- `"square"` (default): band = `dark` square color, labels = `light` square
  color (today's behavior);
- `"brown"`: band = very-dark-brown, labels = creme-white.

Define the brown/creme constants in `style.typ`.

## 3. Highlights — cross & circle (item 3)

**Data-model change.** Today a highlight entry is `"e4"` or `("e4", letter)`,
always drawn filled (board.typ:175–181). Extend entries to also accept a **dict**
`(square: "e4", shape: "circle", color: ..)` with `shape ∈ {filled, cross,
circle}` defaulting to `filled`. Strings and 2-tuples keep working (→ filled).
Add a global default `highlight-shape`.

**Geometry.**
- circle: radius = `sq / 2`, centered;
- cross: centered, near-full both diagonals (almost-but-not-100% corner-to-
  corner), **round** caps.

**New style fields.**
- `highlight-shape` (default `"filled"`)
- `cross-color` (default red), `circle-color` (default green)
- `cross-width` / `circle-width` stroke (default `4pt` each)
- `highlight-fill` (RGB) + `highlight-transparency: 75%`

**Default change to note:** today's `highlight-fill = rgb(60,130,90,110)` is only
~57% transparent. The new default (75% transparency) makes filled highlights
visibly lighter.

## 4. Arrows (item 4)

- Add `arrow-width` (today shaft/head are fixed fractions of `sq` with no exposed
  control — board.typ:86–88). `arrow-width` sets the **shaft** width; the head
  stays proportional to `sq`.
- `arrow-color` default = the default `highlight-fill` color, at 75%
  transparency. Today arrow and highlight defaults are *different* greens; item 4
  unifies them.

## 5. PGN highlights (item 5)

Confirmed: the `%csl` / `%cal` annotation syntax (ChessBase/Lichess) encodes only
**colored squares** (`%csl`) and **colored arrows** (`%cal`) — there is **no**
circle/cross primitive. So `_pgn-annotations` (lib.typ:213–234) keeps producing
**filled-square** highlights, sharing the same fill/transparency options as
manual highlights. No change to the cross/circle path.

## Style-field summary

| field | default | note |
|---|---|---|
| `file-label-corner` | `left` | on-square file label corner (vertical fixed bottom) |
| `rank-label-corner` | `right` | on-square rank label corner (vertical fixed top) |
| `border-theme` | `"square"` | `"square"` (dark/light) or `"brown"` (dark-brown band, creme labels) |
| `highlight-shape` | `"filled"` | global default; per-entry dict override |
| `highlight-fill` | RGB green | paired with `highlight-transparency` |
| `highlight-transparency` | `75%` | composed onto fill (and arrow color) |
| `cross-color` / `circle-color` | red / green | |
| `cross-width` / `circle-width` | `4pt` / `4pt` | round caps; circle r = sq/2 |
| `arrow-color` | = highlight fill | at 75% transparency |
| `arrow-width` | (new) | shaft width; head scales off `sq` |

## Test impact

- **Retire:** `tests/board/labeling/onsquare_fallback.typ`.
- **Add:** 9×9 render test; uneven-columns malformed test (`tests/position/
  malformed/`); on-square corner-placement tests; border-theme tests.
- **Extend:** `tests/board/highlight/highlight.typ` (shapes, colors, widths,
  transparency); `tests/board/arrows/arrows.typ` (color, width, transparency).
- **Review:** existing labeling/size tests for 8×8 assumptions that the geometry
  refactor might shift.

## Open / deferred

- Variant-specific square coloring (a1 light on Xiangqi-style boards) — deferred.
- Whether `arrow-width` should scale the head too — currently **no** (head stays
  `sq`-proportional). Revisit if arrows look unbalanced at large widths.
