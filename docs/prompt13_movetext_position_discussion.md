# Prompt 13 — move text → position, and an API streamline

> Status: **implemented** (standard chess). See "Implementation outcome" at the
> end for what shipped and the one deviation from the plan. Source:
> `prompts/prompt_13__amending_pos_creation.txt` plus the follow-up: drop the
> `variant:` parameter, hunt redundancy, and make the high-level API
> **variant-forward** (`chess-*`, `xiangqi-*`, `shatar-*`, …).

## Verdict

Two things at once:

1. **Add `play-moves(source, moves)`** — apply a run of moves *as text* to a
   position and get the resulting (renderable) position. The engine fold already
   exists (`line` in `game.typ`); this is the ergonomic, variant-aware front
   door.
2. **Streamline the surface** around it: variant flows from data (no `variant:`
   param), retire dead aliases, collapse the `line`/`play-moves` overlap, unify
   the FEN door, and reframe the high-level entry points as a **variant family**.

## Decisions (this session)

- **Variant flows from the position, never as a verb parameter.** The engine
  dispatches on `position.variant`; the "standard-only (for now)" limit lives in
  the engine, so `play-moves` never needs a `variant:` arg and won't change
  signature as variants gain rules.
- **`play-moves(source, moves)` returns the FINAL position.** Retire `line`
  (its only real use, `line(...).last()`, *is* `play-moves`). The
  all-intermediate-positions case is deferred until a concrete need (animation)
  appears.
- **Generic `board` / `diagram` stay public** as the variant-agnostic
  primitives; the variant-named functions are thin sugar over them.
- **`position()` auto-detects a FEN string** and delegates to `parse-fen`, so
  `position(fen)`, `board(fen)`, and `play-moves(fen, …)` are consistent.
  `parse-fen` remains the explicit FEN door.
- **Movetext richness:** flat SAN + optional move numbers (`3.`/`3...`) +
  optional trailing result; comments/NAGs/variations → error (use `parse-pgn`).

## Redundancy audit (what we're cleaning up)

| Overlap (before) | Resolution |
|---|---|
| `chess-board` **=** `board`, `fen-diagram` **=** `chess-diagram` (pure aliases) | `fen-diagram` retired; `chess-board`/`chess-diagram` become the **standard-variant** entries (real meaning, not aliases) |
| `line(start, moves)` (all positions) vs `play-moves` (final) | keep **`play-moves`** only |
| `parse-fen` / `position` / `board` all take a FEN-ish thing differently; `position("…fen…")` wrongly reads FEN as board rows | `position()` **auto-detects** FEN → `parse-fen`; all three consistent |
| 5 render names (`board`, `chess-board`, `chess-diagram`, `fen-diagram`, `board-after`) for ~3 behaviours | generic `board`/`diagram` + variant family + `board-after` |

## Target API

### Creation (model layer, engine-free)
- **`position(...)`** — canonical constructor (squares dict / string rows /
  **FEN string, auto-detected**); carries `variant` / `cols` / `rows`.
- **`parse-fen(fen)`** — explicit FEN door (what `position` delegates to).

### Moves (engine layer)
- **`play-moves(source, moves)`** — `source`: `none` (→ that entry's start) |
  FEN string | position. `moves`: move-text string / raw block / SAN array.
  Returns the **final** position. Variant from `source`; engine dispatches.
  Errors with ply+token context; an unsupported variant errors *in the engine*.
- **`play-san(pos, san)`** — single-move primitive, kept (used internally; handy
  for advanced callers). `line` is **removed**.

### Rendering (presentation layer)
- **`board(source, ..)`** — generic bare-board primitive (variant-agnostic;
  `source` carries the variant).
- **`diagram(source, ..)`** — generic `#figure` wrapper (this is today's
  `chess-diagram` body, renamed to the generic).
- **Variant family** (thin sugar, two lines each over a shared helper):
  - `chess-board` / `chess-diagram` → standard western chess (today's behaviour),
  - `xiangqi-board` / `xiangqi-diagram`, `shatar-board` / `shatar-diagram`, …
    as those variants land.
  Each binds `variant: V`: a *raw* source (FEN/squares/`none`) is interpreted in
  `V`; a *position* source must already be `V` (asserted, to catch
  `chess-board(a-xiangqi-position)`).
- **`board-after(game, locator, ..)`** — PGN/game navigation, unchanged.
- **`fen-diagram`** — retired.

```typ
// all equivalent ways in; variant is explicit in the name or carried by data
#chess-diagram(play-moves(
  "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3",
  "Bb5 a6 Ba4 Nf6"))
#chess-board(play-moves(none, "1. e4 e5 2. Nf3 Nc6"))   // none = standard start
```

## The honest caveat on variants

A *real* `xiangqi-board` is more than a label: it needs a different **renderer**
(9×10 grid, pieces on line *intersections*, river/palace), **engine** rules, and
a **registry** entry (`src/variants.typ` already reserves the xiangqi spec in a
comment). What this prompt delivers **now**:

- `chess-*` works end-to-end;
- the **variant seam** is established — naming, `position.variant` plumbing,
  engine dispatch, and the two-line wrapper pattern — so `xiangqi-*` / `shatar-*`
  slot in when their spec + renderer + engine exist.

We will **not** ship a `xiangqi-board` that silently draws a western 9×10
checkerboard. Variant-named functions appear only when their variant is real.

## Migration (small)

- `examples/showcase.typ:88` — `line(starting-fen, (…)).last()` →
  `play-moves(starting-fen, (…))` (or the move-text string). Drops `.last()`;
  literally demonstrates the redundancy we removed.
- `tests/position/good/object_shape.typ` — the `chess-board == board` assertion
  becomes false (it's now standard-variant sugar). Replace with a check that
  `chess-board` yields a standard position / matches `board` output for a
  standard source.
- `fen-diagram` — no usages in tests/examples; safe to retire.
- Re-export map in `lib.typ` updated (`line` out; `play-moves`, `diagram`,
  `chess-board`, `chess-diagram` in).

## Test plan

- **Ruy Lopez (prompt example):** `play-moves(fen, "Bb5 a6 Ba4 Nf6")` — assert
  `.squares`/turn/fullmove/castling equal the target FEN.
- **`none` → start** with `"1. e4 e5 2. Nf3 Nc6"` — equals the Ruy Lopez start.
- **Move-number tolerance & array form** yield identical positions.
- **`position(fen)` auto-detect** equals `parse-fen(fen)`.
- **Variant-name sugar:** `chess-diagram`/`chess-board` render a standard source;
  passing a (hypothetical) non-standard position to `chess-board` errors.
- **Errors (EXPECT):** illegal move (with ply/token context); a
  comment/variation in the text; an engine-unsupported variant.
- **Render sheet** building a position via `play-moves` and drawing it.

## Open / deferred

- Position→FEN exporter (`to-fen`) — still absent; not needed for rendering, flag
  only.
- All-intermediate-positions helper (the old `line`) — re-add only on real need.
- Variant renderers/engines (xiangqi, shatar, …) — future prompts.

## Implementation outcome

Shipped exactly as designed, with one deviation:

- **`play-moves(source, moves)`** in `src/san.typ` (beside `play-san`), with a
  private `_split-movetext` (move-number/result stripping; rejects
  comments/NAGs/variations). Re-exported from `lib.typ`.
- **Variant guard lives in the engine:** `legal-moves` asserts
  `position.variant == "standard"` (defaulting absent to standard), so *any*
  move analysis — `play-moves`, `play-san`, `san-to-move`, `board-after` — is
  covered, and `play-moves` carries no `variant` parameter.
- **`position()` auto-detects FEN** (a single string/raw positional containing
  `/`) → `parse-fen`. The row form never uses `/`, so no clash.
- **Rendering family:** generic `board` / `diagram` (variant-agnostic) +
  standard sugar `chess-board` / `chess-diagram` (assert a position source is
  `"standard"`). `fen-diagram` retired; `line` removed.
- **Migration:** `showcase.typ` now uses `play-moves` (dropped `.last()`);
  `object_shape.typ` lost the `chess-board == board` assertion.
- **Tests:** `tests/position/good/play_moves.typ` (Ruy Lopez vs target FEN,
  `none`→start, move-number tolerance, array form, `position(fen)` auto-detect)
  plus three EXPECT-error tests (illegal move, comment/variation, non-standard
  variant). Suite: **51 pass / 0 fail**.

**Deviation — per-ply error context.** The plan promised errors like
`play-moves: move 4 "Nf6" — …`. Typst has no `try`/`catch`, so `play-moves`
cannot intercept `san-to-move`'s assertion to prepend the ply number. We rely on
`san-to-move`'s own message, which already names the offending token (e.g.
`illegal or unresolvable move "Qh6" for white`). Token-level context is present;
the ply index is not. Adding it would mean duplicating legality checks before
each call — not worth it.
