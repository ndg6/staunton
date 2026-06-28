# Prompt 17 — chess outlines & references: design + outcome

> Status: **implemented**. Source: `prompts/prompt_17__outlines_refs.txt`. Scope:
> rename/extend the outline helpers and make tournament tables referenceable.

## The ask

1. rename `chess-outline` → `chess-diagram-outline`;
2. add `chess-table-outline` (list of chess tables);
3. add `chess-outlines` (print both);
4. explicit tests for **referencing** chess diagrams and tables.

## Key finding (what made this non-trivial)

Diagrams were already `#figure(kind: "chess")` — numbered, referenceable,
outlineable. **Tables were not figures**: the `*-table` renderers returned a raw
`#table` (optionally a `stack` with a `title` heading). So tables could be neither
referenced nor outlined. The substance of the prompt was therefore *making tables
figures*; the renames were trivial.

## Decisions (this session)

- **Tables become figures, always.** Each `*-table` returns
  `#figure(kind: "chess-table")`. New kind kept distinct from diagrams' `"chess"`
  so the two get **separate counters** and **separate outlines**. (Diagrams' kind
  string stays `"chess"` — no break to existing `figure.where(kind:"chess")`.)
- **Hard rename** of `chess-outline` → `chess-diagram-outline` (no alias). The two
  in-repo callers (showcase + outline test) were updated.
- **`caption` added, `title` kept.** `caption` is the figure caption (below the
  table; drives refs + outline). `title` stays a heading stacked *above* the table
  (e.g. a division name). Both optional.
- **Supplement is a settable bucket.** New **table style** bucket in `style.typ`
  (`default-table-style = (supplement: [Table], title-gap: 0.6em)`), with
  `set-table-defaults(..)`. Each `*-table` also takes `supplement:` (`auto` → the
  document default, else a per-call override). `supplement` collides with the
  diagram bucket, so the `set-chess-defaults` umbrella routes it to **diagrams**;
  table supplement is set via `set-table-defaults` (documented).

## API

```
chess-diagram-outline(title: [List of Chess Diagrams], ..outline-args)
chess-table-outline(title: [List of Chess Tables], ..outline-args)
chess-outlines(diagram-title: .., table-title: .., ..outline-args)   // both
standings-table / crosstable-table / progress-table:
  (.., title: none, caption: none, supplement: auto, ..table-args)   // -> #figure
set-table-defaults(supplement: .., title-gap: ..)
chess-table-kind = "chess-table"     // re-exported for custom figure.where(..)
```

Only **captioned** figures appear in an outline (Typst's own behaviour); a
caption-less table is still referenceable but unlisted.

## Tests

- `tests/diagram/refs/diagram_refs.typ` — label + `@ref` two diagrams (a dangling
  ref is a hard error, so a clean compile proves resolution); `query` asserts the
  diagram counter is independent.
- `tests/tournament/refs/table_refs.typ` — references to two tables + a diagram;
  `query` asserts 2 `chess-table` + 1 `chess` figures (separate counters), the
  per-call `supplement` override reaches the figure, the default supplement is
  `Table`, and it is document-settable via `set-table-defaults`. Exercises
  `chess-outlines`.
- `tests/diagram/outlines/outline.typ` + `examples/showcase.typ` updated to the
  renamed `chess-diagram-outline`.

Suite: **70/70 green.**

## Deferred / notes

- Per-renderer supplements ("Cross-table 2") — not done; one "Table" counter.
- Forwarding figure-level args (e.g. `placement`) to the table figure — extra
  `..table-args` still go to the inner `#table`, as before.
