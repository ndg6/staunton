// staunton user manual
//
// Every feature is shown as the code you type next to the board it produces, via
// the `example` helper (see docs/manual-tools.typ). Edit this file for any manual
// change; there is no separate markdown copy to keep in sync.
//
// Build:  typst compile --root . docs/manual.typ docs/manual.pdf
//
// Chapter order is deliberately bottom-up: board -> diagram -> position -> games
// -> tables -> outlines -> document-wide style.

#import "manual-tools.typ": example

#set page(
  paper: "a4",
  margin: (x: 2.4cm, top: 2.6cm, bottom: 2.4cm),
)
#set text(font: "Libertinus Serif", size: 10.5pt)
#set par(justify: true)
#set heading(numbering: "1.1")
#show raw: set text(font: "DejaVu Sans Mono", size: 9pt)

// Inline code and the `argument` cells read better lightly tinted.
#show raw.where(block: false): it => box(
  fill: rgb("#f0f0ec"), inset: (x: 3pt, y: 0pt), outset: (y: 3pt), radius: 2pt, it,
)

// Copyright year for the footer, taken from the build date.
#let _year = str(datetime.today().year())

// Running chapter title for the header (right side): the FIRST level-1 heading
// that starts on the current page; if none starts here, the LAST one seen on an
// earlier page. So a page carrying "Introduction" then "The Board" shows
// "Introduction", and the next page (no new chapter) shows "The Board". (None
// while still in the front matter, before the first chapter.)
#let _running-chapter = context {
  let pg = here().page()
  let h1 = query(heading.where(level: 1))
  let on-page = h1.filter(h => h.location().page() == pg)
  if on-page.len() > 0 { on-page.first().body } else {
    let earlier = h1.filter(h => h.location().page() < pg)
    if earlier.len() > 0 { earlier.last().body } else { none }
  }
}

// --- cover page (no header, no footer, unnumbered) ---------------------------

#page(header: none, footer: none, numbering: none)[
  #align(center)[
    #v(1.1cm)
    #image("img/pawns-duo.svg", width: 9.5cm)
    #v(0.7cm)
    #text(size: 34pt, weight: "bold")[staunton]
    #v(3pt)
    #text(size: 13pt)[Chess diagrams, games and tournament tables for Typst]
    #v(8pt)
    #text(size: 10pt, fill: rgb("#666"))[User manual · package version 0.1.0]
  ]
]

// --- running header & footer for every following page ------------------------
// Pagination continues from the cover (page 1), so the first body page shows "2".

#set page(
  numbering: "1",
  header: context {
    if here().page() > 1 {
      set text(size: 9pt, fill: rgb("#666"))
      grid(columns: (1fr, 1fr),
        align(left)[staunton],
        align(right)[#_running-chapter],
      )
      v(-0.4em)
      line(length: 100%, stroke: 0.4pt + rgb("#cccccc"))
    }
  },
  footer: context {
    if here().page() > 1 {
      set text(size: 9pt, fill: rgb("#666"))
      line(length: 100%, stroke: 0.4pt + rgb("#cccccc"))
      v(-0.2em)
      grid(columns: (1fr, 1fr),
        align(left)[© Frank Lippert (#_year)],
        align(right)[#counter(page).display()],
      )
    }
  },
)

#outline(title: [Contents], depth: 2, indent: auto)

#pagebreak()

// === Introduction ============================================================

= Introduction<introduction>

Package *staunton* aims to provide a complete, convenient but also flexible solution
for chess publications. It provides a full set of features, including:

- *boards and diagrams* — pure boards with labels, highlights, arrows, an optional grid, 
  flexible sizing, custom colours, and bundled SVG piece sets (or a Unicode fallback); and building on that diagrams with captions, figure counters, and referenceable labels;
- *games from PGN* — a sophisticated parser creates single games or an array of games,  
  from which you create positions by "locators" (mainline and variations), move play-out, and FEN export;
- *move notation* — from parsed games you get move text output with localized piece letters, 
  figurine glyphs, NAGs, comments and diagrams embedded inline;
- *tournament tables* — we can create standings, cross-tables and progress charts from a PGN's
  results, by player or by team;
- *outlines and references* — diagrams and tables get their own counters and lists;
- *document-wide styling* and *localization* (six languages, easily extended).

#example(```typ
#chess-diagram(
  "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R",
  caption: [The Ruy Lopez, three moves in.],
  size: 4cm,
)
```)

This manual is bottom-up. The *board* is the drawing primitive; a *diagram* wraps
a board in a referenceable figure; a *position* is the data a board draws; *games*
add PGN, notation, and play; then come *tournament tables*, *outlines and
references*, and the *document-wide style* settings.

== Installing and Importing

*staunton* is a Typst package. Import its public API once and every function in this
manual is in scope:

```typ
#import "@preview/staunton:0.1.0": *
```

== How to read this manual

In every framed example, the left side is *the code you type* and the right side
is *exactly what it renders* — the manual compiles its own examples, so the two
can never disagree.

== The Name

Typst package *staunton* is named in honour of *Howard Staunton* (c. 1810–1874): a leading chess master of his day, organiser of the first international tournament (London, 1851), a chess author and publisher, and the namesake of the standardised *Staunton pattern* chessmen —
still the tournament standard.

// === The board ===============================================================

= The Board<board>

`board(source, ..)` draws *just the board* — no caption, no figure — and is the
primitive every diagram builds on. `source` is one of: a *FEN string*; a
*position* (from `position(..)` or `parse-fen(..)`); or a bare *squares* dict
(square name → `(kind, color)`).

#example(```typ
#board(
  "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
  size: 4cm,
)
```)

`board` is the variant-agnostic primitive; `chess-board` is the standard-chess
sugar over it (same rendering, but it documents the variant and rejects a
non-standard source). Use `board` inline in text or inside your own layout; reach
for a *diagram* (next chapter) when you want a captioned, referenceable figure.

The rest of this chapter covers the board's drawing options: labels, highlights,
arrows, the grid, coordinates, size, colours, orientation, and piece sets — all of
which a `chess-diagram` accepts too.

== Labels

`label-mode` chooses how labels for files and ranks are drawn — `"on-square"` (default,
tucked into the corner of the squares), `"outside"` (a gutter strip), or `"border"` (a
themed band, styled by `border-theme`). `labels: false` suppresses labels completely.

#example(```typ
#board(
  "8/5k2/8/8/3Q4/8/4K3/8",
  label-mode: "border",
  border-theme: "brown",
  size: 3.8cm,
)
```)

== Highlights

`highlight` marks squares; each entry is a square name (drawn with
`highlight-shape`, default `"filled"`), a `(square, color)` pair, or a dict
`(square: .., shape: .., color: ..)` where `shape` is `"filled"`, `"cross"`, or
`"circle"`. By convention a *cross* marks an empty square.

#example(```typ
#board(
  "8/8/8/4p3/4P3/8/8/8",
  highlight: (
    "e4",
    (square: "e5", shape: "circle"),
    (square: "d5", shape: "cross"),
  ),
  size: 4cm,
)
```)

== Arrows and the Grid

As the name suggests `arrows` draws arrows on the board; each entry is a `(from, to)` or `(from, to, color)` tuple, or a dict `(from: .., to: .., color: ..)`. A missing color uses `arrow-color`.
Arrows scale with the board and flip with it. A `grid: true` overlay draws thin
lines between the squares.

#example(```typ
#board(
  "r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R",
  grid: true,
  highlight: ("f7",),
  arrows: (("c4", "f7"), ("f3", "e5", rgb(0, 70, 160, 200))),
  size: 4.4cm,
)
```, stacked: true)

== Coordinates and Non-Square Boards

At leasst in standard western chess, Files run `a`, `b`, … and ranks `1`, `2`, …; `a1` is the dark square in the lower-left corner, `h8` the upper-right. Square names are case-insensitive
(`"E4"` = `"e4"`).

#example(```typ
#board(
  "8/8/8/8/8/8/8/8",
  label-mode: "outside",
  size: 4cm,
)
```)

But boards are *not* tied to 8×8. A `position` built from the string form (next
chapter) counts its own columns and rows, and the renderer draws whatever geometry
it is given — files and ranks extend as far as the board needs, and the cells stay
square while the board itself becomes rectangular:

#example(```typ
#board(
  position(
    "r..k.r",
    "pp..pp",
    "......",
    "RN..KR",
  ),
  size: 4cm,
)
```)

== Sizing

The default board size suits an A4 two-column layout. A board reads the available
space at its insertion point via `layout`, so it adapts to any column or page size
without being told the geometry, and shrinks to fit if asked for more than fits.
`size` may be a `length`, a `ratio` of the available width, or `auto`:

#example(```typ
#board(
  "8/8/8/3k4/3K4/8/8/8",
  size: 60%,   // of the available width
)
```)

== Colours

`light` and `dark` set the two square colours:

#example(```typ
#board(
  "8/8/8/3qk3/3QK3/8/8/8",
  light: rgb("#eeeed2"),
  dark: rgb("#769656"),
  size: 3.8cm,
)
```)

== Flip

`flip: true` shows the board from Black's side; labels, highlights and arrows all
flip with it. Orientation is a *per-board* choice — `flip` is the one setting that
cannot be made a document default (see *Document-wide style*).

#example(```typ
#board("8/8/8/3k4/3K4/8/8/8", flip: true, size: 3.4cm)
```)

== Piece Sets and Fonts

Pieces are drawn from bundled *SVG piece sets*. Two ship with the package, both
GPLv2+: `cburnett` (default) and `merida`. Choose one with `piece-set:` per board,
or document-wide with `set-piece-set`:

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

The rank/file *labels* are drawn in their own sans-serif, set by the `label-font`
board option (a family or a fallback list), independent of the document font. The
default is `("Arial", "DejaVu Sans Mono")` — Arial on Windows/macOS, falling back
to Typst's always-embedded mono — so a stock install draws labels without
"unknown font family" warnings. Override it like any board default:

```typ
#set-board-defaults(label-font: "Segoe UI")   // or a list, e.g. ("Helvetica", "DejaVu Sans Mono")
```

// === Diagrams ================================================================

= Diagrams<diagrams>

`chess-diagram(source, ..)` wraps a board in a `#figure` (kind `"chess"`), so —
unlike a bare `board` — it is captioned, counted, referenceable, and listed by an
outline. `source` is the same FEN / position / squares the board takes, and it
accepts every board option from the previous chapter.

A diagram carries two optional labels: a *game-info* line above the board (drawn
automatically as `"<White> – <Black> (<Year>)"` when both players are known) and
the figure *caption* below it.

#example(```typ
#chess-diagram(
  "r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R",
  white: "Morphy", black: "NN", year: 1858,
  caption: [After 2...Nc6],
  size: 4.2cm,
)
```)

`chess-diagram` is the standard-chess sugar over the generic `diagram`; both take
the same source and overrides as `board`. Extra named arguments are forwarded to
`figure` (e.g. `placement: top`).

== Boards are not Figures

A bare `board` is plain content: it has *no* caption, *no* figure counter, does
*not* resolve `@`-references, and is *not* listed by `chess-diagram-outline`. Only
a *diagram* is a figure. So draw a `board` for an inline or decorative position,
and a `chess-diagram` whenever you want to caption it, cross-reference it
(`@label`), or list it — see *Outlines and references*.

// === Positions ===============================================================

= Positions<positions>

`position(..)` builds the data model — "which piece stands on which square" — that
a board or diagram draws. It accepts a FEN string (auto-detected), a *squares
dict*, or a *string form*. In a squares dict the piece can be a long name, a kind
abbreviation, or a bare letter (UPPER = white, lower = black):

#example(```typ
#chess-diagram(
  position((
    e1: (kind: "king", color: "white"), // long
    d8: (kind: "q", color: "black"),    // kind
    e4: "P",                            // letter
  )),
  size: 4cm,
)
```, ratio: 0.7)

The *string form* reads like the board itself — first line is the TOP rank, `.`
is empty. Pass it as a raw block, as below — the most legible, least error-prone
way, with no per-line quotes or commas (several row strings work too). It is
rectangular-only (this is what lets a board be non-8×8) and rejects characters
that aren't a valid piece abbreviation or `.`:

#example(````typ
#chess-diagram(
  position(```
    ....r...
    ........
    ..p..PPk
    .p.r....
    pP..p.R.
    P.B.....
    ..P..K..
    ........
  ```),
  size: 4.2cm,
)
````)

`position` returns a dict `(variant, cols, rows, squares, turn, castling,
en-passant, halfmove, fullmove)`; `parse-fen` returns the same shape. The `cols` /
`rows` are counted from the string form (otherwise the 8×8 default).

// === Games (PGN) =============================================================

= Games (PGN)<games>
THe predominant form of the distribution and publications of chess games (atleast for western chess) are _PGN files_. PGN stands for *Portable Game Notation* and is a text format for chess games. It is human-readable, and can be parsed by chess software. PGN files contain the moves of a game, along with metadata such as player names, event, date, and result. PGN files cao contain just one or many games.

The `parse-pgn` function returns an *array of games*; `.first()` takes the first one. Read an external file with `read` in your own file, or pass an inline raw block. The examples below assume an already parsed game is in scope:

```typ
#let game = parse-pgn(read("game.pgn")).first()
```

Parsing is *lazy*: the roster (`tags`), the `result`, and the verbatim
`movetext-raw` are extracted cheaply; the move tree is built on demand by
`movetext(game)`; the move parser / generator engine runs only when you ask
for a position. So a tournament file read only for results and never tokenises movetext.

`chess-notation(game)` renders the moves (as text) the game already holds, and
`board-after(game, loc)` draws the position at a locator:

#example(```typ
#chess-notation(game)
```, stacked: true)

#example(```typ
#board-after(game, "3w", size: 4cm)
```)

== Locators

A *locator* addresses one position in a game. The simple form is a string —
`"30w"` / `"30b"`, the position after White's / Black's 30th *mainline* move.
`position-after(game, loc)`, `board-after(game, loc, ..)`, and
`to-fen(game, locator: ..)` all take this simple string form.

To address a move *inside a variation* (a PGN 'Recursive Annotation Variantion' or RAV), pass a *path* dict instead:
`(line: (..hops..), at: "<final move>")`. Each hop is `(at: "<move>", into: <n>)`
— branch off at mainline move `at`, descending `into` that move's variation
number `n` (*0-based*: `0` is the first variation recorded at that move, `1` the
second, …). The top-level `at` is where you stop within the line you reached:

#example(```typ
#let g = parse-pgn(
  "[White \"V\"][Black \"T\"] 1. e4 (1. d4 d5 2. c4) e5 *",
).first()
// into variation 0 at White's move 1 (the
// 1.d4 line), position after 2.c4:
#board-after(
  g,
  (line: ((at: "1w", into: 0),), at: "2w"),
  size: 3.4cm,
)
```)

Two easy traps:

- *The trailing comma.* A single-hop path is written `((at: "1w", into: 0),)` —
  the comma makes it a one-element *array* of hops. Without it, Typst reads a lone
  parenthesised dict and the locator is malformed.
- *Mainline is the fast path.* The string form (equivalently an empty
  `line: ()`) indexes a memoised list of mainline positions, so many diagrams off
  one game stay cheap; the path form is walked move by move.

Addressing a variation that isn't there (`into:` past the recorded count) or a
move past the end of its line is a hard error.

== Playing Moves onto a Position

To explore a *new* line, or build a position from a FEN plus some moves, use
`chess-moves(source, moves)`. `source` is `none` (the standard start), a FEN
string, or a position; `moves` is move text or a SAN array. It resolves each move
against the legal moves (illegal/ambiguous is a hard error) and returns the
*final* position, never mutating the source:

#example(```typ
#chess-diagram(
  chess-moves(none, "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6"),
  size: 4cm,
)
```)

== Notation Output

For chess publications, notational output of the move text is as important as showing 
board positions. This output has to be flexible and localisable. While you sometimes want to 
show move text exactly as it was recorded in the PGN, you often want to amend and reformat the move text for your own purposes. The `notation(..)` function is the workhorse for this. It takes a game, a move-text string, or a SAN array and produces a formatted move text output. It can localise the piece letters and render figurine glyphs, and it can include or exclude move numbers, results, NAGs, comments, and embedded diagrams.

To support different chess variants in the future`notation(..)` is the *variant-agnostic* primitive and `chess-notation(..)` is the *standard-western-chess* wrapper over it — identical
output today, but `chess-notation` fixes the variant and rejects a source of a
non-standard `variant`. The split is deliberate and forward-looking: staunton is
*variant-forward*, so a future variant gets its own name — a planned
`xiangqi-notation`, `shogi-notation`, … — each a thin wrapper over the same
generic `notation` core, while `chess-notation` stays western-chess-specific. The
same pairing runs through the package's drawing and notation entry points —
`board`/`chess-board`, `diagram`/`chess-diagram`, `notation`/`chess-notation`:
reach for the `chess-` name for ordinary chess, and the generic one only when you
are deliberately variant-agnostic. Two functions stand slightly apart: `position`
is variant-parameterised (the variant rides on its source or `variant:` argument,
so there is no separate `chess-position`), and `chess-moves` is chess-only today
(the engine does standard chess, so there is no generic `moves`). Both this manual and everyday use favour `chess-notation`.

Either formats move text the game already holds — no engine. Its `source` is a
game, a move-text string, or a SAN array; it localises the piece letters and
renders figurine glyphs:

#example(```typ
#chess-notation(game, lang: "de")
```, stacked: true)

#example(```typ
#chess-notation(game, figurine: true)
```, stacked: true)

`from` / `to` restrict output to an *inclusive* slice of moves. Both are the
simple `"8b"` / `"12w"` locators; `from` defaults to the first move, `to` to the
last:

#example(```typ
#chess-notation(game, from: "2w", to: "3b")
```, stacked: true)

`from` / `to` bound a slice of the *mainline*: they are the simple `"8b"` /
`"12w"` locators, not the variation *path* form that `board-after` takes
(rendering variations is a separate control — see the next section). A `from` past
the end or a `to` before `from` is a hard error.

Other options: `move-numbers`, `result`, `bold-mainline` (render the mainline moves
bold to set them off from variations — see *Variations*), and — for a *game*
source — `nags` / `comments`. The last three consult the PGN-handling defaults.
Localization substitutes only the piece letters; files, ranks, captures, check
marks and `O-O` are untouched.

=== Variations

By default `notation` renders only the *mainline*. Set `variations: true` (or the
`set-pgn-defaults(variations: ..)` document default) to splice the game's
variations (RAVs) into the output — in parentheses, correctly numbered: a
white-first line reads `3.Bc4 …`, a black-first line `3...Bc5 …`, and the resumed
mainline move re-shows its number:

#example(```typ
#chess-notation(
  parse-pgn(
    "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4 Bc5) a6 *",
  ).first(),
  variations: true,
)
```, stacked: true)

Variations nest to any depth and honour `nags` / `comments` / `figurine` / `lang`
inside the parentheses. `variation-style: "block"` keeps the parentheses but breaks
each variation onto its own line, indented one level per nesting depth (a variation
that ends on a nested line closes with a `)` on its own line) — the analysis-view
layout:

#example(```typ
#chess-notation(
  parse-pgn(
    "1. e4 (1. d4 d5 (1... Nf6 2. c4)) e5 *",
  ).first(),
  variations: true,
  variation-style: "block",
)
```, stacked: true, left-align: true)

To render *one specific* variation on its own, pass `line:` — a path locator
(the same `board-after` shape, or just its hops array) that descends into the
variation. It is numbered from its real branch ply, so it reads exactly as you'd
write it in analysis:

#example(```typ
#let g = parse-pgn(
  "1. e4 e5 2. Nf3 Nc6 (2... d6 3. d4) 3. Bb5 *",
).first()
// the 2...d6 side line, on its own:
#chess-notation(g, line: ((at: "2b", into: 0),))
```, stacked: true)

Each hop is `(at: "<move>", into: <n>)` — nest hops to reach a deeper line. The
addressed line's *own* variations follow the `variations` flag. (`from` / `to`
stay mainline-only and don't combine with `line`.)

=== Building on a Game: NAGs and Comments

Beyond `nags: true` (which renders the `$n` NAGs a game *already* carries), you can
attach NAGs and comments *programmatically* — without editing the PGN — and then
render them like any parsed game. `with-nags(game, ..)` and
`with-comments(game, ..)` each return a *new* game (the source is never mutated),
so they compose:

#example(````typ
#let g = parse-pgn(
  "1. e4 e5 2. Nf3 Nc6 3. Bb5 (3. Bc4 Bc5) a6 *",
).first()
#chess-notation(
  with-comments(
    with-nags(g, ("3w": "!")),
    (((line: ((at: "3w", into: 0),), at: "3w"), "a sharp try"),),
  ),
  variations: true, nags: true, comments: true,
)
````, stacked: true)

Moves are addressed the same way everywhere — a *mainline* locator (`"3w"`) or a
variation *path* dict — so you can annotate a move *inside* a (nested) variation,
not only the mainline. Two input forms:

- a *dict* `("3w": "!", "5b": "$14")` — mainline moves only (dict keys are strings);
- an *array of `(locator, value)` pairs* — any move, including a path-dict locator
  (as in the example above).

`with-nags` values are a `"$n"` code or a suffix glyph (`! ? !! ?? !? ?!`, sugar
for `$1`–`$6`), or an array of those; `with-comments` values are plain-text
strings. Both *replace* what was on the move. Comments show only with `comments:
true`, NAGs only with `nags: true`.

=== Adding Variations

`with-variation(game, at:, moves:)` grows the tree: it adds a variation as an
*alternative* to the move at `at` (a mainline locator or a path dict). `moves` is
a PGN movetext fragment — the same syntax `parse-pgn` reads — so one call can carry
move numbers (recomputed), nested `()` variations, `$n` NAGs, and `{comments}`; a
plain SAN run like `"Bc4 Bc5"` is the simplest case:

#example(```typ
#let g = parse-pgn("1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 *").first()
#chess-notation(
  with-variation(g, at: "3w",
    moves: "3. Bc4 Bc5! (3... Nf6 4. d4) {a sharp alternative}"),
  variations: true, nags: true, comments: true,
)
```, stacked: true)

The variation is *appended* to the move's variations (its index `into` is the
previous count — `0` for a move with none yet), so you can address into it
afterwards and it composes with `with-nags`/`with-comments`. Together these let you
build a whole annotated tree from a bare game, then render or navigate it exactly
like a parsed PGN. Moves are *not* checked for legality when added — an illegal
move surfaces only if you navigate into the line (`board-after`), matching the rest
of the lazy model.

== Exporting FEN

`to-fen` is the inverse of `parse-fen`. It serialises a position, or a game at a
locator. Standard 8×8 positions round-trip exactly:

#example(```typ
#raw(to-fen(chess-moves(none, "1. e4 e5 2. Nf3")))
```, stacked: true)

== Drawing Annotations in PGNs

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

*With embedded diagrams.* The `diagrams` switch (PGN handling) makes
`notation(diagrams: true)` splice a board after each move whose comment carries a
diagram marker. If that *same* comment also holds `%cal`/`%csl` *and*
`annotations` is on, the spliced board shows those arrows/highlights too — the two
switches compose:

```typ
// 2. Nf3 {[%cal Gf1c4] [%csl Re5] #[After 2.Nf3]} Nc6 ...
#set-pgn-defaults(diagrams: true, annotations: true)
#chess-notation(game)   // ...text, then a board after 2.Nf3 with the arrow + highlight
```

`diagrams` decides *whether* a board appears; `annotations` decides whether it
carries the marks. The marker and the `%cal`/`%csl` must be in the *same* move's
comment. (Only mainline moves are addressed — `notation` renders the mainline.)

== Errors

Malformed PGN is a *hard error*: broken tag syntax and stray variation parens
fail at parse time; illegal, ambiguous, or unparseable moves fail when the
position is navigated. Missing Seven-Tag-Roster tags are tolerated (they default).

// === Tournament tables =======================================================

= Tournament Tables<tournament-tables>

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

// === Outlines and references =================================================

= Outlines and References<outlines-references>

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
(`set-diagram-defaults(outline-title: ..)`). Remember that a bare `board` is not a
figure, so it can be neither referenced nor listed — use a `chess-diagram`.

// === Document-wide style =====================================================

= Document-Wide Style<document-style>

Defaults live in *five* buckets, each with its own setter:

#table(
  columns: (auto, auto, 1fr),
  inset: 6pt,
  align: (left, left, left),
  stroke: 0.5pt + rgb("#d9d9d2"),
  table.header([*bucket*], [*setter*], [*controls*]),
  [board], raw("set-board-defaults"), [square colours, labels, piece set, highlights, arrows, grid, size],
  [diagram], raw("set-diagram-defaults"), [the diagram figure: game-info line, supplement, outline title],
  [table], raw("set-table-defaults"), [the table figure: supplement, outline title, title gap],
  [language], raw("set-lang"), [the document language (also `set-i18n-defaults`)],
  [PGN handling], raw("set-pgn-defaults"), [`annotations` / `nags` / `comments` / `diagrams`],
)

`set-chess-defaults` is the single *umbrella* over *all five* buckets: pass any key
from any bucket — *including* `lang` — and it is routed to the bucket that owns it.

```typ
#set-board-defaults(light: rgb("#eeeed2"), dark: rgb("#769656"), size: 5cm)
#set-lang("de")
#set-pgn-defaults(nags: true)
// ...or all of the above at once, through the umbrella:
#set-chess-defaults(dark: blue, lang: "de", nags: true, info-gap: 1em)
#set-piece-set("merida")    // sugar for set-board-defaults(piece-set: ..)
```

A setter affects *every subsequent* diagram/table; per-call arguments still
override. Every default is equivalently a per-call argument — the same green theme,
set once above vs. passed to one diagram:

#example(```typ
#chess-diagram(
  "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
  light: rgb("#eeeed2"), dark: rgb("#769656"),
  size: 4cm,
)
```)

Two caveats. `flip` is *not* allowed in any defaults setter — orientation is a
per-board choice, so `set-chess-defaults(flip: ..)` is an error. And `supplement` /
`outline-title` live in *both* the diagram and table buckets; the umbrella routes
them to *diagram*, so use `set-table-defaults` for the table ones.

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

== PGN Handling <pgn-handling>

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
  raw("variations"), [splice variations (RAVs) into `notation`, in parentheses],
  raw("bold-mainline"), [render `notation` mainline moves bold (variations stay normal)],
)

Each is also a per-call argument (`auto` → the document default) on `notation` /
`board-after` — as used in the annotations example above.

// === API Reference ===========================================================

#pagebreak()

= API Reference<api-reference>

The reference below serves as a compact and *complete* lookup for every public function's signature, the recurring *argument value shapes*, and the full option lists. The chapters above show each feature in use with a rendered example, this chapter is for answering "what exactly can I
pass" to a function. The `..style` argument list below means *any board style option* (see #link(<board-options>)[Board style options]).

== Argument Value Shapes

A few arguments accept more than one shape and recur across functions, so they are
described once here.

/ `source`: for `board`, `chess-board`, `diagram`, `chess-diagram`, `position` —
  a *FEN string* `"rnbqkbnr/…"`; a *position* dict (from `position` / `parse-fen`);
  a *squares* dict `(e1: "K", d8: (kind: "q", color: "black"), e4: "P")` (piece as a
  long name, kind abbreviation, or bare letter — UPPER white, lower black); or the
  *string form* (rank-per-line rows, `.` = empty; one raw block or several row
  strings). `chess-*` reject a non-standard `variant`.

/ `locator`: for `position-after`, `board-after`, `to-fen`, `move-san`,
  `move-node`, and builder addresses — a *mainline* string `"12w"` / `"12b"`, or a
  *path* dict `(line: (..hops..), at: "<move>")`, each hop `(at: "<move>", into:
  <n>)` (descend into variation `n` at that move), to reach a move inside a (possibly nested)
  variation. `notation`'s `line:` also takes a bare hops array; its `from`/`to` are
  mainline strings only.

/ `size`: a `length` (default: `4cm`), a `ratio` of the available width (default: `60%`), or `auto`.

/ `highlight` entry: a square name `"e4"`; a `(square, color)` pair; or a dict
  `(square:, shape:, color:)` with shape `"filled"` / `"cross"` / `"circle"`.

/ `arrows` entry: `(from, to)`; `(from, to, color)`; or a dict `(from:, to:, color:)`.

/ builder overrides: for `with-nags` / `with-comments` — a *dict* of mainline
  locators (`("3w": v)`) or an *array of `(locator, value)` pairs* (this form also
  takes path-dict locators). A NAG value is `"$n"` or a suffix glyph
  `! ? !! ?? !? ?!` (sugar for `$1`–`$6`), or an array of those; a comment value is
  a plain string.

/ annotation colour letters: for PGN `%cal`/`%csl` and the `annotation-colors`
  map — `G` `R` `Y` `B` `O`.

== Functions

=== Boards and Diagrams

```typ
board(source, flip: false, ..style)
chess-board(source, flip: false, ..style)              // standard-variant sugar
diagram(source, white: none, black: none, event: none, year: none,
        caption: auto, game-info: auto, flip: false, lang: auto, ..style-and-figure)
chess-diagram(source, ..)                               // sugar over diagram
```

`board` draws the bare board; `diagram` wraps it in a captioned, referenceable
`#figure` (kind `"chess"`). `caption: auto` gives a source-specific default (or
`none`); `game-info: auto` draws the automatic "White – Black (Year)" line when
players are known. `diagram` forwards any unknown named argument to `#figure`
(e.g. `placement: top`). `flip` is per-call only — never a document default.

=== Positions

```typ
position(source, ..opts)   // opts: turn, castling, en-passant, halfmove, fullmove, cols, rows, variant
parse-fen(fen)
to-fen(source, locator: none)   // source: a position, or a game addressed by locator
starting-fen                    // constant: the standard start FEN
```

`position` returns `(variant, cols, rows, squares, turn, castling, en-passant,
halfmove, fullmove)`; `parse-fen` returns the same shape. `to-fen` is its inverse.

=== Games (PGN)

```typ
parse-pgn(input)                // -> array of games; input: a string or raw block
movetext(game)                  // -> the parsed move-node tree (lazy, memoised)
mainline(game)                  // -> array of SAN strings
game-result(game)               // -> "1-0" / "0-1" / "1/2-1/2" / "*"
position-after(game, locator)   // -> a position
board-after(game, locator, white: auto, black: auto, year: auto, caption: auto,
            annotations: auto, flip: false, game-info: auto, lang: auto, ..style)
move-san(game, locator)         // -> the SAN of the addressed move
move-node(game, locator)        // -> the full move node (san, nags, comments, variations)
chess-moves(source, moves)      // source: none | FEN | position; moves: text or SAN array
```

A `game` is `(tags, movetext-raw, result)`. Parsing is lazy: `movetext` builds the
tree on demand, the engine runs only when a position is asked for. `chess-moves`
resolves each move against the legal moves (illegal/ambiguous is an error) and
returns the final position; it is mainline-only.

=== Annotate and Build

```typ
with-nags(game, overrides)                  // overrides: dict or array of (locator, value) pairs
with-comments(game, overrides)              // values: plain strings
with-variation(game, at: <locator>, moves: <movetext fragment>)
```

Pure, composable transforms returning a *new* game (the source is never mutated).
`with-variation`'s `moves` is a PGN movetext fragment (nested `()`, `$n`,
`{comments}` allowed); the variation is appended (`into` = previous count).
Legality is checked only on navigation.

=== Notation

```typ
notation(source, from: none, to: none, line: none, figurine: false, lang: auto,
         nags: auto, comments: auto, variations: auto, variation-style: "inline",
         bold-mainline: auto, move-numbers: true, result: false,
         diagrams: auto, annotations: auto)
chess-notation(source, ..)      // standard-variant sugar over notation
```

`source` is a game, a move-text string, or a SAN array. `from`/`to` bound a
mainline slice; `line` renders one addressed variation. `variation-style` is
`"inline"` or `"block"`. `nags`/`comments`/`variations`/`diagrams`/`annotations`
default `auto` (consult `set-pgn-defaults`). Returns a plain string when everything
resolves without document state, else content.

=== Tournament Tables

```typ
standings-table(games, by: "player", tiebreaks: auto,
                match-points: (win: 2, draw: 1, loss: 0),
                title: none, caption: none, supplement: auto, lang: auto, ..table)
crosstable-table(games, by: "player", match-points: (..), title: none, caption: none,
                 supplement: auto, lang: auto, ..table)
progress-table(games, by: "player", match-points: (..), title: none, caption: none,
               supplement: auto, lang: auto, ..table)
games-by-event(games)           // -> games grouped by the Event tag
standings(games, by: "player", tiebreaks: auto, match-points: (..))    // compute -> data
crosstable(games, by: "player", match-points: (..))                    // compute -> data
progress(games, by: "player", match-points: (..))                      // compute -> data
```

`by` is `"player"` or `"team"`. The `*-table` renderers produce a `#figure` (kind
`"chess-table"`); the compute functions return plain data. `title` is a heading
drawn above the table; unknown named args are forwarded to the inner `#table`.

=== Outlines and References

```typ
chess-diagram-outline(title: auto, lang: auto, ..outline)
chess-table-outline(title: auto, lang: auto, ..outline)
chess-outlines(diagram-title: auto, table-title: auto, lang: auto, ..outline)
```

Titles are language-aware by default; extra args are forwarded to `outline`.

=== Document Defaults

```typ
set-chess-defaults(..fields)    // umbrella over ALL five buckets (incl. lang)
set-board-defaults(..fields)    // set-diagram-defaults / set-table-defaults / set-pgn-defaults
set-lang(code)                  // "en" | "de" | … | "auto"
set-piece-set(name)             // sugar for set-board-defaults(piece-set: name)
```

See #link(<board-options>)[Board style options] below for the keys each accepts.
`flip` is rejected by every setter.

== Board Style Options <board-options>

Accepted by `board` / `chess-board` / `diagram` / `chess-diagram` per call, and by
`set-board-defaults` / `set-chess-defaults` document-wide.

#table(
  columns: (2.3fr, 1.5fr, 3.2fr),
  inset: 5pt, align: left + horizon, stroke: 0.5pt + rgb("#d9d9d2"),
  table.header([*option*], [*default*], [*meaning*]),
  raw("size"), raw("auto"), [board size: a `length`, a `ratio` of the width, or `auto`],
  [`light` / `dark`], [tan theme], [the two square fill colours],
  raw("labels"), raw("true"), [show rank/file labels],
  raw("label-font"), [`("Arial", "DejaVu Sans Mono")`], [label font — a family or a fallback list],
  raw("label-mode"), raw("\"on-square\""), [`"on-square"` / `"outside"` / `"border"`],
  [`file-side` / `rank-side`], [`bottom` / `right`], [which edge files / ranks sit on],
  [`file-label-corner` / `rank-label-corner`], [`left` / `right`], [on-square label corner],
  raw("border-theme"), raw("\"square\""), [`"border"` band theme: `"square"` / `"brown"` / `"dark"`],
  raw("border"), [`0.5pt + luma(40)`], [thin board outline (`none` to drop)],
  raw("grid"), raw("false"), [1pt grid lines between squares],
  raw("piece-set"), raw("\"cburnett\""), [SVG set name, or `"unicode"` for the glyph fallback],
  raw("piece-scale"), raw("0.95"), [fraction of a square a piece occupies],
  [`highlight` / `arrows`], raw("()"), [squares / arrows to draw — see the value shapes],
  raw("highlight-shape"), raw("\"filled\""), [default shape for plain-string highlight entries],
  [`highlight-fill` / `highlight-transparency`], [green, `75%`], [filled-highlight colour and its transparency],
  [`cross-color` / `circle-color`], [red / green], [cross / circle stroke colours],
  [`cross-width` / `circle-width`], raw("2pt"), [cross / circle stroke widths],
  [`arrow-color` / `arrow-transparency`], [green, `85%`], [default arrow colour and its transparency],
  raw("arrow-width"), raw("auto"), [arrow shaft width; `auto` scales with the square],
  raw("annotation-colors"), [G/R/Y/B/O map], [PGN `%cal`/`%csl` colour-letter → colour],
  raw("label-color"), raw("luma(90)"), [`"outside"`-mode strip label colour],
  raw("label-border-ratio"), raw("0.07"), [`"border"`-mode band width, as a board fraction],
  [`white-fill` / `black-fill` / `piece-font`], [—], [the `"unicode"` glyph fallback only],
  raw("baseline-inset"), raw("0.20"), [glyph fallback: baseline lift (square fraction)],
)

== Diagram, Table, Language, and PGN-Handling Options

*Diagram* (`set-diagram-defaults`): `info-bold` (`true`), `info-gap` (`0.6em`),
`supplement` (`auto` → localized "Diagram"), `outline-title` (`auto`).

*Table* (`set-table-defaults`): `supplement` (`auto` → "Table"), `outline-title`
(`auto`), `title-gap` (`0.6em`).

*Language* (`set-lang`): `lang` — `"en"` (default), a code (`"de"`, `"es"`, `"fr"`,
`"it"`, `"pt"`, `"ru"`), or `"auto"` (follow `#set text(lang: ..)`).

*PGN handling* (`set-pgn-defaults`): `annotations`, `nags`, `comments`, `diagrams`,
`variations` — all `false` by default; `bold-mainline` defaults `true` (see
#link(<pgn-handling>)[PGN handling]).
