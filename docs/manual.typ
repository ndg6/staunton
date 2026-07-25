// staunton user manual
//
// Every feature is shown as the code you type next to the board it produces, via
// the `example` helper (see docs/manual-tools.typ). Edit this file for any manual
// change; there is no separate markdown copy to keep in sync.
//
// Build:  typst compile --root . docs/manual.typ docs/manual.pdf
//
// Chapter order is deliberately bottom-up: board -> diagram -> position -> games
// -> tables -> outlines -> document-wide defaults.

#import "manual-tools.typ": example
// The manual keeps the package namespaced (via manual-tools) so example snippets
// show realistic unqualified calls; the front-matter figure lists below are the
// one place the manual itself calls the API, so pull in just that function. The
// dev build reads `/lib.typ`; a reader would `#import "@preview/staunton:..": *`.
#import "/lib.typ": chess-diagram-outline, chess-table-outline
#import "@preview/tidy:0.4.1"

// --- compact tidy style ------------------------------------------------------
// tidy's default style leaves a very large gap (4.8em) between successive
// functions and wraps each parameter in a grey 10pt-inset block. We keep the
// same content but tighten the vertical rhythm and reuse the manual's own
// inline-code tint (#f0f0ec) for parameter blocks, so the generated API pages
// sit closer to the hand-written chapters. We override only three of the style
// functions and borrow the rest from `tidy.styles.default`.
#let _td = tidy.styles.default

#let _compact-param-block(
  function-name: none, name, types, content, style-args,
  show-default: false, default: none,
) = block(
  inset: (x: 8pt, y: 7pt), fill: rgb("#f0f0ec"), width: 100%, radius: 2pt,
  breakable: style-args.break-param-descriptions,
  [
    #box(heading(level: style-args.first-heading-level + 3, name))
    #if function-name != none and style-args.enable-cross-references {
      label(function-name + "." + name.trim("."))
    }
    #h(1.2em)
    #types.map(x => (style-args.style.show-type)(x, style-args: style-args)).join([ #text("or", size: .6em) ])

    #content
    #if show-default [ #parbreak() #style-args.local-names.default: #raw(lang: "typc", default) ]
  ],
)

#let _compact-function(fn, style-args) = {
  if style-args.colors == auto { style-args.colors = _td.colors }
  [
    #heading(fn.name, level: style-args.first-heading-level + 1)
    #if style-args.enable-cross-references { label(style-args.label-prefix + fn.name + "()") }
  ]
  tidy.utilities.eval-docstring(fn.description, style-args)
  block(breakable: style-args.break-param-descriptions, {
    heading(style-args.local-names.parameters, level: style-args.first-heading-level + 2)
    (style-args.style.show-parameter-list)(fn, style-args: style-args)
  })
  for (name, info) in fn.args {
    if style-args.omit-private-parameters and name.starts-with("_") { continue }
    let description = info.at("description", default: "")
    if description == "" and style-args.omit-empty-param-descriptions { continue }
    (style-args.style.show-parameter-block)(
      name, info.at("types", default: ()),
      tidy.utilities.eval-docstring(description, style-args), style-args,
      show-default: "default" in info,
      default: info.at("default", default: none),
      function-name: style-args.label-prefix + fn.name,
    )
  }
  v(1.6em, weak: true)
}

#let _compact-variable(var, style-args) = {
  if style-args.colors == auto { style-args.colors = _td.colors }
  let type = if "type" not in var { none } else { (style-args.style.show-type)(var.type, style-args: style-args) }
  stack(dir: ltr, spacing: 1.2em,
    [
      #heading(var.name, level: style-args.first-heading-level + 1)
      #if style-args.enable-cross-references { label(style-args.label-prefix + var.name) }
    ],
    type,
  )
  tidy.utilities.eval-docstring(var.description, style-args)
  v(1.6em, weak: true)
}

#let compact-style = (
  show-outline: _td.show-outline,
  show-type: _td.show-type,
  show-function: _compact-function,
  show-parameter-list: _td.show-parameter-list,
  show-parameter-block: _compact-param-block,
  show-reference: _td.show-reference,
  show-example: _td.show-example,
  show-variable: _compact-variable,
)

// API-reference helper: render a CURATED, ordered list of functions/variables —
// possibly spanning several source modules — from their `tidy` docstrings
// (signature + each parameter's type and default). `entries` is an array of
// `(file, name)`, `file` root-absolute. Only the named items are shown, so private
// `_` helpers never appear. Each module is parsed once and cached.
#let show-fns(entries, level: 3) = {
  let cache = (:)
  let base = none
  let fns = ()
  let vars = ()
  for (file, name) in entries {
    if file not in cache { cache.insert(file, tidy.parse-module(read(file), old-syntax: true)) }
    let m = cache.at(file)
    if base == none { base = m }
    let f = m.functions.find(fn => fn.name == name)
    if f != none { fns.push(f) } else {
      let v = m.at("variables", default: ()).find(x => x.name == name)
      assert(v != none, message: "show-fns: `" + name + "` not found in " + file)
      vars.push(v)
    }
  }
  base.functions = fns
  base.variables = vars
  // tidy emits its own function/variable headings; leave them unnumbered so the
  // API reference doesn't grow odd counters like "10.2.0.1" under the manual's
  // own "1.1" scheme.
  set heading(numbering: none)
  tidy.show-module(
    base, first-heading-level: level, show-outline: false, sort-functions: none,
    style: compact-style,
  )
}

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

// Running chapter title for the header (right side): the FIRST level-1 heading
// that starts on the current page; if none starts here, the LAST one seen on an
// earlier page. So a page carrying "Introduction" then "The Board" shows
// "Introduction", and the next page (no new chapter) shows "The Board". (None
// while still in the front matter, before the first chapter.) Only numbered
// chapters count — the part dividers ("User Guide" / "API Reference" / "Appendix")
// are level-1 headings too but carry `numbering: none`, so they never appear here.
#let _running-chapter = context {
  let pg = here().page()
  let h1 = query(heading.where(level: 1)).filter(h => h.numbering != none)
  let on-page = h1.filter(h => h.location().page() == pg)
  if on-page.len() > 0 { on-page.first().body } else {
    let earlier = h1.filter(h => h.location().page() < pg)
    if earlier.len() > 0 { earlier.last().body } else { none }
  }
}

// --- parts: a hierarchy level ABOVE chapters ---------------------------------
// `part(..)` emits an *unnumbered* level-1 heading; chapters stay numbered
// level-1 headings, so their 1, 2, 3 counter runs unbroken across the parts (an
// unnumbered heading neither takes a number nor increments the counter). A part
// therefore never shows in the running header either (that filters
// `numbering != none`). The show rule below gives a part its banner look; a
// numbered level-1 heading — a chapter — falls through to Typst's default.
#let part(body) = [#heading(level: 1, numbering: none, outlined: true)[#body]]
#show heading.where(level: 1): it => {
  // A part is unnumbered AND outlined (see `part`); an outline's own title is
  // also an unnumbered level-1 heading but is `outlined: false`, so it falls
  // through to default rendering — no banner, no page break.
  if it.numbering == none and it.outlined {
    pagebreak(weak: true)
    v(2.2cm)
    align(center, text(size: 24pt, weight: "bold", it.body))
    v(0.5em)
    align(center, box(width: 28%, divider()))
    v(1.1cm)
  } else {
    it
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
    #link("https://github.com/ndg6/staunton")[#text(size: 11pt, fill: rgb("#555"), font: "DejaVu Sans Mono")[https://github.com/ndg6/staunton]]
    #v(8pt)
    #text(size: 10pt, fill: rgb("#666"))[User manual · package version 0.2.2]
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
      align(center)[#here().page() / #counter(page).final().first()]
    }
  },
)

// Front-matter table of contents. Level-1 entries come in two kinds and are
// styled apart: a PART divider (unnumbered — "User Guide" / "API Reference" /
// "Appendix") reads as a larger group header, while a numbered chapter is set
// bold with its level-2 sections indented beneath. Parts and chapters share the
// level-1 indent (parts are separators, not a deeper nesting). This only concerns
// the heading TOC; the front-matter figure lists (List of Diagrams / Tables) are
// also level-1 entries but of figures, so leave those at the default outline look.
#show outline.entry.where(level: 1): it => {
  if it.element.func() != heading { return it }
  if it.element.numbering == none {
    v(1.1em, weak: false)                 // strong gap above a new part
    strong(text(size: 1.1em, it))
    v(0.45em, weak: false)
  } else {
    v(0.55em, weak: false)                // firm gap above a new chapter
    strong(it)
    v(0.2em, weak: false)                 // small gap before its level-2 children
  }
}

#align(center, text(size: 15pt, weight: "bold")[Contents])
#v(0.6em)
#outline(title: none, depth: 2, indent: auto)

// Dogfood the package's own figure outlines: list the manual's diagrams and
// tables. We draw the two titles ourselves (identical to "Contents" above) and
// pass `title: none`, so no outline-title heading is emitted — the lists flow
// together on one page with no part-style banner or page break. Their figure
// entries keep the default outline look (the chapter-TOC rule skips non-headings).
#v(0.4em)
#align(center, text(size: 15pt, weight: "bold")[List of Diagrams])
#v(0.6em)
#chess-diagram-outline(title: none)
#v(1.2em)
#align(center, text(size: 15pt, weight: "bold")[List of Tables])
#v(0.6em)
#chess-table-outline(title: none)

#pagebreak()

#part[User Guide]

// === Introduction ============================================================

= Introduction<introduction>

Package *staunton* aims to provide a complete, convenient and flexible solution
for chess publications. It provides a full set of features, including:

- *boards and diagrams* — bare boards with labels, highlights, arrows, an optional grid, 
  flexible sizing, custom colors, and bundled SVG piece sets (or a Unicode fallback); and building on that diagrams with captions, figure counters, and referenceable labels;
- *games from PGN* — a sophisticated parser creates single games or an array of games from a PGN file,  
  from which you create positions by using move "locators" (mainline and variations). You can also 
  play out moves from start positions and export resulting positions as FEN strings;
- *move notation* — from parsed games you create move text output with localized piece letters,
  figurine glyphs, NAGs (numeric annotation glyphs, the standard `$n` move-assessment codes), comments and diagrams embedded inline;
- *tournament tables* — we can create standings, cross-tables and progress charts from a PGN's
  results, by player or by team;
- *Chess960 / Fischer Random Chess* — the same board, engine, PGN pipeline and notation
  handle chess960, with X-FEN castling, the FRC PGN tags, and start-by-number instead of FEN (see @chess960);
- *outlines and references* — diagrams and tables get their own counters and lists;
- *document-wide styling* and *localization* (six languages, easily extended);
- *limited HTML export* — notation, tables, outlines, references and captioned
  figures become native HTML, with boards and diagrams embedded as inline SVG
  (see @html-export).

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
references*, and the *document-wide defaults*.

== Installing and Importing

*staunton* is a Typst package. Import its public API once and every function in this
manual is in scope:

```typ
#import "@preview/staunton:0.2.2": *
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
primary building block every diagram builds on. `source` is one of: a *FEN string*; a
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
for a *diagram* (@diagrams) when you want a captioned, referenceable figure.

The rest of this chapter covers the board's drawing options: labels, highlights,
arrows, the grid, coordinates, size, colors, orientation, and piece sets — all of
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

In `"border"` mode, `border-theme` picks the band's look — the fill color and the
contrasting label color:

- `"square"` (default) — the band reuses the board's own `dark` square color with
  `light`-colored labels, so the border blends into the board;
- `"brown"` — a very dark-brown band with creme labels (a warm, classic frame);
- `"dark"` — a charcoal band with light-grey labels (suits dark backgrounds).

`border-theme` is a normal board option: set it per call as above, or document-wide
with `set-board-defaults(border-theme: ..)` / `set-chess-defaults` (see
@document-style). It only takes effect with `label-mode: "border"`.

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

== Move Markings

Two optional markings annotate the *move* rather than arbitrary squares. Both are
*off by default* and their colors are settable per call or via
`set-board-defaults`.

`check: true` draws a radial glow (`check-color`, default red, fading to
transparent) *under* the king that is in check. On a standard position the checked
king is located automatically — you only flip the switch (see the combined example
below).

`move-quality: true` draws a small disc near the *upper-right* of the last move's
destination square, carrying its assessment: `!` / `!!` (good, blue), `?` / `??`
(bad, red), `!?` / `?!` (interesting, green), text always white. The disc clears the
piece and spills slightly into the neighbours; recolor the categories with
`move-quality-colors`.

A badge is tied to a *move*, so it is only available when you draw *from a game*:
`diagram-after` derives it from the addressed move itself and places it on that
move's destination. (A bare `board` / `chess-board` has no move, so it cannot carry
a badge — setting `move-quality-mark` there is an error.) The assessment is read
identically whether written as a literal `?!` suffix, a PGN NAG, or set with
`with-nags`. Here the mate `4.Qxf7#` glows on the Black king and, tagged `!`
programmatically, wears a good-move badge on `f7`:

#example(```typ
#let g = parse-pgn(
  "1. e4 e5 2. Qh5 Nc6 3. Bc4 Nf6?? 4. Qxf7# 1-0",
).first()
#diagram-after(
  with-nags(g, ("4w": "!")), "4w",
  check: true, move-quality: true, size: 4cm,
)
```)

== Coordinates and Non-Square Boards

At least in standard western chess, files run `a`, `b`, … and ranks `1`, `2`, …; `a1` is the dark square in the lower-left corner, `h8` the upper-right. Square names are case-insensitive
(`"E4"` = `"e4"`).

But boards are *not* tied to an 8×8 layout. A `position` built from the string form (@positions)
counts its own columns and rows, and the renderer draws whatever geometry
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

== Colors

`light` and `dark` set the two square colors:

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

Shown side by side with `"border"` labels, the flipped coordinates are easy to
spot — `a1` moves from the lower-left to the upper-right:

#example(```typ
#grid(columns: 2, gutter: 8pt,
  board("8/8/8/3k4/3K4/8/8/8",
    label-mode: "border", border-theme: "brown", size: 3.4cm),
  board("8/8/8/3k4/3K4/8/8/8", flip: true,
    label-mode: "border", border-theme: "brown", size: 3.4cm),
)
```, stacked: true)

== Piece Sets and Fonts

Pieces are normally drawn from bundled *SVG piece sets* — this is the preferred rendering, since
vector art stays crisp at any board size and looks the same across platforms.
A *Unicode glyph* set is provided only as a *fallback* (see below), for when you
want no SVG dependency or a font-native look.

Two SVG sets ship with the package: `cburnett` (default) and `merida`. Both are
distributed under a license that *permits commercial use* (GPLv2+) — a deliberate
constraint: staunton only bundles piece art whose license does not forbid
commercial publication, so you can use it freely in commercial work. Choose one
with `piece-set:` per board, or document-wide with `set-piece-set` (see
@document-style):

#example(```typ
#let pos = "2kr3r/ppp2ppp/2n1bn2/3q4/3P4/2NB1N2/PPPQ1PPP/R4RK1"
#grid(columns: 3, gutter: 8pt, align: bottom,
  board(pos, size: 3.4cm, piece-set: "cburnett"),
  board(pos, size: 3.4cm, piece-set: "merida"),
  board(pos, size: 3.4cm, piece-set: "unicode"),
)
```, stacked: true)

`piece-set: "unicode"` (or `none`) selects the glyph fallback — solid Unicode chess
glyphs distinguished by fill and a contrasting stroke; it needs a font carrying them.

=== The label font<label-font>

The rank/file *labels* are drawn in their own sans-serif, set by the `label-font`
board option (a family or a fallback list), independent of the document font. The
default is `("Arial", "DejaVu Sans Mono")` — Arial on Windows/macOS, falling back
to Typst's always-embedded mono — so a stock install draws labels without
"unknown font family" warnings. Override it like any board default:

```typ
#set-board-defaults(label-font: "Segoe UI")   // or a list, e.g. ("Helvetica", "DejaVu Sans Mono")
```

=== Bringing your own piece art<custom-piece-sets>

You are not limited to the bundled sets. Many more are downloadable — a good
source is the lichess piece library @lichess-pieces — and a set's license often
lets you *use* it but not *redistribute* it, which is exactly why staunton can draw
artwork you supply rather than trying to bundle everyone's. You hand it the images and *staunton*
draws them. The same mechanism serves a restyled *standard* set and the
non-standard pieces of @fairy-pieces.

One obstacle is Typst's file sandbox: code inside an installed package can only
read files from *its own* directory, never from your project, and no `.typ` can
read files *above* the compilation root#footnote[The *compilation root* is the top
of the directory tree Typst is allowed to read from — by default the directory of
the document being compiled. Set it explicitly with `typst compile --root <dir>`
(commonly `--root .`); no `read()` may reach above it.]. So staunton cannot go
hunting for a folder of artwork on its own — *you* pass `piece-set` a _loader_: a
function `(color, kind)` returning the image bytes, with the `read()` written *in
your document*, where paths resolve against your project root (a packaged
staunton's own `read()` would look inside the package instead).

*The easy case — a lichess-style set.* If your set is twelve SVGs named
`{w,b}{K,Q,R,B,N,P}.svg` (`wK.svg`, `bN.svg`, …), `svg-piece-set` does the naming
for you; you supply only a one-line reader saying *where* the files are. Set it
once as the document default and every later board uses it:

```typ
// Put the set's twelve SVGs somewhere under your project, e.g. assets/pieces/alpha/.
#set-piece-set(svg-piece-set(f => read("/assets/pieces/alpha/" + f, encoding: none)))

#board("...")   // and every board after uses alpha
```

Typst memoizes file reads, so each SVG is loaded once however many boards use it.

*Any other naming scheme.* Downloaded sets don't all agree on filenames, and a
folder you had to symlink in may be read-only with names you cannot change.
`named-piece-set` adapts to whatever scheme through a filename *pattern* you supply
— `svg-piece-set` is simply its `"{c}{K}.svg"` shorthand:

```typ
#named-piece-set(f => read("/assets/pieces/alpha/" + f, encoding: none),
                 pattern: "{kind}_{color}.svg")   // e.g. king_white.svg, knight_black.svg
```

The pattern's placeholders are `{kind}` (long name), `{color}` / `{c}` (long /
short color) and `{K}` / `{k}` (the kind's letter, upper / lower); the default is
`"{kind}_{color}.svg"`. If the files follow *no* tidy pattern at all, skip the
helper and pass `piece-set` a bare loader `(color, kind) -> bytes | content` that
does the naming itself — or a *dictionary* keyed `"<color>-<kind>"` (e.g.
`"white-king"`) mapping to bytes or ready-made `image(..)` content, in which case
only the pieces your positions actually use need be present.

*Only some pieces your own.* To restyle just a few pieces — or, in @fairy-pieces,
to add non-standard kinds to an otherwise standard board — wrap your
loader in `with-fallback`: the standard six come from a bundled set (cburnett by
default) and every other kind from your loader.

*Art outside the project.* If the art lives outside your project tree (a shared
system folder, say), Typst refuses to read it (“would escape the project root”).
Two compile-time fixes: run `typst compile` with `--root` set to a common ancestor
of your document and the art, or symlink the folder into your project. A missing
or misnamed file fails with Typst's own “file not found”, naming the exact path.

=== Non-standard pieces<fairy-pieces>

Beyond the six western pieces you can define *your own* kinds — non-standard
pieces, also known as _fairy_ pieces, such as the alfil, dabbaba or ferz — and
place them on a board, mixed with the standard pieces if you like. The support is
deliberately limited to *drawing*: there is no FEN, PGN, move generation or
legality for custom kinds. You place them by hand — a squares dict or the string
form — and render them; that is all.

Two structural assumptions still hold, whatever the pieces: the board is a
*rectangular* grid of *square* cells, and there are exactly *two* piece colors
(white and black). Non-square fields, hexagonal boards or a third side are out of
scope.

Two things are needed: a *vocabulary* that names the kinds and their letters, and
the *art* to draw them.

*Defining the kinds.* `define-variant` builds a custom *variant* you bind once and
pass to `position` as its `variant:` argument. The easiest form `extends` the
standard variant — inheriting the six kinds and their letters — and adds only the
new ones. Each new kind takes a single lower-case letter that must not clash with
an existing one (case selects color, exactly as for the standard pieces):

```typ
#let fairy = define-variant("Fairy demo",
  extends: "standard",
  kinds: ("alfil", "dabbaba", "ferz"),
  abbr:  (a: "alfil", d: "dabbaba", f: "ferz"),   // letters must not overlap
)
```

Now `position(.., variant: fairy)` understands `A`/`a`, `D`/`d` and `F`/`f` in
both the squares-dict and string forms, right beside the standard `K`, `P`, ….
`define-variant` validates *eagerly*, so an overlapping letter or an unknown kind
is caught at the definition. (A variant is a *value* you reuse, not a global name —
Typst has no mutable registry a position parser could read; built-in variants like
`"standard"` are still named by string. An inline spec dict works too, wherever a
variant is expected.)

*Drawing the kinds.* A bundled set *name* (`"cburnett"`) knows only the six western
pieces, so a fairy board is drawn from a *loader* — exactly as for your own piece
art (@custom-piece-sets), pointed at your fairy SVGs. Use `named-piece-set` with a
`pattern` matching your filenames, and, for a *mixed* board, wrap it in
`with-fallback` so the standard kinds come from a bundled set and every custom kind
from your loader:

#example(```typ
// fairy art named "alfil_white.svg", "dabbaba_black.svg", … under the project
#let art = with-fallback(named-piece-set(
  f => read("/docs/assets/fairy/" + f, encoding: none),
))

#let fairy = define-variant("Fairy demo",
  extends: "standard",
  kinds: ("alfil", "dabbaba", "ferz"),
  abbr:  (a: "alfil", d: "dabbaba", f: "ferz"),
)

#board(
  position((e1: "K", e8: "k", c3: "A", d4: "d", f5: "F"), variant: fairy),
  piece-set: art, size: 4.6cm,
)
```, stacked: true)

_Fairy art above, Wikimedia Commons, CC BY-SA 4.0: alfil (elephant) and ferz from
the Xogos da Meiga chess icons family by Iago Casabiell González @fairy-art;
dabbaba by Kwamikagami @fairy-art-dabbaba. Per-file credits in
`docs/assets/fairy/ATTRIBUTION.md`._

*A glyph instead of art.* When you have no SVG for a kind, give the variant a
`glyphs:` map from kind to a text glyph; then `piece-set: "unicode"` draws that
glyph while the standard kinds keep their built-in ones. Unicode assigns code
points to only a handful of fairy pieces, so you supply whatever glyph you like —
typically a character from a font you embed with `set text(font: ..)`:

```typ
#let fairy = define-variant("Amazon demo",
  extends: "standard",
  kinds: ("amazon",), abbr: (a: "amazon"),
  glyphs: (amazon: "🨊"),          // any glyph your font carries
)
#board(position((d4: "A"), variant: fairy), piece-set: "unicode")
```

// === Diagrams ================================================================

= Diagrams<diagrams>

`chess-diagram(source, ..)` wraps a board in a `#figure` (kind `"chess"`), so —
unlike a bare `board` — it is captioned, counted, referenceable, and listed by an
outline. `source` is the same FEN / position / squares the board takes, and it
accepts every board option documented in @board.

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

*Automatic captions.* Omit `caption:` and staunton supplies a source-appropriate
default. A *game* (`diagram-after`) knows the move just played, so its caption
names it — `Position after 23... Nf6`. A bare *FEN* or *position* is only a
snapshot, with no move history, so it can state only whose turn it is —
`White to move` / `Black to move`. A manual squares dict has neither and gets no
default caption. Pass your own `caption:` to override, or `caption: none` to drop
it.

`chess-diagram` is the standard-chess sugar over the generic `diagram`; both take
the same source and overrides as `board`. Extra named arguments are forwarded to
`figure` (e.g. `placement: top`).

The distinction matters: a bare `board` is plain content — it has *no* caption,
*no* figure counter, does *not* resolve `@`-references, and is *not* listed by
`chess-diagram-outline`. Only a *diagram* is a figure. So draw a `board` for an
inline or decorative position, and a `chess-diagram` whenever you want to caption
it, cross-reference it (`@label`), or list it — see *Outlines and references*.

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

`position` and `parse-fen` both return a dict of the same shape:

```
(variant, cols, rows, squares, turn, castling, en-passant, halfmove, fullmove)
```

The `cols` / `rows` are counted from the string form (otherwise the 8×8 default).

// === Games (PGN) =============================================================

= Games (PGN)<games>
The predominant form for distributing and publishing chess games (at least for
western chess) is the _PGN file_. PGN stands for *Portable Game Notation*
@pgn-spec: a human-readable text format that chess software can parse. A PGN file
holds the moves of a game together with metadata such as player names, event, date
and result, and may contain a single game or many.

Package *staunton* also reads *Chess960 / Fischer Random* games — the variant tags and
start-by-number are covered in @chess960; everything in this chapter applies to
them unchanged.

The `parse-pgn` function returns an *array of games*; `.first()` takes the first one. Read an external file with `read` in your own file, or pass an inline raw block. The examples below assume an already parsed game is in scope:

```typ
#let game = parse-pgn(read("game.pgn")).first()
```

Parsing is *lazy*: the roster (`tags`), the `result`, and the verbatim
`movetext-raw` are extracted cheaply; the move tree is built on demand by
`movetext(game)`; the move parser / generator engine runs only when you ask
for a position. So a tournament file read only for results and never tokenises movetext.

`chess-notation(game)` renders the moves (as text) the game already holds, and
`diagram-after(game, loc)` renders a *diagram* (a referenceable `#figure`, like
`chess-diagram`) of the position at a locator:

#example(```typ
#chess-notation(game)
```, stacked: true)

#example(```typ
#diagram-after(game, "3w", size: 4cm)
```)

== Locators

A *locator* addresses one position in a game. The simple form is a string —
`"30w"` / `"30b"`, the position after White's / Black's 30th *mainline* move.
`position-after(game, loc)`, `diagram-after(game, loc, ..)`, and
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
#diagram-after(
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
*final* position, never mutating the source. The result is a *position*, not a
game: it carries no move history, roster or PGN — for those, parse a game
(@games).

#example(```typ
#chess-diagram(
  chess-moves(none, "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6"),
  size: 4cm,
)
```)

== Naming Moves as SAN<naming-moves-san>

`chess-moves` plays SAN onto a position; `move-to-san(position, move)` runs the
engine the other way. Given a position and a concrete move dict — one produced
by `legal-moves` or `san-to-move` — it returns canonical English SAN: minimal
PGN-standard disambiguation, en passant written as a plain capture, side-based
castling (Chess960-safe), and the `+`/`#` suffixes. An illegal move dict is a
hard error. This is what lets *computed* moves be *named* — a legal-move
listing, a puzzle solution built move by move, or movetext assembled without a
PGN in hand:

#example(```typ
#let pos = chess-moves(none, "1. e4 e5 2. Nf3")
#raw(legal-moves(pos).map(m => move-to-san(pos, m)).join(", "))
```, stacked: true)

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
`"12w"` locators, not the variation *path* form that `diagram-after` takes
(rendering variations is a separate control — see @variations). A `from` past
the end or a `to` before `from` is a hard error.

Other options: `move-numbers`, `result`, `bold-mainline` (render the mainline moves
bold to set them off from variations — see *Variations*), and — for a *game*
source — `nags` / `comments`. The last three consult the PGN-handling defaults.
Localization substitutes only the piece letters; files, ranks, captures, check
marks and `O-O` are untouched.

=== Variations<variations>

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
(the same `diagram-after` shape, or just its hops array) that descends into the
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
move surfaces only if you navigate into the line (`diagram-after`), matching the rest
of the lazy model.

== Exporting FEN

`to-fen` is the inverse of `parse-fen`. It serialises a position, or a game at a
locator. Standard 8×8 positions round-trip exactly:

#example(```typ
#raw(to-fen(chess-moves(none, "1. e4 e5 2. Nf3")))
```, stacked: true)

For Chess960 positions `to-fen` emits *X-FEN* — a rook-file castling letter when
`KQkq` would be ambiguous — and it writes en-passant targets strictly; see @chess960.

== Drawing Annotations in PGNs

PGN comments can carry drawing annotations — `[%cal …]` for arrows, `[%csl …]`
for highlights. Processing is *off by default*; opt in per call with
`annotations: true` (or document-wide with `set-pgn-defaults` — see @pgn-handling).
The demo game annotates its 2nd move:

#example(```typ
// move 2: {[%cal Gf3e5] [%csl Re5]}
#diagram-after(game, "2w", annotations: true, size: 4cm)
```)

The color letters (`G R Y B O`) resolve through the `annotation-colors` board
style; annotations merge with any `arrows` / `highlight` you pass explicitly.

*PGN marks and your own marks, combined.* The two sources add up — the marks a PGN
comment carries (`annotations: true`) and the `arrows` / `highlight` you pass on the
same call are drawn *together* on one board. So you can take an author's annotated
game and layer your own emphasis on top without editing the PGN. Here the green
`f3→e5` arrow and red `e5` highlight come from the comment, while the `b1→c3` arrow
and the circle on `d4` are added programmatically:

#example(```typ
#diagram-after(game, "2w",
  annotations: true,                              // Gf3e5 + Re5, from the PGN
  arrows: (("b1", "c3"),),                        // added here
  highlight: ((square: "d4", shape: "circle"),),  // added here
  size: 4cm,
)
```, stacked: true)

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

== PGN Handling <pgn-handling>

The switches above — `annotations`, `nags`, `comments`, `diagrams`, `variations`,
`bold-mainline` — form the *PGN-handling* group: they decide how much of a parsed
game's embedded extras get interpreted at render time. Parsing itself stays
lossless; these only decide what is *processed*, and (except `bold-mainline`)
*all default off*. Each is a per-call argument (`auto` → the document default) on
`notation` / `diagram-after`, or a document-wide default via `set-pgn-defaults`:

```typ
#set-pgn-defaults(annotations: true, nags: true, comments: true)
```

#table(
  columns: (auto, 1fr),
  inset: 6pt,
  align: (left, left),
  stroke: 0.5pt + rgb("#d9d9d2"),
  table.header([*key*], [*effect*]),
  raw("annotations"), [`%cal`/`%csl` → arrows/highlights on `diagram-after`],
  raw("nags"), [render NAGs (`Nf3!`, `d4⩲`) in `notation`],
  raw("comments"), [include comment prose in `notation`],
  raw("diagrams"), [embed a board in `notation` after each move marked for one],
  raw("variations"), [splice variations (RAVs) into `notation`, in parentheses],
  raw("bold-mainline"), [render `notation` mainline moves bold (variations stay normal)],
)

*Why most of these default off.* For a typical publication you want clean, readable
move text: the mainline, set as prose. A PGN's *embedded diagrams*, *drawing
annotations*, and free-form *comments* are usually working notes that would clutter
that output, so they stay off unless you deliberately ask for them. *NAGs* sit in
between — a `!` or `⩲` is often wanted in a published line — but they, too, default
off so nothing appears that you didn't request. *Variations*, by contrast, are a
first-class part of chess writing: staunton fully supports them, and whether a
render shows *only the mainline* or *the variations as well* is exactly the choice
`variations` gives you (per call, or document-wide) — see *Variations* under
@games. In short: parsing keeps everything; rendering shows only what you opt into.

`set-chess-defaults` routes these same keys through its umbrella, alongside the
board, diagram, table and language buckets — see @document-style.

== Errors

Malformed PGN is a *hard error*: broken tag syntax and stray variation parens
fail at parse time; illegal, ambiguous, or unparseable moves fail when the
position is navigated. Missing Seven-Tag-Roster tags are tolerated (they default).

// === Chess960 / Fischer Random ==============================================

= Chess960 / Fischer Random<chess960>

*staunton* supports #link("https://en.wikipedia.org/wiki/Chess960")[Chess960]
(a.k.a. Fischer Random / FRC). It is *not* a separate system: the same board,
pieces, position model (@positions), rules engine, PGN parser and notation output
(@games) all handle it. Only two things differ — a game starts from one
of the 960 back-rank arrangements, and *castling is generalised* (the king and
its rook may begin on other files). So most of this manual already applies; this
chapter covers just the 960-specific pieces.

== Boards and start positions

`chess960-board` and `chess960-diagram` are the variant-named entry points —
identical rendering to `chess-board` / `chess-diagram`, but they document the
variant. Get a start position by its Scharnagl *number* — the standard indexing of
the 960 back-rank arrangements @scharnagl, running `0`–`959` (`518` is standard
chess) — with `chess960-start` (a position) or `chess960-start-fen` (its FEN):

#example(```typ
#chess960-diagram(chess960-start(356), size: 4cm)
```)

== X-FEN castling

`parse-fen` and `to-fen` speak *X-FEN*, the Chess960-compatible extension of FEN.
On input a castling right may be written as the rook's *file letter* (`A`–`H` /
`a`–`h`) instead of `K`/`Q`; on output `to-fen` still writes plain `KQkq` whenever
it is unambiguous, and switches to the file letter only when it is not — for
instance when another rook stands *outside* the castling rook on its side. In the
game below the white a1-rook travels `a1→a3→h3→h1`, so before `11.O-O` White has
rooks on g1 *and* h1 with the king still on e1; the king-side castling rook is the
inner one on g1, which X-FEN spells `G`:

#example(```typ
#raw(to-fen(frc, locator: "10b"))
```, stacked: true)

== Games

A Chess960 PGN must be marked `[Variant "Chess960"]` or `[Variant "Fischerrandom"]`,
usually with `[SetUp "1"]`, and declares its start *exactly one way*: an `[FEN]`
tag, or a position number in an `[FRCPosition N]` / `[Chess960Position N]` tag
(giving both is an error). `game-variant` reports a parsed game's variant and
`game-start` resolves its start position:

#example(```typ
#game-variant(frc)
```, stacked: true)

Everything else is unchanged — locators, `chess-notation`, `diagram-after`, move
play-out and FEN export all behave as in @games. Here is the position right after
White castles king-side: the king lands on g1 and the g1-rook on f1, the
generalised 960 castling (the h1-rook stays put):

#example(```typ
#diagram-after(frc, "11w", size: 4cm)
```)

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
#standings-table(games, by: "player", caption: [Final standings.])
```, stacked: true)

`crosstable-table` renders the round-robin grid (it *requires* a complete
round-robin and errors otherwise — use standings + progress for Swiss/league):

#example(```typ
#crosstable-table(games, by: "player", caption: [Round-robin cross-table.])
```, stacked: true)

`progress-table` shows the round-by-round running score (needs the `Round` tag):

#example(```typ
#progress-table(games, by: "player", caption: [Round-by-round progress.])
```, stacked: true)

Each renderer takes `caption` (used by refs and the outline), `title` (a heading
above the table), `supplement`, and `lang`. The compute functions (`standings`,
`crosstable`, `progress`) are also public, returning plain data for custom
layouts. *Team* mode groups games by the `Round = "round.board"` convention into
matches.

== Styling

The three `*-table` renderers share a curated set of styling fields. Each is
settable *per call* (as a keyword argument on `standings-table`,
`crosstable-table`, or `progress-table`) or *document-wide* via
`set-table-defaults(..)` (see @document-style) — a per-call value always wins.
The defaults below reproduce the classic look shown earlier in this chapter.

```typ
// document-wide, affects every table rendered from here on:
#set-table-defaults(grid: "header-rule", header-fill: "gray", body-fill: "zebra")
```

// Justification off for this table only: the columns are narrow enough that the
// document-wide `par(justify: true)` tears visible gaps into short cells.
#[
#set par(justify: false)
#table(
  // `values` is a fraction, not `auto`: left to size itself it claimed whatever
  // its longest entry needed and squeezed `effect` to an unreadable ribbon.
  // Wrapping inside `values` is fine, `effect` is the column that must breathe.
  columns: (auto, 0.85fr, 1.45fr),
  inset: 6pt,
  align: (left, left, left),
  stroke: 0.5pt + rgb("#d9d9d2"),
  table.header([*field*], [*values*], [*effect*]),
  [`grid`], [`"complete"` (default) / `"no-outer"` / `"header-rule"`], [rule preset: full grid / inner lines only, no outer border / a single rule between header and body],
  [`header-align`], [`center` (default) / `left` / `right`], [alignment of the header row],
  [`header-fill`], [`none` (default) / `"gray"` / a color], [header row fill],
  [`body-align`], [`center` (default) / `left` / `right`], [alignment of the data columns (the name column stays left-aligned)],
  [`body-fill`], [`none` (default) / `"zebra"` / a color], [body row fill: `"zebra"` alternates light-gray rows; a plain color is used *as* the alternating shade (not a solid body fill). On a crosstable the self/self diagonal gets a distinct light-blue tint instead, so it stays legible],
  [`table-align`], [`center` (default) / `left` / `right`], [page alignment of the *table* (the caption stays centered at full page width — see note below)],
  [`caption-bold`], [`false` (default) / `true`], [bold the caption text],
  [`highlight-winners`], [`true` (default) / `false`], [bold the rank-1 entity's name and points],
)
]

The default standings table again, for comparison:

#example(```typ
#standings-table(games, by: "player", caption: [Default styling.])
```, stacked: true)

A single header rule instead of a full grid, with a shaded header row:

#example(```typ
#standings-table(
  games, by: "player",
  grid: "header-rule", header-fill: "gray",
  caption: [Header rule + shaded header.],
)
```, stacked: true)

Zebra body rows on a crosstable (note the self/self diagonal keeps its own
light-blue tint so it stays legible):

#example(```typ
#crosstable-table(games, by: "player", body-fill: "zebra", caption: [Zebra body rows.])
```, stacked: true)

A left-aligned table (the caption stays centered) with a bold caption, and
`highlight-winners` turned off so the winner's name and points are no longer
bolded:

#example(```typ
#standings-table(
  games, by: "player",
  table-align: left, caption-bold: true, highlight-winners: false,
  caption: [Left-aligned, bold caption, no winner highlight.],
)
```, stacked: true)

#block(inset: (left: 1em))[_Note: `table-align` moves the table itself; the
caption always stays centered at full page width. Aligning the caption to a
left/right table would require wrapping the figure, which Typst's model does not
allow without breaking table cross-references (`@my-table`), so the caption is
left centered by design._]

`caption-bold` bolds *your* caption text. It deliberately leaves the automatic
`Table N:` prefix alone, because a figure's supplement is the same value Typst
prints for a cross-reference — bolding it here would also bold every `@my-table`
in running text. If you want the prefix to match a bold caption, add a show rule
to your own document. Yours is the one place it can live: a rule inside the
package would have to wrap the figure, and that breaks the cross-references.

```typ
#import "@preview/staunton:0.2.2": chess-table-kind

#show figure.caption: it => {
  if it.kind == chess-table-kind {
    strong[#it.supplement #context it.counter.display(it.numbering)#it.separator]
    it.body
  } else { it }
}
```

The `kind` test keeps this to staunton's tables — ordinary figures, diagrams and
every cross-reference stay exactly as they were. Swap `chess-table-kind` for
`chess-kind` to do the same for diagrams, or drop the test to style all captions
alike.

Headers always repeat when a table breaks across a page boundary. For anything
these fields don't cover, pass raw `#table` arguments straight through — they
override any preset:

```typ
#standings-table(games, by: "player", stroke: 2pt + red, caption: [..])
```

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
(`set-diagram-defaults(outline-title: ..)` — see @document-style). Remember that a bare `board` is not a
figure, so it can be neither referenced nor listed — use a `chess-diagram`.

// === Document-wide style =====================================================

= Document-Wide Defaults<document-style>

Package *staunton* features sensible default settings out of the box, you rarely
need to adjust them at all. But if you need to, you can achieve that in two ways: per-call arguments overriding the default settings, and *document-wide* defaults that can be set with `set-chess-defaults` or the more specific setters. Adjusting settings this way affects *every subsequent* diagram and table unless overridden per-call.

Defaults live in *five* buckets, each with its own setter:

#table(
  columns: (auto, auto, 1fr),
  inset: 6pt,
  align: (left, left, left),
  stroke: 0.5pt + rgb("#d9d9d2"),
  table.header([*bucket*], [*setter*], [*controls*]),
  [board], raw("set-board-defaults"), [square colors, labels, piece set, grid, size, highlight/arrow *styling* — full list in @board-options],
  [diagram], raw("set-diagram-defaults"), [the diagram figure: game-info line, supplement, outline title],
  [table], raw("set-table-defaults"), [the table figure: supplement, outline title, title gap],
  [language], raw("set-lang"), [the document language (localized strings)],
  [PGN handling], raw("set-pgn-defaults"), [what a parsed game's extras render — see @pgn-handling],
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

Every default is equivalently a per-call argument — the same green theme,
set once above vs. passed to one diagram:

#example(```typ
#chess-diagram(
  "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR",
  light: rgb("#eeeed2"), dark: rgb("#769656"),
  size: 4cm,
)
```)

A few caveats. `flip` is *not* allowed in any defaults setter — orientation is a
per-board choice, so `set-chess-defaults(flip: ..)` is an error. The
*position-specific* board options are likewise rejected: `highlight` and `arrows`
are per-call arguments (a document-wide default would stamp the same squares on
every diagram), and `move-quality-mark` is derived from a game move by
`diagram-after` — their *styling* (`highlight-fill`, `cross-color`, `arrow-color`,
`move-quality-colors`, …) is settable document-wide, but the squares/arrows/mark
themselves are not. Finally, `supplement` / `outline-title` live in *both* the
diagram and table buckets; the umbrella routes them to *diagram*, so use
`set-table-defaults` for the table ones.

== Language

Package *staunton* supports localisation of text-related output. At the moment we support six different languages; apart from the standard English, we offer German, French, Spanish, Italian, Portuguese, and Russian. We can easily extend the list of supported languages by adding new translation files. 

The `notation` / `chess-notation` functions localise the piece letters, and the `chess-diagram` / `chess-table` figures carry language-aware titles and captions. The `lang:` argument on each function overrides the document default, and the document default is set with `set-lang`.

A single document *language* drives every language-aware string — diagram and
table supplements, outline titles, automatic diagram captions ("Position after
move …"), tournament-table column headers, and notation piece letters. Default is
English; `"auto"` follows `#set text(lang: ..)`; or pick a code:

```typ
#set-lang("de")     // Diagramm / Tabelle / Sf3, Lb5, ...
#set-lang("auto")   // follow #set text(lang: ..)
```

Every localizable string is also per-call overridable (the `lang:` argument seen
on `chess-notation` above). Adding a language is a no-code change: drop a
`src/assets/i18n/<code>.typ` and register it in `src/i18n.typ`.

== PGN Handling

The fifth bucket, *PGN handling*, decides how much of a parsed game's embedded
extras (NAGs, comments, annotations, variations, embedded diagrams) get
interpreted at render time. Because those switches are best understood next to
the notation and board features they govern, they are documented with the games
themselves — see @pgn-handling. `set-pgn-defaults` sets them document-wide, and
`set-chess-defaults` routes the same keys through the umbrella.

// === HTML export =============================================================

#pagebreak()

= HTML Export<html-export>

Besides paged output (PDF / PNG), *staunton* also supports Typst's *HTML export*.
Compile with the `html` feature and target:

```sh
typst compile --features html --format html your-doc.typ out.html
```

The library-level output maps onto native HTML:

- *move notation* becomes ordinary inline text (mainline moves as `<strong>`);
- *tournament tables* become real `<table>` elements;
- *diagram* and *table* figures keep their captions, numbering and supplements as
  `<figure>` / `<figcaption>`, and `@`-references and the diagram / table
  *outlines* resolve to in-document links;
- *boards and diagrams* are embedded as *inline SVG* (a board is layout-drawn, so
  it is wrapped in `html.frame` under an HTML target — paged export is unchanged).

*Caveats.* Typst's HTML export is itself #emph[under active development], so this
is *limited* support, not full PDF parity. Page-level chrome (the `#set page`
header / footer, `#pagebreak`, multi-column `#grid` layout) is dropped by HTML
export — that is document styling, not part of staunton. Treat HTML output as a
useful secondary format that will improve as Typst's own HTML support matures.

// === API Reference ===========================================================

#part[API Reference] <api-reference>

= Common Parameters

This chapter collects the recurring *argument value shapes* and the full board /
diagram / table option lists — the parameters that many functions share. The
*Main functions* and *Advanced functions* chapters that follow then give every
public function's signature with each parameter's type and default, generated
directly from the source docstrings. The guide chapters above show each feature
in use with a rendered example; this reference part answers "what exactly can I
pass".

== Argument Value Shapes

A few arguments accept more than one shape and recur across functions, so they are
described once here.

/ `source`: for `board`, `chess-board`, `diagram`, `chess-diagram`, `position` —
  a *FEN string* `"rnbqkbnr/…"`; a *position* dict (from `position` / `parse-fen`);
  a *squares* dict `(e1: "K", d8: (kind: "q", color: "black"), e4: "P")` (piece as a
  long name, kind abbreviation, or bare letter — UPPER white, lower black); or the
  *string form* (rank-per-line rows, `.` = empty; one raw block or several row
  strings). `chess-*` reject a non-standard `variant`.

/ `locator`: for `position-after`, `diagram-after`, `to-fen`, `move-san`,
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

/ annotation color letters: for PGN `%cal`/`%csl` and the `annotation-colors`
  map — `G` `R` `Y` `B` `O`.

== Board Style Options <board-options>

Accepted by `board` / `chess-board` / `diagram` / `chess-diagram` per call, and by
`set-board-defaults` / `set-chess-defaults` document-wide (see @document-style) —
*except* the three *position-specific* ones marked _(per call only)_ below:
`highlight`, `arrows` and `move-quality-mark` cannot be document defaults (the
setters reject them), though their *styling* options can.

#table(
  columns: (2.3fr, 1.5fr, 3.2fr),
  inset: 5pt, align: left + horizon, stroke: 0.5pt + rgb("#d9d9d2"),
  table.header([*option*], [*default*], [*meaning*]),
  raw("size"), raw("auto"), [board size: a `length`, a `ratio` of the width, or `auto`],
  [`light` / `dark`], [tan theme], [the two square fill colors],
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
  [`highlight` / `arrows`], raw("()"), [squares / arrows to draw — see the value shapes _(per call only)_],
  raw("highlight-shape"), raw("\"filled\""), [default shape for plain-string highlight entries],
  [`highlight-fill` / `highlight-transparency`], [green, `75%`], [filled-highlight color and its transparency],
  [`cross-color` / `circle-color`], [red / green], [cross / circle stroke colors],
  [`cross-width` / `circle-width`], raw("auto"), [cross / circle stroke widths; `auto` → 15% of the square (a `ratio` or absolute length also work)],
  [`cross-margin` / `circle-margin`], raw("auto"), [cross corner-to-tip distance / circle inset; `auto` → 10% / 3% of the square (ratio / length accepted)],
  [`arrow-color` / `arrow-transparency`], [green, `35%`], [default arrow color and its transparency],
  raw("arrow-width"), raw("auto"), [arrow shaft width; `auto` → 15% of the square (ratio / length accepted)],
  raw("check"), raw("false"), [in-check glow on the checked king (auto-located for standard positions)],
  [`check-color` / `check-square`], [red / `none`], [glow color; square to glow (`none` → auto-located)],
  raw("move-quality"), raw("false"), [move-quality badge on the last move's destination],
  raw("move-quality-mark"), raw("none"), [`(square:, symbol:)`, symbol one of `! ? !! ?? !? ?!` — derived and set by `diagram-after` only; not a document default nor settable on a bare board _(per call only)_],
  raw("move-quality-colors"), [blue / red / green], [`good` / `bad` / `interesting` badge backgrounds],
  raw("annotation-colors"), [G/R/Y/B/O map], [PGN `%cal`/`%csl` color-letter → color],
  raw("label-color"), raw("luma(90)"), [`"outside"`-mode strip label color],
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
`variations` — all `false` by default; `bold-mainline` and `spaced` default `true`
(`spaced` = a space after the move number, "24. Nf3" vs. the dense "24.Nf3"; see
#link(<pgn-handling>)[PGN handling]).

// === Main functions ==========================================================

#pagebreak()

= Main Functions<main-functions>

The everyday API, grouped by task. Each entry is generated from the function's
source docstring: its signature, then every parameter with its type and default.

== Boards and Diagrams
#show-fns((
  ("/lib.typ", "board"),
  ("/lib.typ", "chess-board"),
  ("/lib.typ", "chess960-board"),
  ("/lib.typ", "diagram"),
  ("/lib.typ", "chess-diagram"),
  ("/lib.typ", "chess960-diagram"),
))

== Positions
`define-variant` builds a reusable custom (fairy) variant to pass as `variant:`
(see #link(<fairy-pieces>)[Non-standard pieces]).
#show-fns((
  ("/lib.typ", "position"),
  ("/src/fen.typ", "parse-fen"),
  ("/lib.typ", "to-fen"),
  ("/src/fen.typ", "starting-fen"),
  ("/lib.typ", "chess960-start"),
  ("/src/chess960.typ", "chess960-start-fen"),
  ("/src/variants.typ", "define-variant"),
))

== Games (PGN)
#show-fns((
  ("/src/pgn.typ", "parse-pgn"),
  ("/src/pgn.typ", "movetext"),
  ("/src/game.typ", "mainline"),
  ("/src/game.typ", "game-result"),
  ("/src/game.typ", "game-start"),
  ("/src/game.typ", "game-variant"),
  ("/src/game.typ", "position-after"),
  ("/lib.typ", "diagram-after"),
  ("/src/game.typ", "move-san"),
  ("/src/game.typ", "move-node"),
  ("/src/san.typ", "chess-moves"),
))

== Annotate and Build
#show-fns((
  ("/src/game.typ", "with-nags"),
  ("/src/game.typ", "with-comments"),
  ("/src/game.typ", "with-variation"),
))

== Notation
#show-fns((
  ("/lib.typ", "notation"),
  ("/lib.typ", "chess-notation"),
))

== Tournament Tables
#show-fns((
  ("/src/tournament.typ", "standings-table"),
  ("/src/tournament.typ", "crosstable-table"),
  ("/src/tournament.typ", "progress-table"),
  ("/src/tournament.typ", "games-by-event"),
))

== Outlines and References
#show-fns((
  ("/lib.typ", "chess-diagram-outline"),
  ("/lib.typ", "chess-table-outline"),
  ("/lib.typ", "chess-outlines"),
))

== Document Defaults
#show-fns((
  ("/src/style.typ", "set-chess-defaults"),
  ("/src/style.typ", "set-board-defaults"),
  ("/src/style.typ", "set-diagram-defaults"),
  ("/src/style.typ", "set-table-defaults"),
  ("/src/style.typ", "set-pgn-defaults"),
  ("/src/style.typ", "set-lang"),
  ("/src/style.typ", "set-piece-set"),
))

// === Advanced functions ======================================================

#pagebreak()

= Advanced Functions<behind-the-scenes>

A handful of supported *escape hatches* for programmatic use — not the everyday
entry points, but part of the public API and safe to build on. They cover three
needs: reading tournament *data* to build your own tables, driving the *engine*
directly, and dropping a single piece *glyph* or computing a square in your own
layout code.

Everything else in `src/` (the position parser's internals, the SAN encoder, the
renderer, the comment interpreter, the localization tables, …) is deliberately
*not* re-exported from the package: those names are implementation details that
may change between releases. If you truly need one, import it directly from its
module — e.g. `#import "@preview/staunton:0.2.2/src/coords.typ": square-name` —
with the understanding that it carries no stability promise.

== Tournament data
The `*-table` functions in #link(<tournament-tables>)[Tournament Tables] render standings,
cross-tables and progress grids. These return the underlying *data* instead, so
you can lay it out yourself.
#show-fns((
  ("/src/tournament.typ", "standings"),
  ("/src/tournament.typ", "crosstable"),
  ("/src/tournament.typ", "progress"),
))

== Engine
Generate and apply moves, or test for check — for puzzles, analysis, or
conditional rendering. `move-to-san` names a move dict as canonical SAN (see
#link(<naming-moves-san>)[Naming Moves as SAN]).
#show-fns((
  ("/src/engine.typ", "legal-moves"),
  ("/src/engine.typ", "apply"),
  ("/src/engine.typ", "in-check"),
  ("/src/san.typ", "move-to-san"),
))

== Pieces and coordinates
`piece-content` renders a single piece glyph for use in running prose; the two
coordinate helpers convert between square names and `(col, row)` indices for
hand-built overlays.
#show-fns((
  ("/src/pieces.typ", "piece-content"),
  ("/src/coords.typ", "parse-square"),
  ("/src/coords.typ", "is-dark-square"),
))

== Piece-set loaders
Build the `piece-set` value for a downloaded or custom set (see
#link(<custom-piece-sets>)[Bringing your own piece art] and
#link(<fairy-pieces>)[Non-standard pieces]). `named-piece-set` maps
`(color, kind)` onto your files through a filename pattern; `svg-piece-set` is
the lichess-layout shorthand; `with-fallback` composes a custom loader over a base
set for mixed boards.
#show-fns((
  ("/src/pieces.typ", "named-piece-set"),
  ("/src/pieces.typ", "svg-piece-set"),
  ("/src/pieces.typ", "with-fallback"),
))

// === Appendix ================================================================

#part[Appendix]

// Appendix chapters are lettered A, B, … (sections A.1, …). Reset the level-1
// heading counter and switch its format; the part heading itself is unnumbered,
// so this only affects the chapters that follow.
#counter(heading).update(0)
#set heading(numbering: "A.1")

= Bibliography

#bibliography("refs.yml", title: none)

= Acknowledgements

The Typst package #link("https://typst.app/universe/package/boards-n-pieces")[boards-n-pieces]
was an inspiration for some of staunton's features. This package and its manual
were developed with assistance from Claude (Opus 4.8) by Anthropic.
