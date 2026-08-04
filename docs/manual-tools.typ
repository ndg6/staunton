// Support helpers for the staunton Typst manual (docs/manual.typ).
//
// The point of the compiled manual is to show, for every feature, *the code you
// type* next to *the board it produces* — the cetz/tidy-manual idiom. `example`
// does exactly that: it renders a raw `typ` code block AND evaluates it, in the
// document's own context, so the two can never drift apart.

#import "/lib.typ" as staunton

// --- demo data shared by the examples ---------------------------------------
//
// The Games/PGN and Tournament sections assume a couple of parsed games are in
// scope, exactly as the prose says ("all examples assume `#let g = ...`").
// Defining them here keeps the shown snippets short and faithful to real usage.
//
// Bound as `g` / `gs` (not `game` / `games`) so they don't shadow the actual
// `game()` / `games()` package functions in the eval scope below.

// One fully-annotated game for the PGN / notation / annotation examples.
#let demo-game = staunton.game(```
[White "Alice"] [Black "Bob"] [Event "Synthetic Open"] [Date "2024.05.01"]
[Round "1"] [Result "1-0"]
1. e4 e5 2. Nf3 {[%cal Gf3e5] [%csl Re5]} Nc6 3. Bb5 a6 4. Ba4 Nf6
5. O-O Be7 6. Re1 b5 7. Bb3 d6 8. c3 O-O 1-0
```)

// A Chess960 / Fischer Random game (R. Scharnagl's SmirfGUI test game) for the
// Chess960 chapter. Its a1-rook maneuvers a1->a3->h3->h1, so the position before
// 11.O-O carries two white rooks on g1/h1 and serialises with the X-FEN file
// letter "Gkq".
#let demo-frc = staunton.game(```
[Variant "Fischerrandom"] [SetUp "1"]
[FEN "rnbnkqrb/pppppppp/8/8/8/8/PPPPPPPP/RNBNKQRB w KQkq - 0 1"]
1. h4 g6 2. g3 Bf6 3. a4 Qh6 4. Ra3 Bxh4 5. gxh4 Qxh4 6. Qh3 Qxh3
7. Rxh3 Ne6 8. Bf3 d6 9. Nbc3 Ng5 10. Rhh1 Bf5 11. O-O
```)

// A complete 4-player single round-robin (every pair meets once: 6 games over 3
// rounds) so standings / crosstable / progress all have something to chew on.
#let demo-games = staunton.games(```
[White "Alice"] [Black "Bob"]   [Event "Club RR"] [Round "1"] [Result "1-0"]     1. e4 1-0
[White "Carol"] [Black "Dave"]  [Event "Club RR"] [Round "1"] [Result "1/2-1/2"] 1. d4 1/2-1/2
[White "Alice"] [Black "Carol"] [Event "Club RR"] [Round "2"] [Result "1-0"]     1. c4 1-0
[White "Bob"]   [Black "Dave"]  [Event "Club RR"] [Round "2"] [Result "0-1"]     1. Nf3 0-1
[White "Alice"] [Black "Dave"]  [Event "Club RR"] [Round "3"] [Result "1/2-1/2"] 1. e4 1/2-1/2
[White "Bob"]   [Black "Carol"] [Event "Club RR"] [Round "3"] [Result "1-0"]     1. d4 1-0
```)

// Everything exported from the package PLUS the demo bindings, as an eval scope.
// Examples can therefore call `diagram`, `board`, `game`, `games`, ... and use
// `g` / `gs`, unqualified — just as a reader would.
#let manual-scope = dictionary(staunton) + (g: demo-game, gs: demo-games, frc: demo-frc)

#let _code-fill = rgb("#f6f6f4")
#let _frame = rgb("#d9d9d2")

// Show `code` (a raw block) as source, and beside/under it the result of
// evaluating that exact source in markup mode.
//
//   stacked:    force the layout (true = source above output). `auto` measures.
//   ratio:      force a fixed fraction of the width for the SOURCE column.
//   left-align: left-align the output instead of centring it (needed when the
//               output's own indentation matters, e.g. block variations)
//   min-out:    the least width the OUTPUT column may be given before the
//               example stacks instead. Raise it if a diagram comes out cramped.
#let _inset = 8pt

// Auto layout: the code column is given exactly the width its LONGEST LINE
// needs, so code never wraps and no space is wasted on padding a half-empty
// column. The output takes everything left over. If honouring the code's
// natural width would squeeze the output below `min-out`, the example stacks
// instead — that is the case `stacked: true` used to be passed by hand for.
//
// `stacked` and `ratio` stay as explicit ESCAPES for the cases where the
// measurement picks badly: `stacked: true` / `false` forces the layout, and a
// numeric `ratio` forces the old fixed split. Both default to `auto`.
#let example(
  code,
  stacked: auto,
  ratio: auto,
  left-align: false,
  min-out: 150pt,
) = {
  // Grid cells stretch to the row height, and the grid `fill` covers each cell
  // fully — so the code panel matches the output height with no page-relative
  // sizing (which would blow each example up to a full page).
  let src = raw(code.text.trim(), lang: "typ", block: true)
  let out = align((if left-align { left } else { center }) + horizon, eval(code.text, mode: "markup", scope: manual-scope))

  let stacked-grid = grid(
    columns: 1,
    inset: _inset,
    fill: (_, row) => if row == 0 { _code-fill },
    grid.hline(y: 1, stroke: 0.75pt + _frame),
    src,
    out,
  )
  let split-grid = cols => grid(
    columns: cols,
    inset: _inset,
    fill: (col, _) => if col == 0 { _code-fill },
    grid.vline(x: 1, stroke: 0.75pt + _frame),
    src,
    out,
  )

  let framed = body => block(
    stroke: 0.75pt + _frame,
    radius: 4pt,
    clip: true,
    width: 100%,
    breakable: false,
    body,
  )

  // An explicit `ratio` keeps the old fixed-split behaviour verbatim, and an
  // explicit `stacked` short-circuits the measurement entirely — neither needs
  // `layout`, so callers that force a layout pay nothing for the auto path.
  if stacked == true { return framed(stacked-grid) }
  if ratio != auto and stacked != auto { return framed(split-grid((ratio * 1fr, (1 - ratio) * 1fr))) }

  layout(avail => framed(context {
    // `measure` on a raw block reports its UNWRAPPED natural width, i.e. the
    // longest line — which is exactly the width at which the code stops
    // breaking. Verified: a one-line call measures ~58pt against the manual's
    // 459pt text width, so the old fixed 50/50 split wasted most of the row.
    let code-w = measure(src).width + 2 * _inset
    let fits = code-w <= avail.width - min-out
    if stacked == false or fits {
      let w = calc.min(code-w, avail.width - min-out)
      split-grid(if ratio != auto { (ratio * 1fr, (1 - ratio) * 1fr) } else { (w, 1fr) })
    } else {
      stacked-grid
    }
  }))
}
