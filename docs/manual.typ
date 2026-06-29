// staunton — user manual (the CANONICAL source; compiles to docs/manual.pdf).
//
// Every feature is shown as the code you type next to the board it produces, via
// the `example` helper (see docs/manual-tools.typ). Edit this file for any manual
// change; there is no separate markdown copy to keep in sync.
//
// Build:  typst compile --root . docs/manual.typ docs/manual.pdf

#import "manual-tools.typ": example

#set page(
  paper: "a4",
  margin: (x: 2.4cm, top: 2.4cm, bottom: 2.2cm),
  numbering: "1",
)
#set text(font: "Libertinus Serif", size: 10.5pt)
#set par(justify: true)
#set heading(numbering: "1.1")
#show raw: set text(font: "DejaVu Sans Mono", size: 9pt)

// Inline code and the `argument` cells read better lightly tinted.
#show raw.where(block: false): it => box(
  fill: rgb("#f0f0ec"), inset: (x: 3pt, y: 0pt), outset: (y: 3pt), radius: 2pt, it,
)

// --- title -------------------------------------------------------------------

#align(center)[
  #v(2cm)
  #text(size: 30pt, weight: "bold")[staunton]
  #v(2pt)
  #text(size: 13pt)[Chess diagrams, games and tournament tables for Typst]
  #v(6pt)
  #text(size: 10pt, fill: rgb("#666"))[User manual · package version 0.1.0]
]

#v(1.4cm)

All examples assume the package is in scope:

```typ
#import "@preview/staunton:0.1.0": *
```

In every framed example below, the left side is *the code you type* and the right
side is *exactly what it renders* — the manual compiles its own examples, so the
two can never disagree.

#outline(title: [Contents], depth: 2, indent: auto)

#pagebreak()

// === chess-diagram ===========================================================

= chess-diagram

`chess-diagram(source, ..)` is the everyday entry point for *standard western
chess*. It returns a `#figure` with `kind: "chess"`, so it is captioned and
cross-referenceable. The simplest call takes a FEN string:

#example(```typ
#chess-diagram(
  "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
  size: 4cm,
)
```)

`source` is one of: a *FEN string*; a *position* dict from `position(..)` or
`parse-fen(..)`; or a bare *squares* dict (square name → `(kind, color)`).

A diagram can carry two labels: a *game-info* line above the board (drawn
automatically as `"<White> – <Black> (<Year>)"` when both players are known), and
the figure *caption* below it.

#example(```typ
#chess-diagram(
  "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R",
  white: "Morphy", black: "NN", year: 1858,
  caption: [After 2...Nc6],
  size: 4.2cm,
)
```)

Use `flip: true` to show the board from Black's side, and `piece-set:` to pick a
bundled set (`"cburnett"` default, `"merida"`, or `"unicode"` for the glyph
fallback):

#example(```typ
#chess-diagram(
  "8/8/8/3k4/3K4/8/8/8",
  flip: true,
  piece-set: "merida",
  size: 3.6cm,
)
```)

== Board labels

`label-mode` chooses how files and ranks are drawn — `"on-square"` (default,
tucked into the corner squares), `"outside"` (a gutter strip), or `"border"` (a
themed band, styled by `border-theme`). `labels: false` suppresses them.

#example(```typ
#chess-diagram(
  "8/5k2/8/8/3Q4/8/4K3/8",
  label-mode: "border",
  border-theme: "brown",
  size: 3.8cm,
)
```)

// === Highlights and arrows ===================================================

= Highlights and arrows

`highlight` marks squares; each entry is a square name (drawn with
`highlight-shape`, default `"filled"`), a `(square, color)` pair, or a dict
`(square: .., shape: .., color: ..)` where `shape` is `"filled"`, `"cross"`, or
`"circle"`.

#example(```typ
#chess-diagram(
  "8/8/8/4p3/4P3/8/8/8",
  highlight: (
    "e4",
    (square: "e5", shape: "circle"),
    (square: "d5", shape: "cross"),
  ),
  size: 4cm,
)
```)

`arrows` draws arrows; each entry is a `(from, to)` or `(from, to, color)` tuple,
or a dict `(from: .., to: .., color: ..)`. A missing color uses `arrow-color`.
Arrows scale with the board and flip with it.

#example(```typ
#chess-diagram(
  "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
  arrows: (
    ("e2", "e4"),
    ("g1", "f3", blue),
  ),
  size: 4cm,
)
```)

Highlights and arrows combine freely, and a `grid: true` overlay can be added on
top of any board:

#example(```typ
#chess-diagram(
  "r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R",
  grid: true,
  highlight: ("f7",),
  arrows: (("c4", "f7"), ("f3", "e5", rgb(0, 70, 160, 200))),
  size: 4.4cm,
)
```, stacked: true)

// === board and diagram =======================================================

= board and diagram

`board(source, ..)` draws *just the board* — no figure, no caption. It is the
variant-agnostic primitive the diagram wrappers build on, and the right tool when
you want a board inline in text or inside your own layout. It takes the same
`source` forms and the same style overrides as `chess-diagram`.

#example(```typ
A king-and-pawn ending #board(
  "8/8/8/3k4/3K4/8/8/8",
  size: 2.2cm,
  labels: false,
) drawn inline.
```)

Reach for `board` when you want the bare board; reach for a `*-diagram` when you
want the captioned, cross-referenceable `#figure`. `chess-board` / `chess-diagram`
are the *standard-variant* sugar over the generic `board` / `diagram`: same
rendering, but they document the variant and reject a non-standard source.

// === position ================================================================

= position

`position(..)` builds the data model — "which piece stands on which square." It
accepts a FEN string (auto-detected), a *squares dict*, or a *string form*. In a
squares dict the piece can be a long name, a kind abbreviation, or a bare letter
(UPPER = white, lower = black):

#example(```typ
#chess-diagram(
  position((
    e1: (kind: "king", color: "white"), // long
    d8: (kind: "q", color: "black"),    // kind
    e4: "P",                            // letter
  )),
  size: 4cm,
)
```)

The *string form* reads like the board itself — first line is the TOP rank, `.`
is empty:

#example(```typ
#chess-diagram(
  position(
    "....r...",
    "........",
    "..p..PPk",
    ".p.r....",
    "pP..p.R.",
    "P.B.....",
    "..P..K..",
    "........",
  ),
  size: 4.2cm,
)
```)

`position` returns a dict `(variant, cols, rows, squares, turn, castling,
en-passant, halfmove, fullmove)`; `parse-fen` returns the same shape. The string
form is rectangular-only and rejects characters that aren't a valid piece
abbreviation or `.`.

// === Games (PGN) =============================================================

= Games (PGN)

`parse-pgn` returns an *array of games* (a PGN file may hold many); `.first()`
takes one. Read an external file with `read` in your own file, or pass an inline
raw block. The examples below assume a parsed game is in scope:

```typ
#let game = parse-pgn(read("game.pgn")).first()
```

Parsing is *lazy*: the roster (`tags`), the `result`, and the verbatim
`movetext-raw` are extracted cheaply; the move tree is built on demand by
`movetext(game)`; the engine runs only when you ask for a position. So a
tournament file read only for results never tokenises movetext.

`chess-notation(game)` renders the moves the game already holds, and
`board-after(game, loc)` draws the position at a locator:

#example(```typ
#chess-notation(game)
```, stacked: true)

#example(```typ
#board-after(game, "3w", size: 4cm)
```)

== Locators

`position-after(game, loc)` / `board-after(game, loc, ..)` accept `"30w"` /
`"30b"` (after White's / Black's 30th mainline move), or a *path* into nested
variations:

```typ
// the position after 2...Bc5 in variation 0 at White's move 2
#board-after(game, (line: ((at: "2w", into: 0),), at: "2b"))
```

== Playing moves onto a position

To explore a *new* line, or build a position from a FEN plus some moves, use
`play-moves(source, moves)`. `source` is `none` (the standard start), a FEN
string, or a position; `moves` is move text or a SAN array. It resolves each move
against the legal moves (illegal/ambiguous is a hard error) and returns the
*final* position, never mutating the source:

#example(```typ
#chess-diagram(
  play-moves(none, "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6"),
  size: 4cm,
)
```)

== Notation output

`chess-notation(source, ..)` formats move text the game already holds — no engine.
`source` is a game, a move-text string, or a SAN array. It can localise the piece
letters and render figurine glyphs:

#example(```typ
#chess-notation(game, lang: "de")
```, stacked: true)

#example(```typ
#chess-notation(game, figurine: true)
```, stacked: true)

Useful options: `from` / `to` (inclusive mainline slice, `"8b"`/`"12w"`),
`move-numbers`, `result`, and — for a *game* source — `nags` / `comments`
(consulting the PGN-handling defaults). Localization substitutes only the piece
letters; files, ranks, captures, check marks and `O-O` are untouched.

== Exporting FEN

`to-fen` is the inverse of `parse-fen`. It serialises a position, or a game at a
locator. Standard 8×8 positions round-trip exactly:

#example(```typ
#raw(to-fen(play-moves(none, "1. e4 e5 2. Nf3")))
```, stacked: true)

== Drawing annotations

PGN comments can carry drawing annotations — `[%cal …]` for arrows, `[%csl …]`
for highlights. Processing is *off by default*; opt in per call with
`annotations: true` (or document-wide with `set-pgn-defaults`). The demo game
annotates its 2nd move:

#example(```typ
// move 2: {[%cal Gf3e5] [%csl Re5]}
#board-after(game, "2w", annotations: true, size: 4cm)
```)

The color letters (`G R Y B O`) resolve through the `annotation-colors` board
style; annotations merge with any `arrows` / `highlight` you pass explicitly.

== Errors

Malformed PGN is a *hard error*: broken tag syntax and stray variation parens
fail at parse time; illegal, ambiguous, or unparseable moves fail when the
position is navigated. Missing Seven-Tag-Roster tags are tolerated (they default).

// === Tournament tables =======================================================

= Tournament tables

Tournament tables are built from a parsed PGN's roster + results (no engine). The
`*-table` renderers produce a captioned, referenceable `#figure` (kind
`"chess-table"`). Each works on a list of games, with `by: "player"` or
`by: "team"`. The examples use a parsed 4-player round-robin in `games`:

```typ
#let games = parse-pgn(read("event.pgn"))
```

`standings-table` sorts best-first (score, then tie-breaks, then first
appearance):

#example(```typ
#standings-table(games, by: "player")
```, stacked: true)

`crosstable-table` renders the round-robin grid (it *requires* a complete
round-robin and errors otherwise — use standings + progress for Swiss/league):

#example(```typ
#crosstable-table(games, by: "player")
```, stacked: true)

`progress-table` shows the round-by-round running score (needs the `Round` tag):

#example(```typ
#progress-table(games, by: "player")
```, stacked: true)

Each renderer takes `caption` (used by refs and the outline), `title` (a heading
above the table), `supplement`, and `lang`. The compute functions (`standings`,
`crosstable`, `progress`) are also public, returning plain data for custom
layouts. *Team* mode groups games by the `Round = "round.board"` convention into
matches.

// === Document-wide style =====================================================

= Document-wide style

Styling splits into buckets — *board* style, *diagram* style, and *table* style —
each with its own setter; `set-chess-defaults` is an umbrella routing each key to
the right bucket. A setter affects *every subsequent* diagram/table; per-call
arguments still override.

```typ
#set-board-defaults(light: rgb("#eeeed2"), dark: rgb("#769656"), size: 5cm)
#set-diagram-defaults(info-bold: false, supplement: [Position])
#set-table-defaults(supplement: [Tabelle])
#set-piece-set("merida")                          // sugar for set-board-defaults
#set-chess-defaults(dark: blue, info-gap: 1em)    // umbrella
```

Every default is equivalently a *per-call* argument — the same green theme, set
once above vs. passed to one diagram:

#example(```typ
#chess-diagram(
  "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
  light: rgb("#eeeed2"), dark: rgb("#769656"),
  size: 4cm,
)
```)

`flip` is the one setting *not* allowed in any defaults setter — orientation is a
per-diagram choice, so `set-chess-defaults(flip: ..)` is an error.

== Language

A single document *language* drives every language-aware string — diagram and
table supplements, outline titles, and notation piece letters. Default is
English; `"auto"` follows `#set text(lang: ..)`; or pick a code:

```typ
#set-lang("de")     // Diagramm / Tabelle / Sf3, Lb5, ...
#set-lang("auto")   // follow #set text(lang: ..)
```

Every localizable string is also per-call overridable (the `lang:` argument seen
on `chess-notation` above). Adding a language is a no-code change: drop a
`src/assets/i18n/<code>.typ` and register it in `src/i18n.typ`.

== PGN handling

A *PGN-handling* bucket decides how much of a parsed game's embedded extras get
interpreted at render time. Parsing stays lossless; these switches only decide
what is processed, and *all default off*:

```typ
#set-pgn-defaults(annotations: true, nags: true, comments: true)
```

#table(
  columns: (auto, 1fr),
  inset: 6pt,
  align: (left, left),
  stroke: 0.5pt + rgb("#d9d9d2"),
  table.header([*key*], [*effect*]),
  raw("annotations"), [`%cal`/`%csl` → arrows/highlights on `board-after`],
  raw("nags"), [render NAGs (`Nf3!`, `d4⩲`) in `notation`],
  raw("comments"), [include comment prose in `notation`],
  raw("diagrams"), [embed a board in `notation` after each move marked for one],
)

Each is also a per-call argument (`auto` → the document default) on `notation` /
`board-after` — as used in the annotations example above.

// === Outlines and references =================================================

= Outlines and references

Diagrams and tables each carry a distinct figure `kind` (`"chess"` /
`"chess-table"`), so they get their own counters, can be *referenced*
(`@label` → "Diagram 3" / "Table 2"), and can be *listed separately*:

```typ
#chess-diagram-outline()     // list of chess diagrams
#chess-table-outline()       // list of tournament tables
#chess-outlines()            // both, diagrams then tables

#chess-diagram(starting-fen, caption: [Start]) <start>
As shown in @start, ...
```

Only figures that carry a *caption* appear in an outline (a caption-less figure is
still referenceable but unlisted, matching Typst). Titles are language-aware by
default and settable per call (`title:`, `lang:`) or document-wide
(`set-diagram-defaults(outline-title: ..)`).

// === Pieces and fonts ========================================================

= Pieces and fonts

Pieces are drawn from bundled *SVG piece sets*. Two ship with the package, both
GPLv2+: `cburnett` (default) and `merida`. Choose one per diagram with
`piece-set:` or document-wide with `set-piece-set`:

#example(```typ
#grid(columns: 3, gutter: 8pt, align: bottom,
  board("8/8/8/8/4N3/8/8/8", size: 2.6cm, piece-set: "cburnett"),
  board("8/8/8/8/4N3/8/8/8", size: 2.6cm, piece-set: "merida"),
  board("8/8/8/8/4N3/8/8/8", size: 2.6cm, piece-set: "unicode"),
)
```, stacked: true)

The renderer accepts *any* set name and loads
`src/assets/piece_sets/<name>/{w,b}{K,Q,R,B,N,P}.svg` on demand, so you can add a
set by dropping such a folder into your copy and passing its name. `piece-set:
"unicode"` (or `none`) selects the glyph fallback — solid Unicode chess glyphs
distinguished by fill and a contrasting stroke; it needs a font carrying them.

// === Coordinates =============================================================

= Coordinates

Files `a`–`h`, ranks `1`–`8`; `a1` is the dark square in the lower-left corner,
`h8` the upper-right. Square names are case-insensitive (`"E4"` = `"e4"`).

#example(```typ
#board(
  "8/8/8/8/8/8/8/8",
  label-mode: "outside",
  size: 4cm,
)
```)

// === Sizing ==================================================================

= Sizing

The default board size suits an A4 two-column layout. A diagram reads the
available space at its insertion point via `layout`, so it adapts to any column
or page size without being told the geometry, and shrinks to fit if asked for
more than fits. `size` may be a `length`, a `ratio` of the available width, or
`auto`:

#example(```typ
#chess-diagram(
  "8/8/8/3k4/3K4/8/8/8",
  size: 60%,   // of the available width
)
```)
