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

// Manual placement (capitalisation of squares does not matter):
#chess-diagram(position((
  ("king", "white", "e1"),
  ("king", "black", "e8"),
  ("pawn", "white", "e4"),
)), labels: false)
```

During local development (before the package is published) import the entry
point directly and compile with the package folder as root:

```sh
typst compile --root . your-doc.typ
```

## `chess-diagram(source, ..)`

The main entry point. Returns a `#figure` with `kind: "chess"`.

`source` is one of:

* a **FEN string**, e.g. `"8/8/8/8/8/8/8/8"`;
* a **position** dict from `position(..)` or `parse-fen(..)`;
* a bare **board** dict (square name → `(kind, color)`).

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
| `size` | `auto` | board edge length: a `length`, a `ratio` (of available width), or `auto` for the default. `≤ 0` falls back to the default. Always clamped so the figure fits the available width **and** height. |
| `light`, `dark` | tan theme | square fill colors |
| `piece-set` | `"cburnett"` | SVG piece set, or `"unicode"` for the glyph fallback |
| `labels` | `true` | show rank/file labels |
| `label-mode` | `"on-square"` | `"on-square"`, `"outside"`, or `"border"` (see below) |
| `file-side` | `bottom` | `bottom` or `top` |
| `rank-side` | `right` | `right` or `left` |
| `grid` | `false` | draw 1pt grid lines between squares (fixed at any size) |
| `highlight` | `()` | squares to shade: names (`("e2","e4")`) and/or `(square, color)` pairs |
| `highlight-fill` | green wash | fill for plain `highlight` squares (settable) |
| `arrows` | `()` | array of arrows — see below |
| `arrow-color` | green | default arrow color when an arrow gives none (settable) |

Extra named arguments are forwarded to `figure` (e.g. `placement: top`).

### Arrows

`arrows` is an array; each entry is a `(from, to)` or `(from, to, color)` tuple,
or a dict `(from: "f3", to: "e5", color: red)`. A missing color uses
`arrow-color`. Arrows scale with the board and flip with it:

```typ
#board("...", arrows: (("e2", "e4"), ("g1", "f3", blue)))
```

### Board labels

`label-mode` chooses how files (`a`–`h`) and ranks (`1`–`8`) are drawn, always
in a fixed sans-serif font independent of the document:

* `"on-square"` (default) — small labels tucked into the corners of the edge
  squares (file letters bottom-left of the file-side rank, rank digits top-right
  of the rank-side file), each in the *opposite* color of its square. On small
  boards, where these corner labels would drop to ≤ 4pt and become illegible,
  the diagram **falls back to `"border"`** automatically.
* `"outside"` — label strips in a gutter outside the board (the classic look).
* `"border"` — a band around the board in the dark square color, labels in the
  light color.

`labels: false` suppresses all of them; `file-side`/`rank-side` and `flip` are
honored in every mode.

## `board(source, ..)`

`board` draws just the board — no figure, no caption — and is the primitive that
`chess-diagram` / `fen-diagram` wrap. It takes the same `source` forms, the same
`flip`, and the same style overrides (`size`, `light`, `dark`, `piece-set`,
`labels`, `label-mode`, `file-side`, `rank-side`, `highlight`, …):

```typ
#import "@preview/staunton:0.1.0": board
#board("8/8/8/3k4/3K4/8/8/8", flip: true, size: 4cm)
```

Reach for `board` when you want a board inline in text, inside your own layout,
or anywhere a `#figure` would be in the way. Use `chess-diagram` when you want
the captioned, cross-referenceable figure.

## Games (PGN)

```typ
#import "@preview/staunton:0.1.0": parse-pgn, board-after, position-after, line, mainline

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

### Variations without altering the source

Variations recorded in the PGN (RAVs) are addressed by the path locator above.
To explore a *new* line not in the file, use `line` — it starts from a position
(or FEN) and applies SAN moves, returning the array of positions
`(start, after 1, after 2, …)`. The source game is never mutated:

```typ
#let base = position-after(game, "5w")
#let whatif = line(base, ("Be7", "Re1", "b5"))
#chess-diagram(whatif.last())
```

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
src/coords.typ      square addressing (col,row <-> "e4")
src/pieces.typ      piece model + glyph rendering
src/fen.typ         FEN parsing -> position dict
src/engine.typ      legal-move engine (pseudo-legal -> legality filter)
src/san.typ         SAN parsing + resolution
src/pgn.typ         PGN tokenizer + movetext/variation tree
src/game.typ        navigation: mainline, locators, line()
src/style.typ       diagram-style dict + document defaults
src/board.typ       canvas renderer + sizing + flip + label modes
assets/piece_sets/  SVG piece sets (cburnett default, + 5 more)
tests/run.sh        test runner (walks tests/**, // EXPECT:-classified)
tests/board/        §2 board: size, colors, labeling, orientation, piece_sets, style_options
tests/diagram/      §3 figures: auto_captions, free_captions, outlines
tests/fen/          §4 FEN: good / malformed / inconsistent
tests/pgn/          §5 PGN: good / roster / san / moves / realworld
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
