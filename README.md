# staunton

Chess diagrams for [Typst](https://typst.app). Render a board with pieces, build
a diagram straight from a **FEN** string, or parse a **PGN** game (with a pure
Typst legal-move engine) and draw any position — mainline, variation, or a
"what-if" line — all wrapped in a `#figure` for captions and cross-references.

![gallery](out/gallery-1.png)

## Quick start

```typ
#import "@preview/staunton:0.1.0": chess-diagram, position, starting-fen

// From a FEN string (this one is 1.e4 c5 2.Nf3):
#chess-diagram("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2")

// The starting position, with PGN-style metadata for the caption:
#chess-diagram(starting-fen, white: [Carlsen], black: [Nepo], event: [Dubai], year: 2021)

// Manual placement: a squares dict (square -> piece). Capitalisation of the
// square names does not matter; pieces may be long names or bare letters.
#chess-diagram(position((
  e1: (kind: "king", color: "white"),
  e8: (kind: "king", color: "black"),
  e4: "P",                                // bare letter: upper = white pawn
)), labels: false)
```

During local development (before the package is published) import the entry
point directly and compile with the package folder as root:

```sh
typst compile --root . your-doc.typ
```

## `chess-diagram(source, ..)`

The everyday entry point for **standard western chess**. Returns a `#figure`
with `kind: "chess"`.

The high-level API is **variant-forward**: `chess-board` / `chess-diagram` are
standard chess; other variants get their own names (`xiangqi-board` /
`xiangqi-diagram`, `shatar-board` / `shatar-diagram`, …) as their renderers and
engines land. Each is thin sugar over the variant-agnostic primitives `board`
and `diagram` (which take the variant from the `source`). `chess-diagram` simply
documents the variant and rejects a non-standard position source.

`source` is one of:

* a **FEN string**, e.g. `"8/8/8/8/8/8/8/8"`;
* a **position** dict from `position(..)` or `parse-fen(..)`;
* a bare **squares** dict (square name → `(kind, color)`).

### Labeling

A diagram can carry two labels:

* **Above** the board — a *game-info* line. When both `white` and `black` are
  known it is drawn automatically as `"<White> – <Black> (<Year>)"`. Override
  with `game-info:` (any content), or it is omitted when players are unknown.
* **Below** the board — the figure **caption**. For a **FEN-string** source the
  default is `"Position at move N, X to play"`; for a **PGN** source (via
  `board-after`) it is `"Position after move <last move>"`; for a manual
  position/board dict there is no default. Override with `caption:` (or `none`).

| argument | default | meaning |
|---|---|---|
| `white`, `black` | `none` | player names; drive the automatic above-line |
| `year` | `none` | appended to the above-line in parentheses |
| `event` | `none` | accepted for the Seven-Tag-Roster; not shown by default |
| `game-info` | `auto` | content drawn above the board; overrides the auto line |
| `caption` | `auto` | content drawn below; overrides the source-specific default |
| `flip` | `false` | `true` shows the board from Black's side (**per-diagram only** — cannot be a document default) |
| `size` | `auto` | board size: a `length`, a `ratio` (of available width), or `auto` for the default. `≤ 0` falls back to the default. `size` is the **longer** board dimension; cells stay square. Always clamped so the figure fits the available width **and** height. |
| `light`, `dark` | tan theme | square fill colors |
| `piece-set` | `"cburnett"` | SVG piece set, or `"unicode"` for the glyph fallback |
| `labels` | `true` | show rank/file labels |
| `label-mode` | `"on-square"` | `"on-square"`, `"outside"`, or `"border"` (see below) |
| `file-side` | `bottom` | `bottom` or `top` |
| `rank-side` | `right` | `right` or `left` |
| `file-label-corner` | `left` | on-square file label corner: `left` (lower-left) or `right` (lower-right) |
| `rank-label-corner` | `right` | on-square rank label corner: `right` (upper-right) or `left` (upper-left) |
| `border-theme` | `"square"` | `"border"` band theme: `"square"` (dark band, light labels), `"brown"` (dark-brown band, creme labels), or `"dark"` (charcoal band, light-grey labels) |
| `grid` | `false` | draw 1pt grid lines between squares (fixed at any size) |
| `highlight` | `()` | squares to mark — see below |
| `highlight-shape` | `"filled"` | default shape for plain string entries: `"filled"`, `"cross"`, or `"circle"` |
| `highlight-fill` | green | fill for `"filled"` highlights (settable; combined with `highlight-transparency`) |
| `highlight-transparency` | `75%` | transparency applied to `highlight-fill` |
| `cross-color`, `circle-color` | red, green | stroke colors for cross / circle highlights |
| `cross-width`, `circle-width` | `4pt` | stroke widths for cross / circle highlights |
| `arrows` | `()` | array of arrows — see below |
| `arrow-color` | green | default arrow color (same base as `highlight-fill`); combined with `arrow-transparency` |
| `arrow-transparency` | `75%` | transparency applied to the default `arrow-color` |
| `arrow-width` | `auto` | arrow shaft width; `auto` scales with the square |

Extra named arguments are forwarded to `figure` (e.g. `placement: top`).

### Highlights

`highlight` is an array; each entry is one of:

* a square name `"e4"` — drawn with `highlight-shape` (default `"filled"`) in
  `highlight-fill`;
* a `(square, color)` pair — a **filled** square in an explicit color (this is
  what PGN `%csl` annotations produce; the color may be a `%csl` letter);
* a dict `(square: "e4", shape: "circle", color: green)` — full control;
  `shape` is `"filled"`, `"cross"`, or `"circle"`, `color` optional.

Filled squares use `highlight-fill` at `highlight-transparency`. Circles have a
radius of half the square; crosses span (almost) corner-to-corner with round
ends. Their stroke colors/widths are `cross-color`/`circle-color` and
`cross-width`/`circle-width`. By convention a **cross marks an empty square**
(it would clash with a piece) — this is a guideline, not enforced.

```typ
#board("...", highlight: ("e4", (square: "e5", shape: "circle")))
```

### Arrows

`arrows` is an array; each entry is a `(from, to)` or `(from, to, color)` tuple,
or a dict `(from: "f3", to: "e5", color: red)`. A missing color uses
`arrow-color` (default: the highlight color at `arrow-transparency`). The shaft
width is `arrow-width` (`auto` scales with the square). Arrows scale with the
board and flip with it:

```typ
#board("...", arrows: (("e2", "e4"), ("g1", "f3", blue)))
```

### Board labels

`label-mode` chooses how files and ranks are drawn (files run `a`… and ranks
`1`… as far as the board geometry needs), always in a fixed sans-serif font
independent of the document:

* `"on-square"` (default) — small labels tucked into the corners of the edge
  squares (file letters on the file-side rank, rank digits on the rank-side
  file), each in the *opposite* color of its square. The corners are settable
  via `file-label-corner` / `rank-label-corner`. The size is a fixed fraction of
  the square and does **not** change with the board size (no automatic switch to
  another mode).
* `"outside"` — label strips in a gutter outside the board (the classic look).
* `"border"` — a band around the board, themed by `border-theme`: `"square"`
  (dark-square band, light-square labels), `"brown"` (dark-brown band, creme
  labels), or `"dark"` (charcoal band, light-grey labels).

`labels: false` suppresses all of them; `file-side`/`rank-side` and `flip` are
honored in every mode.

## `board(source, ..)` and `diagram(source, ..)`

`board` draws just the board — no figure, no caption — and is the variant-agnostic
primitive that the diagram wrappers build on. `diagram` is the matching generic
`#figure` wrapper. Both take the same `source` forms, the same `flip`, and the
same style overrides (`size`, `light`, `dark`, `piece-set`, `labels`,
`label-mode`, `file-side`, `rank-side`, `highlight`, …):

```typ
#import "@preview/staunton:0.1.0": board
#board("8/8/8/3k4/3K4/8/8/8", flip: true, size: 4cm)
```

Reach for `board` when you want a board inline in text, inside your own layout,
or anywhere a `#figure` would be in the way. Use a `*-diagram` when you want the
captioned, cross-referenceable figure.

`chess-board` / `chess-diagram` are the **standard-variant** sugar over
`board` / `diagram`: same rendering, but they document the variant and reject a
non-standard position source. Other variants get their own names
(`xiangqi-board`, …) as they land.

## `position(..)`

`position` builds a position object — the data model for "which piece stands on
which square." It accepts a **FEN string** (auto-detected and delegated to
`parse-fen`, so `position(fen)`, `board(fen)` and `play-moves(fen, …)` are
consistent), or one of two hand-authoring forms:

```typ
// a squares dict (square -> piece). The piece can be written three ways,
// freely mixed: a long name, a kind abbreviation, or a bare letter
// (UPPER = white, lower = black). Square-name capitalisation is ignored.
#position((
  e1: (kind: "king", color: "white"),   // long name
  d8: (kind: "q", color: "black"),       // kind abbreviation
  e4: "P",                                // bare letter
))

// the "string" form — first line is the TOP rank, "." is empty,
// UPPER = white, lower = black:
#position(```
  ....r...
  ........
  ..p..PPk
  .p.r....
  pP..p.R.
  P.B.....
  ..P..K..
  ........
```)
// ...or as several row strings: position("....r...", "........", ...)
```

It returns a dict `(variant, cols, rows, squares, turn, castling, en-passant,
halfmove, fullmove)`:

* `variant` — `"standard"` (the only one implemented; the registry in
  `src/variants.typ` is the seam for future variants like Xiangqi). This is the
  low-level field that records which variant a position belongs to;
* `cols` / `rows` — board geometry (counted from the string form, otherwise the
  variant default of 8×8);
* `squares` — the canonical square → `(kind, color)` map (this is the field
  formerly called `board`).

Named options `turn`, `castling`, `en-passant`, `halfmove`, `fullmove`, and
explicit `cols`/`rows` are accepted too. `parse-fen` returns the same shape.
The string form is rectangular-only (every row must have the same width) and
rejects characters that aren't a valid piece abbreviation or `.`.

(The earlier array-of-`(kind, color, square)` form has been removed; use the
squares dict or the string form.)

## Games (PGN)

```typ
#import "@preview/staunton:0.1.0": parse-pgn, board-after, position-after, play-moves, mainline

// Read an external file IN YOUR OWN FILE (so `read` resolves relative to it):
#let game = parse-pgn(read("morphy.pgn")).first()

// ...or inline as a raw block (verbatim; no escaping of the quotes in tags):
#let game = parse-pgn(```
[White "Morphy"] [Black "NN"] [Result "1-0"]
1. e4 e5 2. Nf3 d6 3. d4 *
```).first()

#mainline(game)            // ("e4", "e5", "Nf3", "d6", "d4")
#board-after(game, "3w")   // a diagram of the position after White's 3rd move
```

`parse-pgn` returns an **array of games** (a PGN file may hold many). Parsing is
two-phase: tags and the movetext tree are read eagerly and cheaply, while the
move **engine** runs lazily — only when you ask for a position. So a tournament
file read only for `game.result` never invokes the engine.

### Locators

`position-after(game, loc)` / `board-after(game, loc, ..)` accept:

* `"30w"` / `"30b"` — after White's / Black's 30th move (the mainline);
* a **path** for (possibly nested) variations:

  ```typ
  // descend into variation 0 at White's move 2, then take ...the position after 2...Bc5
  #board-after(game, (line: ((at: "2w", into: 0),), at: "2b"))
  // two levels deep:
  #board-after(game, (line: ((at: "2w", into: 0), (at: "2b", into: 0)), at: "3w"))
  ```

### Playing moves onto a position (`play-moves`)

Variations recorded in the PGN (RAVs) are addressed by the path locator above.
To explore a *new* line not in the file, or to build a position from a FEN plus
some moves, use **`play-moves(source, moves)`**. `source` is `none` (the standard
starting position), a FEN string, or a position; `moves` is move **text** (a
string or a ```` ``` ```` raw block — move numbers and a trailing result are
tolerated) or an array of SAN tokens. It resolves each move against the
position's legal moves (an illegal/ambiguous move is a hard error) and returns
the **final** position. The source is never mutated:

```typ
#let base = position-after(game, "5w")
#chess-diagram(play-moves(base, "Be7 Re1 b5"))

#chess-diagram(play-moves(none, "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6"))   // none = start
```

The variant is taken from the position; the engine analyses **standard chess
only** for now (a non-standard position errors). Comments, NAGs and variations
in the text are rejected — use `parse-pgn` for full PGN movetext.

### Notation output (`chess-notation`)

`chess-notation(source, ..)` (and the variant-agnostic `notation`) renders move
text in human-readable form. `source` is a parsed **game**, a **move-text
string**, or a **SAN array** (the same forms `play-moves` takes). It formats SAN
the game already holds — no engine needed.

```typ
#import "@preview/staunton:0.1.0": parse-pgn, chess-notation

#let game = parse-pgn(read("game.pgn")).first()
#chess-notation(game)                       // 1. e4 e5 2. Nf3 Nc6 ...
#chess-notation(game, lang: "de")           // 1. e4 e5 2. Sf3 Sc6 ...
#chess-notation(game, figurine: true)       // 1. e4 e5 2. ♘f3 ♞c6 ...
#chess-notation(game, from: "8b", to: "12w")// an inclusive mainline slice
#chess-notation("1. e4 e5 2. Nf3")          // format a bare move-text string
```

Options:

| option | default | meaning |
|---|---|---|
| `from` / `to` | `none` | inclusive mainline locators (`"12w"`/`"12b"`); omit for the whole line |
| `figurine` | `false` | render piece letters as figurine glyphs (♔♕♖♗♘) |
| `lang` | `"en"` | piece-letter language: `"en"`, a code (`"de"`, `"ru"`, …), or `"auto"` (follows `#set text(lang: ..)`; unknown → English) |
| `move-numbers` | `true` | prefix move numbers (`1.`, `1...`) |
| `result` | `false` | append the game result (a `*` is never shown) |

Localization substitutes only the piece letters (`K Q R B N` and the promotion
letter after `=`); files, ranks, captures, check marks, and `O-O` are untouched.
Language files live in `assets/i18n/<code>.typ` (a `piece-chars` dict per
language); adding one is a no-code change. v1 ranges are **mainline-only**
(variation-line ranges error) and exclude comments/variations.

> Note: notation only *formats* SAN you already hold (a game or a SAN list). It
> cannot yet *generate* SAN from arbitrary positions — that needs a move→SAN
> encoder, which is future work.

### Exporting FEN (`to-fen`)

`to-fen` is the inverse of `parse-fen`. It serialises either a **position** or a
**game at a locator**:

```typ
#import "@preview/staunton:0.1.0": to-fen, parse-fen, play-moves, parse-pgn

#to-fen(play-moves(none, "1. e4 e5 2. Nf3"))   // "rnbqkbnr/... b KQkq - 1 2"
#to-fen(game, locator: "12w")                  // FEN at that locator
```

Standard 8×8 positions round-trip exactly with `parse-fen`. It is geometry-aware
(serialises larger boards too) and tolerant of positions built by `position()`
(empty castling, no en-passant).

### Drawing annotations (`%cal` / `%csl`)

`board-after` reads the standard PGN drawing annotations in a move's comment and
turns them into arrows and highlights automatically:

```typ
// 2. Nf3 {[%cal Gf3e5,Bf1c4] [%csl Re5,Yc6]} ...
#board-after(game, "2w")   // green/blue arrows + red/yellow square highlights
```

`[%cal <c><from><to>,…]` becomes arrows; `[%csl <c><square>,…]` becomes
highlights. The color letters (`G` `R` `Y` `B` `O`) resolve through the
`annotation-colors` board-style map, so a document can re-theme what each letter
means. PGN annotations merge with any `arrows` / `highlight` you pass explicitly;
set `pgn-annotations: false` to ignore them.

### Errors

Malformed PGN is a **hard error** (better than a silently wrong diagram):
broken tag syntax and stray variation parens fail at parse time; illegal,
ambiguous, or unparseable moves fail when the position is navigated. Missing
Seven-Tag-Roster tags are tolerated (they default).

## Document-wide style

Styling is split into two buckets: **board** style (everything the board draws —
colors, labels, piece set, grid, highlight, arrows, …) and **diagram** style (the
`#figure` wrapper — `info-bold`, `info-gap`, `supplement`). Each has its own
setter; `set-chess-defaults` is an umbrella that routes each key to the right one.

```typ
#import "@preview/staunton:0.1.0": set-board-defaults, set-diagram-defaults, set-chess-defaults, set-piece-set
#set-board-defaults(light: rgb("#eeeed2"), dark: rgb("#769656"), size: 5cm)
#set-diagram-defaults(info-bold: false, supplement: [Position])
#set-piece-set("merida")          // sugar for set-board-defaults(piece-set: "merida")
#set-chess-defaults(dark: blue, info-gap: 1em)  // umbrella: routes to both buckets
// every subsequent diagram inherits these; per-call arguments still override.
```

`flip` is the one setting that is **not** allowed in any defaults setter — board
orientation is a per-diagram choice, so `set-chess-defaults(flip: ..)` is an error.

## Coordinates

Files `a`–`h`, ranks `1`–`8`; `a1` is the dark square in the lower-left corner,
`h8` the upper-right. Square names are case-insensitive (`"E4"` = `"e4"`).

## Sizing

The default board size suits an A4 two-column layout (A4 is narrower than
US-letter, so it drives the default). The diagram reads the available space at
its insertion point via `layout`, so it adapts to one- or two-column layouts and
any page size without being told the geometry, and shrinks to fit if asked for
more than fits.

## Custom outline

Because diagrams use a distinct `figure` kind, you can list them separately:

```typ
#outline(title: [List of Diagrams], target: figure.where(kind: "chess"))
```

## Pieces & fonts

Pieces are drawn from bundled **SVG piece sets** under `assets/piece_sets/`:
`cburnett` (default), `merida`, `alpha`, `california`, `maestro`, `staunty`.
Choose one per diagram with `piece-set:` or document-wide with `set-piece-set`.
The SVGs carry their own baseline and colors, so the board renderer just centers
them in each square.

Passing `piece-set: "unicode"` (or `none`) selects the **glyph fallback**: the
solid Unicode chess glyphs (U+265A–U+265F) for both colors, distinguished by fill
+ a contrasting stroke, with the `white-fill`/`black-fill` style fields applying
only to this fallback. It needs a font carrying those glyphs; staunton tries
`DejaVu Sans Mono`, `Segoe UI Symbol`, `Apple Symbols`, `Noto Sans Symbols 2` in
order. Ship one of these if you rely on the fallback for portable output.

## Project layout

```
typst.toml          package manifest
lib.typ             public API + figure wrapper
src/coords.typ      square addressing (col,row <-> "e4"), geometry-aware
src/variants.typ    chess-variant registry (piece vocab + geometry; standard only)
src/pieces.typ      piece model + glyph rendering
src/fen.typ         FEN parsing -> position dict; position-fen (export)
src/engine.typ      legal-move engine (pseudo-legal -> legality filter)
src/san.typ         SAN parsing + resolution; play-san, play-moves
src/pgn.typ         PGN tokenizer + movetext/variation tree
src/game.typ        navigation: mainline, locators
src/notation.typ    human-readable notation (figurine / i18n); chess-notation
src/i18n.typ        language registry (loads assets/i18n/*.typ)
src/style.typ       diagram-style dict + document defaults
src/board.typ       canvas renderer + sizing + flip + label modes
assets/piece_sets/  SVG piece sets (cburnett default, + 5 more)
tests/run.sh        test runner (walks tests/**, // EXPECT:-classified)
tests/board/        §2 board: size, colors, labeling, orientation, piece_sets, style_options
tests/diagram/      §3 figures: auto_captions, free_captions, outlines
tests/fen/          §4 FEN: good / malformed / inconsistent
tests/pgn/          §5 PGN: good / roster / san / moves / realworld
tests/position/     position object: string form, object shape, malformed
tests/out/          kept render artifacts (mirrors the tests/ tree)
examples/showcase.typ   capability tour using the example games
examples/pgn/           sample PGN files
```

PGN input is robust to CRLF and LF line endings and to `{…}` comments
containing parentheses, move numbers and evaluations.

## Tests

```sh
bash tests/run.sh        # compiles pass-cases, asserts fail-cases error with their message
```

The runner walks every `.typ` under `tests/`. A file carrying a
`// EXPECT: <substring>` header is an **expected-fail** test (it must error and
the message must contain the substring); any other file is an **expected-pass**
test whose rendered PDF is kept under `tests/out/`, mirroring the source path
(so visual sheets can be eyeballed). Files/dirs prefixed with `_` (shared
fixtures) are skipped. `examples/*.typ` are also compiled as must-compile
showcases.

Or individually:

```sh
typst compile --root . tests/board/labeling/label_modes.typ out/labels.pdf
typst compile --root . examples/showcase.typ out/showcase.pdf
```

## Roadmap

Designed so these are additive, not rewrites:

* **Internationalization** of chess terms via `#set text(lang: ..)`.
* **Customization**: more board themes and square patterns (piece sets, colors,
  flip and label modes already plug into the `(kind, color) → content` seam).
* Engine performance: the `legal-moves`/`apply` interface is narrow enough to
  swap for a WASM engine if large PGN databases ever need it.

## License

MIT.
