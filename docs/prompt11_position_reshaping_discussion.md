# Prompt 11 — reshaping the `position` object: design discussion

> Status: **discussion only (no code).** Builds on
> `docs/prompt10_mission_and_gap_analysis.md`. Scope of this note: the **board /
> position** layer — the data model for "which piece stands on which square."
> Source: `prompts/prompt_11__reshaping_board_code.md`. Visualization revamp is
> the next step and is only flagged here, not designed.

## Verdict

The proposed `position` with a `pieces` **array** is the right *authoring* form,
but it should **not** become the canonical *stored/runtime* form. Keep a
square-keyed **dict** as the internal model (what the engine and renderer read);
make `pieces`-array, FEN, and the new string form all **constructors** that
produce that one canonical object.

So `position.board` (the dict the engine uses) is **not** the wrong layout — it
is *incomplete* (no variant/geometry) and *too coupled to standard 8×8 chess*.
The real blocker for variants/geometry is **`coords.typ`**, not the position
object.

## 1. Array vs dict — different jobs, keep both

- An **array** of `(kind, color, square)` is great to *write* but a poor *store*:
  it permits duplicate squares, ordering is meaningless, and "what's on e4?" is
  O(n). The engine asks that constantly.
- A **dict** `square -> (kind, color)` dedupes by construction, is O(1), and is
  already what `apply` / `is-square-attacked` rely on (`engine.typ`).

Decision: `pieces:` is a constructor **input**, not a persisted field. If needed,
expose a `pieces(position)` accessor that *derives* the array from the dict —
never store both (they drift).

**Update (resolved, implemented):** the array-of-`(kind,color,square)` *input*
form was **removed** entirely — hand-input is now a **squares dict** (or the
string form), keeping a single authoring shape. The dict's piece value may be
written three ways, freely mixed: the long name `(kind: "king", color: "white")`,
the abbreviation `(kind: "k", color: "white")`, or a bare letter `"K"`
(upper = white, lower = black). All normalise to canonical `(kind, color)` via
`_normalize-piece`. So: **yes to both** long form and abbreviations.

## 2. What the position is genuinely missing

To be "prepared" for the mission, the object should carry:

```
(
  variant: "standard",        // enum: standard | xiangqi | ...
  cols: 8, rows: 8,           // geometry (files × ranks)
  board: ( <square> -> (kind, color) ),     // canonical occupancy (shape unchanged)
  turn, castling, en-passant, halfmove, fullmove,   // standard-chess state
)
```

- **`variant` + `cols`/`rows` are the additions that matter.** The renderer
  currently hardcodes `range(8)`; it must read `cols`/`rows` (the visualization
  revamp).
- **`castling` / `en-passant` / `halfmove` are standard-chess concepts** —
  meaningless/different for Xiangqi, Shogi, etc. Keep them for now, but expect
  them to become variant-scoped (e.g. an open `state:` sub-dict the variant
  defines) when variants are actually added. Don't assume every position has
  castling rights.

## 3. The real structural blocker: `coords.typ`

`src/coords.typ` hardcodes standard geometry three ways, all of which break for
variants:

- `file-letters = ("a".."h")` — only 8 files.
- `rank-digits = ("1".."8")` — only 8 ranks.
- `parse-square` **assumes exactly 2 characters** — so `"a10"` (Xiangqi has 10
  ranks) is rejected and `square-name` can't emit it.

Repercussion: coordinate translation must become **geometry-parameterized** —
`parse-square(name, cols, rows)` / `square-name(col, row, cols, rows)` — instead
of relying on module-level constants. Files beyond `h` extend `a..z` (26 is
plenty); ranks become multi-digit.

**Typst constraint:** dict keys must be **strings**, so the board must be keyed by
a string. Two options:

- **(a) algebraic names** ("e4", "a10") — human-friendly; parsing/formatting must
  be geometry-aware (the rework above). **[recommended]**
- **(b) neutral coordinate key** like `"4,0"` — trivially geometry-agnostic but
  unreadable and un-FEN-like.

Recommendation: **(a)**, with all naming centralized in `coords.typ` and the
position carrying `cols`/`rows` so the parser knows the bounds. Keeps "e4"
working and scales to 9×10 without a new key scheme.

Invariant to preserve (already documented in `coords.typ`): internal `(col,row)`
is chess-native (row 0 = rank 1 = bottom); the screen y-flip lives only in the
renderer. Generalize the *bounds*, keep the invariant.

## 4. Per-variant piece vocabularies → a small registry

`piece-kinds` / `piece-colors` in `pieces.typ` are currently global and western.
Make them **per-variant**, in a `variants.typ` registry:

```
standard: (kinds: ("king","queen","rook","bishop","knight","pawn"),
           fen: (k:"king", q:"queen", r:"rook", b:"bishop", n:"knight", p:"pawn"),
           cols: 8, rows: 8)
xiangqi:  (kinds: ("general","advisor","chariot","elephant","horse","cannon","soldier"),
           abbr: (G:"general", A:"advisor", R:"chariot", E:"elephant",
                  H:"horse", C:"cannon", S:"soldier"),
           cols: 9, rows: 10)
```

`fen-piece` and the new string parser then look up the abbreviation→kind map for
the position's `variant` (lower case = black, upper case = white). This is the
seam that makes "standard pieces / unusual geometry / non-western / fairy"
*possible later* without rewrites. (Piece-set asset resolution will also key off
variant eventually — not now.)

## 5. New string constructor — yes; prefer the raw-block form

Strongly in favour. Notes:

- **Prefer the raw-block (backtick) form** over the array-of-strings. The
  array-of-strings is bug-prone (the prompt's own example left stray `"` and `,`
  on some lines). A raw block has no per-line quoting/comma noise and no
  trailing-comma traps. Accept the array form too; document the raw block as
  primary.
- **Rules:** first line = top rank (read top-down, like FEN); `.` = empty;
  uppercase = white, lowercase = black; map letters via the variant's
  abbreviation table.
- **Validation:** assert every non-empty line has the same length → that is
  `cols`; `rows` = line count (rectangular only, per the prompt). Trim trailing
  whitespace per line. Reject unknown abbreviations with a clear message
  (mirrors the FEN "invalid piece letter" path).
- Needs `variant` (default `standard`) to know legal abbreviations; otherwise it
  *discovers* geometry by counting.

Example (raw block):

```
#board(position(```
  ....r...
  ........
  ..p..PPk
  .p.r....
  pP..p.R.
  P.B.....
  ..P..K..
  ........
```))
```

## 6. The engine question, answered

> *engine.typ `apply()` uses `position.board` — is that the wrong layout?*

**No — the dict is the right runtime layout** (fast lookup, no duplicates, what
move generation needs). What is actually off is adjacent:

1. The surrounding position is **standard-and-8×8-coupled** (no
   `variant`/`cols`/`rows`; mandatory castling/ep). `apply` is also
   standard-rules-only — and that's acceptable: **variant move generation is a
   separate, deferrable problem**, and **board visualization needs no engine at
   all.** The visualization revamp should depend only on
   `board` + `cols` + `rows` + `variant`, never on `apply`.
2. Keying `board` by algebraic name silently assumes 8×8/2-char naming — the
   `coords.typ` issue (§3), not an `apply` issue.

So: keep `board` as a dict; do not merge `pieces` into the engine; fix
geometry-awareness in `coords.typ`; keep the engine western-standard for now
behind the `variant` flag.

## Open decisions to settle at implementation time

1. **Board key scheme:** algebraic-but-geometry-aware (rec) vs neutral
   `"col,row"`.
2. **Where standard state lives:** keep `castling`/`ep`/clocks top-level for now,
   or move into a variant-defined `state:` sub-dict from the start (cleaner,
   slightly more work).
3. **Always store geometry** in `position` vs derive `8×8` when omitted. (Rec:
   always store — single source of truth for the renderer.)
4. **Constructor surface:** overload `position(..)` to sniff str / array / raw /
   dict (rec — it already sniffs array-vs-dict) vs a dedicated
   `position-from-string`.

## Bottom line

The instinct that *something* is too narrow is right — but it is the
**geometry/variant coupling in `coords.typ` plus the position's standard-only
metadata**, not the use of a board dict. Minimal set to unlock everything from
8×8 western to 9×10 Xiangqi *as a possibility* (without implementing variants
now):

1. Make `pieces` (and the new string form) **constructors**; keep the board dict
   canonical.
2. Add `variant` + `cols` + `rows` to `position`.
3. Generalize `coords.typ` to be geometry-parameterized (variable files,
   multi-digit ranks).
4. Move piece vocabularies into a `variants.typ` registry.

Then revamp the renderer to read `cols`/`rows`/`variant` (next step).
