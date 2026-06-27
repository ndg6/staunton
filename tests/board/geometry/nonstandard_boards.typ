// §prompt 12, item 1 - non-standard board geometries. The renderer is no longer
// 8x8-only: the position model carries cols/rows and the board draws a square-
// celled cols x rows grid. `size` is the LARGER dimension (cells stay square).
#import "/lib.typ": board, position

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

= Non-standard board geometries

== 9x9 (e.g. a Xiangqi-sized grid) -- the prompt's 9-queens example

#board(position(```
....Q....
......Q..
........Q
...Q.....
.Q.......
.......Q.
.....Q...
..Q......
Q........
```), size: 6cm)

== Rectangular 10x8 (Capablanca-style width) -- cells stay square

The board is wider than tall; `size` fixes the longer (10-file) side, and the
cells stay square. Labels and the "border" band wrap the rectangle correctly.

#let cap = position(
  "rnbqkbnr..",
  "pppppppp..",
  "..........",
  "..........",
  "..........",
  "..........",
  "PPPPPPPP..",
  "RNBQKBNR..",
)
#grid(columns: 2, column-gutter: 16pt,
  board(cap, size: 7cm),
  board(cap, size: 7cm, label-mode: "border"),
)

== 9x9 flipped + on-square labels (file letters run a..i)

#board(position(```
....Q....
......Q..
........Q
...Q.....
.Q.......
.......Q.
.....Q...
..Q......
Q........
```), size: 6cm, flip: true)
