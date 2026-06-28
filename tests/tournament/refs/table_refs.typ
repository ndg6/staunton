// §prompt 17 - REFERENCING chess tables, plus the chess outlines. Tournament
// tables are now #figure(kind: "chess-table"), so they can be referenced (@label)
// and listed by chess-table-outline / chess-outlines, with their OWN counter
// separate from diagrams. Also exercises the table `supplement`: default "Table",
// document-settable (set-table-defaults), and per-call overridable.
#import "/lib.typ": (
  parse-pgn, standings-table, crosstable-table, chess-diagram, starting-fen,
  chess-table-outline, chess-outlines, set-table-defaults,
  default-table-style, table-style-state,
)

#set page(width: 16cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)
#set heading(numbering: "1.")

// Default table supplement is "Table".
#context {
  assert((default-table-style + table-style-state.get()).supplement == [Table], message: "default table supplement is Table")
}

#let rr = parse-pgn(```
[White "A"][Black "B"][Result "1-0"] 1-0
[White "A"][Black "C"][Result "1-0"] 1-0
[White "B"][Black "C"][Result "1-0"] 1-0
```)

// Both outlines, back to back (diagrams then tables).
#chess-outlines()

= Tables and a diagram
#standings-table(rr, by: "player", caption: [Final standings]) <st>
#crosstable-table(rr, by: "player", caption: [Cross-table], supplement: [Crosstab]) <ct>
#chess-diagram(starting-fen, size: 2.5cm, caption: [A position]) <pos>

@st gives the standings; @ct the cross-table; the board is @pos.

#context {
  // Separate counters: two chess-tables, one chess diagram.
  let tables = query(figure.where(kind: "chess-table"))
  assert(tables.len() == 2, message: "two chess tables present")
  assert(query(figure.where(kind: "chess")).len() == 1, message: "one diagram, separate counter")
  // The per-call supplement override reached the figure.
  assert(tables.map(t => t.supplement).contains([Crosstab]), message: "per-call supplement override applied")
}

// The default supplement is document-settable.
#set-table-defaults(supplement: [Tabelle])
#context {
  assert((default-table-style + table-style-state.get()).supplement == [Tabelle], message: "table supplement is document-settable")
}
