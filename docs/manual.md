# staunton — user manual

Complete reference for the **staunton** chess package. For a quick overview and
installation, see the [README](../README.md). A runnable capability tour lives in
[`docs/examples/showcase.typ`](examples/showcase.typ).

All examples assume:

```typ
#import "@preview/staunton:0.1.0": *
```

## Contents

- [chess-diagram](#chess-diagram)
  - [Labeling](#labeling) · [Highlights](#highlights) · [Arrows](#arrows) · [Board labels](#board-labels)
- [board and diagram](#board-and-diagram)
- [position](#position)
- [Games (PGN)](#games-pgn)
  - [Locators](#locators) · [Playing moves](#playing-moves-onto-a-position) · [Notation output](#notation-output) · [Exporting FEN](#exporting-fen) · [Drawing annotations](#drawing-annotations) · [Errors](#errors)
- [Tournament tables](#tournament-tables)
- [Document-wide style](#document-wide-style) · [Language](#language) · [PGN handling](#pgn-handling)
- [Outlines and references](#outlines-and-references)
- [Pieces and fonts](#pieces-and-fonts)
- [Coordinates](#coordinates) · [Sizing](#sizing)

---

## chess-diagram

`chess-diagram(source, ..)` is the everyday entry point for **standard western
chess**. Returns a `#figure` with `kind: "chess"`.

The high-level API is **variant-forward**: `chess-board` / `chess-diagram` are
standard chess; other variants get their own names (`xiangqi-board` /
`xiangqi-diagram`, …) as their renderers and engines land. Each is thin sugar
over the variant-agnostic primitives `board` and `diagram` (which take the
variant from the `source`). `chess-diagram` documents the variant and rejects a
non-standard position source.

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
| `lang` | `auto` | language for the figure supplement (`auto` → document language) |
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
ends. By convention a **cross marks an empty square** (guideline, not enforced).

```typ
#board("...", highlight: ("e4", (square: "e5", shape: "circle")))
```

### Arrows

`arrows` is an array; each entry is a `(from, to)` or `(from, to, color)` tuple,
or a dict `(from: "f3", to: "e5", color: red)`. A missing color uses
`arrow-color`. The shaft width is `arrow-width` (`auto` scales with the square).
Arrows scale with the board and flip with it:

```typ
#board("...", arrows: (("e2", "e4"), ("g1", "f3", blue)))
```

### Board labels

`label-mode` chooses how files and ranks are drawn (files run `a`… and ranks
`1`… as far as the board geometry needs), always in a fixed sans-serif font
independent of the document:

* `"on-square"` (default) — small labels tucked into the corners of the edge
  squares, each in the *opposite* color of its square. The corners are settable
  via `file-label-corner` / `rank-label-corner`.
* `"outside"` — label strips in a gutter outside the board (the classic look).
* `"border"` — a band around the board, themed by `border-theme`.

`labels: false` suppresses all of them; `file-side`/`rank-side` and `flip` are
honored in every mode.

## board and diagram

`board(source, ..)` draws just the board — no figure, no caption — and is the
variant-agnostic primitive that the diagram wrappers build on. `diagram` is the
matching generic `#figure` wrapper. Both take the same `source` forms, the same
`flip`, and the same style overrides:

```typ
#board("8/8/8/3k4/3K4/8/8/8", flip: true, size: 4cm)
```

Reach for `board` when you want a board inline in text or inside your own layout;
use a `*-diagram` when you want the captioned, cross-referenceable figure.

`chess-board` / `chess-diagram` are the **standard-variant** sugar over
`board` / `diagram`: same rendering, but they document the variant and reject a
non-standard position source.

## position

`position(..)` builds a position object — the data model for "which piece stands on
which square." It accepts a **FEN string** (auto-detected and delegated to
`parse-fen`), or one of two hand-authoring forms:

```typ
// a squares dict (square -> piece). The piece can be written three ways, freely
// mixed: a long name, a kind abbreviation, or a bare letter (UPPER = white,
// lower = black). Square-name capitalisation is ignored.
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

* `variant` — `"standard"` (the only one implemented; `src/variants.typ` is the
  seam for future variants);
* `cols` / `rows` — board geometry (counted from the string form, otherwise the
  variant default of 8×8);
* `squares` — the canonical square → `(kind, color)` map.

Named options `turn`, `castling`, `en-passant`, `halfmove`, `fullmove`, and
explicit `cols`/`rows` are accepted too. `parse-fen` returns the same shape. The
string form is rectangular-only and rejects characters that aren't a valid piece
abbreviation or `.`.

## Games (PGN)

```typ
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

`parse-pgn` returns an **array of games** (a PGN file may hold many). A game is
`(tags, movetext-raw, result)`. Parsing is **lazy** to stay fast on large,
multi-game files:

* the **roster** (`tags`), the `result`, and each game's **verbatim movetext**
  (`movetext-raw`, a string) are extracted eagerly and cheaply;
* the movetext **tree** (move nodes with NAGs / comments / variations) is built
  on demand by **`movetext(game)`**, and memoised;
* the move **engine** runs later still — only when you ask for a position.

So a tournament file read only for `game.result` (e.g. for standings) never
tokenises movetext, and pulling one game's moves out of a 400-game file parses
only that game.

```typ
#game.movetext-raw        // "1. e4 e5 2. Nf3 ..." (verbatim, always present)
#movetext(game)           // parsed nodes: (san, nags, comment-before, comment-after, variations)
#mainline(game)           // ("e4", "e5", "Nf3", ...) — uses movetext() under the hood
```

### Locators

`position-after(game, loc)` / `board-after(game, loc, ..)` accept:

* `"30w"` / `"30b"` — after White's / Black's 30th move (the mainline);
* a **path** for (possibly nested) variations:

  ```typ
  // into variation 0 at White's move 2, then the position after 2...Bc5
  #board-after(game, (line: ((at: "2w", into: 0),), at: "2b"))
  // two levels deep:
  #board-after(game, (line: ((at: "2w", into: 0), (at: "2b", into: 0)), at: "3w"))
  ```

### Playing moves onto a position

Variations recorded in the PGN (RAVs) are addressed by the path locator above.
To explore a *new* line, or to build a position from a FEN plus some moves, use
**`play-moves(source, moves)`**. `source` is `none` (the standard start), a FEN
string, or a position; `moves` is move **text** (a string or a raw block — move
numbers and a trailing result are tolerated) or an array of SAN tokens. It
resolves each move against the legal moves (illegal/ambiguous is a hard error)
and returns the **final** position; the source is never mutated:

```typ
#let base = position-after(game, "5w")
#chess-diagram(play-moves(base, "Be7 Re1 b5"))
#chess-diagram(play-moves(none, "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6"))   // none = start
```

The engine analyses **standard chess only** for now. Comments, NAGs and
variations in the text are rejected — use `parse-pgn` for full PGN movetext.

### Notation output

`chess-notation(source, ..)` (and the variant-agnostic `notation`) renders move
text in human-readable form. `source` is a parsed **game**, a **move-text
string**, or a **SAN array**. It formats SAN the game already holds — no engine.

```typ
#chess-notation(game)                       // 1. e4 e5 2. Nf3 Nc6 ...
#chess-notation(game, lang: "de")           // 1. e4 e5 2. Sf3 Sc6 ...
#chess-notation(game, figurine: true)       // 1. e4 e5 2. ♘f3 ♞c6 ...
#chess-notation(game, from: "8b", to: "12w")// an inclusive mainline slice
#chess-notation("1. e4 e5 2. Nf3")          // format a bare move-text string
```

| option | default | meaning |
|---|---|---|
| `from` / `to` | `none` | inclusive mainline locators (`"12w"`/`"12b"`); omit for the whole line |
| `figurine` | `false` | render piece letters as figurine glyphs, colour-aware: White's moves use outline symbols (♔♕♖♗♘), Black's the solid ones (♚♛♜♝♞) |
| `lang` | `auto` | piece-letter language. `auto` (the value) follows the document language (`set-lang`, default English); a code (`"de"`, `"ru"`, …) forces a language; the string `"auto"` follows `#set text(lang: ..)`; unknown → English |
| `move-numbers` | `true` | prefix move numbers (`1.`, `1...`) |
| `result` | `false` | append the game result (a `*` is never shown) |
| `nags` | `auto` | render NAGs as glyphs (`$1`→`!`, `$6`→`?!`, `$14`→`⩲`, …); `auto` → the `set-pgn-defaults` default (off) |
| `comments` | `auto` | append comment prose (game source only); `auto` → the pgn default (off) |

`nags`/`comments` apply to a **game** source. With an **explicit** `lang` (a
code) and explicit `nags`/`comments`/`diagrams`, `notation` returns a plain
string; when any of those is `auto` (consulting a document default) — including
the default `lang: auto` — it returns content.

**Embedded diagrams.** With `diagrams: true` (or `set-pgn-defaults(diagrams:
true)`) over a *game*, `notation` flows the movetext as content and splices a
`chess-diagram` after each move whose comment holds a diagram marker — using that
move's caption (from `{#[caption]}`) and, when `annotations` is on, its
`%cal`/`%csl`:

```typ
// 2. Nf3 {[%cal Gf1c4] #[After 2.Nf3]} Nc6 3. Bb5 {[d]} a6 ...
#chess-notation(game, diagrams: true, annotations: true)
```

Spliced diagrams are created in a `context`, so they are not individually
referenceable (use `board-after` with a label when you need a reference).

Localization substitutes only the piece letters (`K Q R B N` and the promotion
letter after `=`); files, ranks, captures, check marks, and `O-O` are untouched.
Ranges are **mainline-only** and exclude comments/variations.

> `notation` only *formats* SAN you already hold. It cannot yet *generate* SAN
> from arbitrary positions — that needs a move→SAN encoder (future work).

### Exporting FEN

`to-fen` is the inverse of `parse-fen`. It serialises either a **position** or a
**game at a locator**:

```typ
#to-fen(play-moves(none, "1. e4 e5 2. Nf3"))   // "rnbqkbnr/... b KQkq - 1 2"
#to-fen(game, locator: "12w")                  // FEN at that locator
```

Standard 8×8 positions round-trip exactly with `parse-fen`. It is geometry-aware
(serialises larger boards too) and tolerant of positions built by `position()`.

### Drawing annotations

PGN comments can carry drawing annotations. Processing is **off by default** —
reading a PGN gives plain output unless you opt in:

```typ
// 2. Nf3 {[%cal Gf3e5,Bf1c4] [%csl Re5,Yc6]} ...
#board-after(game, "2w", annotations: true)   // green/blue arrows + red/yellow highlights
#set-pgn-defaults(annotations: true)           // ...or turn it on document-wide
```

`[%cal <c><from><to>,…]` becomes arrows; `[%csl <c><square>,…]` becomes
highlights. The color letters (`G` `R` `Y` `B` `O`) resolve through the
`annotation-colors` board-style map. They merge with any `arrows` / `highlight`
you pass explicitly. The per-call `annotations:` argument (`auto` → the document
default) overrides per diagram.

### Errors

Malformed PGN is a **hard error**: broken tag syntax and stray variation parens
fail at parse time; illegal, ambiguous, or unparseable moves fail when the
position is navigated. Missing Seven-Tag-Roster tags are tolerated (they
default).

## Tournament tables

Built from a parsed PGN's roster + results (no engine). Compute functions return
plain data; the `*-table` renderers produce a `#figure` (kind `"chess-table"`)
wrapping a `#table`, so a table can be captioned, referenced (`@label`) and
listed by `chess-table-outline`. Each works on a list of games (filter a
multi-division file first with `games-by-event`), with `by: "player"` or
`by: "team"`:

```typ
#let games = parse-pgn(read("event.pgn"))
#standings-table(games, by: "player")        // end-score table, sorted best-first
#crosstable-table(games, by: "team")          // round-robin cross-table
#progress-table(games, by: "team")            // round-by-round running score

// captioned + referenceable; `title` is a heading drawn ABOVE the table
#standings-table(games, caption: [Final standings], title: [Division A]) <a>
// ...later:  see @a
```

Each renderer takes `caption` (figure caption, used by refs and the outline),
`title` (a heading stacked above the table), `supplement` (`auto` → the
language-aware default "Table"/"Tabelle"/…, or an explicit per-call override),
and `lang` (`auto` → the document language). Extra named arguments are forwarded
to the inner `#table`.

- **`standings`** sorts by score desc, then tie-breaks, then first appearance.
  Tie-breaks: `buchholz`, `sonneborn-berger`, and (team) `board-points`; override
  with `tiebreaks: (..)`.
- **Team** mode groups games in the same major round (`Round = "round.board"`)
  between the same two teams into a **match**: board points are summed and match
  points (`2/1/0`, settable via `match-points`) decide the match.
- **`crosstable`** requires a round-robin (every pair met) — it errors otherwise
  (use standings + progress for Swiss/league).
- **`progress`** needs the `Round` tag; columns are the rounds with a running
  total.
- The compute functions (`standings`, `crosstable`, `progress`) are also public,
  returning data for custom layouts.

> Team tables assume the standard `Round = "round.board"` convention. A file
> whose round numbering doesn't follow it will produce unreliable *team*
> grouping — *player* standings only sum per player and are robust regardless.

## Document-wide style

Styling is split into buckets: **board** style (everything the board draws),
**diagram** style (the diagram `#figure` — `info-bold`, `info-gap`,
`supplement`, `outline-title`), and **table** style (the table `#figure` —
`supplement`, `outline-title`, `title-gap`). Each has its own setter;
`set-chess-defaults` is an umbrella that routes each key to the right one.

```typ
#set-board-defaults(light: rgb("#eeeed2"), dark: rgb("#769656"), size: 5cm)
#set-diagram-defaults(info-bold: false, supplement: [Position])
#set-table-defaults(supplement: [Tabelle])
#set-piece-set("merida")          // sugar for set-board-defaults(piece-set: "merida")
#set-chess-defaults(dark: blue, info-gap: 1em)  // umbrella
// every subsequent diagram/table inherits these; per-call arguments still override.
```

`flip` is the one setting **not** allowed in any defaults setter — board
orientation is a per-diagram choice, so `set-chess-defaults(flip: ..)` is an
error. (`supplement` / `outline-title` live in both the diagram and table
buckets; the umbrella routes them to **diagrams** — use `set-table-defaults` for
the table ones.)

### Language

A single document **language** drives every language-aware string — diagram and
table supplements, outline titles, and notation piece letters. Default is
English; `"auto"` follows `#set text(lang: ..)`; or pick a code (`"de"`, `"es"`,
`"fr"`, `"it"`, `"pt"`, `"ru"`):

```typ
#set-lang("de")     // diagrams -> "Diagramm", tables -> "Tabelle",
                     // outlines -> "Diagrammverzeichnis" / "Tabellenverzeichnis",
                     // notation -> Sf3, Lb5, ...
#set-lang("auto")   // follow #set text(lang: ..)
```

`set-chess-defaults(lang: ..)` does the same. Every localizable string is also
**per-call overridable**: diagrams/tables/outlines take a `lang:` argument
(default `auto` = the document language), and an explicit `supplement:` /
`title:` (content) overrides the localized default entirely. Adding a language is
a no-code change: drop a `src/assets/i18n/<code>.typ` exporting `piece-chars` +
`strings` and register it in `src/i18n.typ`.

### PGN handling

A **PGN-handling** bucket decides how much of a parsed game's embedded extras get
*processed at render time*. Parsing stays lossless; these switches only decide
what is interpreted. **All default off**:

```typ
#set-pgn-defaults(annotations: true, nags: true, comments: true)
```

| key | default | effect |
|---|---|---|
| `annotations` | `false` | `%cal`/`%csl` → arrows/highlights on `board-after` |
| `nags` | `false` | render NAGs (`Nf3!`, `d4⩲`) in `notation` |
| `comments` | `false` | include comment prose in `notation` |
| `diagrams` | `false` | embed a board in `notation` output after each move whose comment carries a diagram marker (`{#}`/`{#[caption]}`, `{[d]}`/`{[D]}`, `{\diagram}`, `{%%diagram}`) |

`set-chess-defaults` routes these keys too; each is also a per-call argument
(`auto` → the document default) on `notation` / `board-after`.

## Outlines and references

Diagrams and tournament tables are each wrapped in a `#figure` with a distinct
`kind` — `"chess"` for diagrams, `"chess-table"` for tables — so they get their
own counters, can be **referenced** (`@label` → "Diagram 3" / "Table 2"), and can
be **listed separately**:

```typ
#chess-diagram-outline()          // list of chess diagrams
#chess-table-outline()            // list of tournament tables
#chess-outlines()                  // both, diagrams then tables

// titles are LANGUAGE-AWARE by default, but settable per call or document-wide;
// extra args (depth, indent, ...) are forwarded to `outline`
#chess-diagram-outline(title: [Figures])           // explicit title
#chess-diagram-outline(lang: "de")                  // "Diagrammverzeichnis"
#chess-outlines(diagram-title: [Diagrams], table-title: [Tables])
```

Referencing works because the label attaches to the figure:

```typ
#chess-diagram(starting-fen, caption: [Start]) <start>
#standings-table(games, caption: [Final standings]) <final>
As shown in @start and @final, ...
```

Only figures that carry a **caption** appear in an outline (a caption-less figure
is still referenceable but unlisted, matching Typst's own behaviour). You can
also target the kinds directly with `#outline(target: figure.where(kind:
"chess-table"))`. Document-wide default titles: `set-diagram-defaults(outline-title:
..)` / `set-table-defaults(outline-title: ..)`.

## Pieces and fonts

Pieces are drawn from bundled **SVG piece sets** under `src/assets/piece_sets/`.
Two sets ship with the package, both licensed **GPLv2+** (see
[`LICENSE-PIECES`](../LICENSE-PIECES)):

* `cburnett` — the default; © Colin M.L. Burnett
* `merida` — © Armando Hernandez Marroquin

Choose one per diagram with `piece-set:` or document-wide with `set-piece-set`.
The SVGs carry their own baseline and colors, so the renderer just centers them
in each square.

**Adding your own set.** The renderer accepts *any* set name and loads
`src/assets/piece_sets/<name>/{w,b}{K,Q,R,B,N,P}.svg` on demand (path resolved
relative to the package), so you can add a set by dropping such a folder into your
local copy of the package and passing its name. A missing/misnamed file surfaces
as Typst's own "file not found" error. (The other popular lichess sets — alpha,
california, maestro, staunty — are **not** bundled: their licenses are
non-commercial. Download them from lichess for your own use if the terms suit
you.)

Passing `piece-set: "unicode"` (or `none`) selects the **glyph fallback**: the
solid Unicode chess glyphs (U+265A–U+265F) for both colors, distinguished by fill
+ a contrasting stroke (the `white-fill`/`black-fill` style fields apply only to
this fallback). It needs a font carrying those glyphs; staunton tries
`DejaVu Sans Mono`, `Segoe UI Symbol`, `Apple Symbols`, `Noto Sans Symbols 2`.

## Coordinates

Files `a`–`h`, ranks `1`–`8`; `a1` is the dark square in the lower-left corner,
`h8` the upper-right. Square names are case-insensitive (`"E4"` = `"e4"`).

## Sizing

The default board size suits an A4 two-column layout. The diagram reads the
available space at its insertion point via `layout`, so it adapts to one- or
two-column layouts and any page size without being told the geometry, and shrinks
to fit if asked for more than fits.
