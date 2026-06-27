# Prompt 15 — PGN handling options + embedded comment commands

> Status: **implemented** (this round's scope) — see "Implementation outcome" at
> the end. Source:
> `prompts/prompt_15__pgn_options_embedded_diagram.txt`. Scope: a third settable
> bucket controlling how PGN-embedded extras (annotations, NAGs, comments,
> diagram markers) are *handled at render time*, plus a comment interpreter that
> recognises the diagram-command syntaxes.

## Verdict

Parsing is **already lossless** (`parse-pgn` stores comments verbatim, the raw
`nags` array, and the `variations` tree; it never looks inside a comment). So:

- **All filtering lives at the visualization stage, not the parser.** The same
  parsed game can be shown plain in one place and fully annotated in another;
  filtering at parse would discard information irreversibly. **No parser change.**
- Add a third **handling bucket** `set-pgn-defaults` (peer of board/diagram
  style), wired into the existing consumers (`board-after`, `notation`) plus a
  new **comment interpreter**.

## Decisions (this session)

- **Factory defaults: everything OFF, opt-in** (`annotations`, `nags`,
  `comments`, `diagrams` all `false`). Reading a PGN yields plain movetext; you
  enable processing explicitly. *This flips `board-after`'s current
  annotations-on default* (pre-1.0; the annotations test gains `annotations:
  true`).
- **Scope this round: options bucket + comment parsing.** Build the bucket,
  NAG-in-notation, comment-text-in-notation, and the **comment interpreter** that
  detects/strips diagram markers (+caption) and `%cal`/`%csl`. **Defer** the
  inline whole-game renderer (`annotated-game`) to its own prompt.
- **Name: `set-pgn-defaults`** (`default-pgn-style`, `pgn-style-state`,
  `pgn-style-keys`).

## The bucket (`src/style.typ`)

```typ
#let default-pgn-style = (
  annotations: false,  // process %cal/%csl -> arrows/highlights
  nags:        false,  // render NAGs ("Nf3!", "d4⩲") in notation
  comments:    false,  // include comment prose in notation
  diagrams:    false,  // act on embedded diagram markers (consumer: future renderer)
)
```

Plus `pgn-style-state`, `set-pgn-defaults(..)`, `pgn-style-keys`. Same resolution
as the other buckets: factory ⊕ document state ⊕ per-call override. (The umbrella
`set-chess-defaults` learns to route these keys too.)

## Comment interpreter (`src/annotations.typ`, new)

`_interpret-comment(comment) -> (diagram, arrows, highlights, text)`:

- **diagram**: `none`, or `(caption: none|str)`. Recognised markers (your list),
  **`{d}`/`{D}` deliberately NOT recognised**:

  | in-comment token | source | caption |
  |---|---|---|
  | `#` / `#[<caption>]` | ChessBase | optional |
  | `[d]` / `[D]` | Scid | — |
  | `\diagram` | LaTeX | — |
  | `%%diagram` | Markdown/HTML | — |

- **arrows / highlights**: the existing `%cal` / `%csl` extraction (moved here).
- **text**: the residual comment prose with all markers/commands stripped (for
  `comments: true`).

A single comment may hold a marker **and** `%cal`/`%csl` **and** prose; the
interpreter splits all three. Also here: the **NAG → symbol** map
(`$1→!`, `$2→?`, `$3→!!`, `$5→!?`, `$6→?!`, `$10→=`, `$14→⩲`, `$16→±`,
`$18→+−`, …; unknown `$n` passes through as `$n`).

## Consumers wired this round

- **`board-after`**: drop the bespoke `pgn-annotations: true` flag; read
  `annotations` from the resolved pgn bucket (default now `false`), still
  overridable per call. Annotation extraction routes through the new interpreter.
- **`notation`**: gains `nags` and `comments`. These need the move **nodes**
  (san + nags + comment-after), so `notation`'s game path reads `game.movetext`
  rather than just `mainline()`; string/array sources wrap each SAN in a minimal
  node (no nags/comments). `nags: true` appends NAG symbols after the SAN;
  `comments: true` appends the interpreted comment text. Variations still
  excluded (v1).
- **`diagrams`**: the switch + marker detection ship now; its consumer (the
  inline embed) is deferred, so this round it is detectable/tested but not yet
  acted on.

## Deferred (next prompt): inline diagram embedding — NOT a new renderer

To clarify a point that came up: embedding diagrams at `{#}` markers does **not**
need a new board renderer. The board is the **existing** one, unchanged — each
inserted diagram is just:

```typ
chess-diagram(position-after(game, ply), caption: <marker caption>,
              arrows: <from %cal>, highlight: <from %csl>)
```

`position-after`, `chess-diagram`, the arrows/highlight params, and captions all
already exist. The only new code is a **thin interleave**: walk the movetext,
emit `notation` for the runs and a `chess-diagram` where a marker appears.

Two equally light shapes for that interleave (decide when we wire it):

1. **A `diagrams: true` branch inside `notation`** — `notation` already returns
   content, so it returns move-text with `board` blocks spliced in at markers.
   **No new function** (current lean).
2. A tiny separate composer (`annotated-game`/`replay`) if we want `notation` to
   stay strictly inline text.

Either way it is pure composition over existing primitives, and orthogonal to the
manual workflow (`notation(from/to)` → `board-after` → repeat), where everything
stays off.

## Test plan

- `set-pgn-defaults` round-trips through resolution; per-call override wins;
  `set-chess-defaults` routes pgn keys.
- Interpreter: each marker form detected (`#`, `#[cap]`, `[d]`, `[D]`,
  `\diagram`, `%%diagram`) with caption captured; `{d}`/`{D}` **not** detected;
  `%cal`/`%csl` extracted; residual text correct; mixed comment splits cleanly.
- `notation(game, nags: true)` → `1. e4 e5 2. Nf3!? ...`; `comments: true`
  includes prose; both default off (plain movetext unchanged).
- `board-after`: annotations off by default (no arrows); `annotations: true`
  renders them; document default via `set-pgn-defaults`.
- NAG map: representative `$n` → symbol; unknown passes through.

## Open / deferred

- inline diagram embedding (consumes `diagrams`) — likely just a `diagrams: true`
  branch inside `notation`, no new renderer (see the clarification above).
- Configurable marker set / localized NAG text — fixed for now.
- Comments/variations in notation beyond mainline prose — out of scope.

## Implementation outcome

Shipped as designed (parser untouched, lossless):

- **`set-pgn-defaults` bucket** in `src/style.typ` (`default-pgn-style` /
  `pgn-style-state` / `pgn-style-keys`), all switches **off**; `set-chess-defaults`
  routes the keys.
- **`src/annotations.typ`**: `interpret-comment(comment) -> (diagram, arrows,
  highlights, text)` (recognises `#`/`#[cap]`, `[d]`/`[D]`, `\diagram`,
  `%%diagram`; **not** bare `{d}`/`{D}`; extracts `%cal`/`%csl`; returns residual
  prose) + the NAG→symbol map.
- **`notation`** gained `nags` / `comments` (default `auto` → the pgn bucket),
  reading the move **nodes** for a game source; string/array sources carry none.
  Returns a string on the explicit fast path, content when document state is
  consulted (same string-vs-content rule as `lang: "auto"`).
- **`board-after`**: the old `pgn-annotations: true` flag became `annotations:
  auto` (consults the bucket, **off** by default). The pgn gate is resolved
  inside the figure **body** (a context) via a shared `_assemble` helper, so the
  `#figure` stays **referenceable** (verified: figures created *inside* a context
  still cannot be referenced in Typst 0.15, hence the body-level resolution).
- `lib._pgn-annotations` now delegates to `interpret-comment`.
- **Tests** 57 → 60 pass: `tests/pgn/handling/{pgn_options,interpret_comment}.typ`
  + an EXPECT-error for an unknown key; the notation and annotations tests were
  updated for the new defaults (and a referenceability guard added).

### Deviation / note

`board-after`'s annotation default flipped from on to off (pre-1.0). The diagram
markers are detected and tested but not yet rendered (the inline embed is the
deferred step).
