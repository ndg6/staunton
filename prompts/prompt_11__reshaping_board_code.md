Based on the discussions in and from "prompts/prompt_10__revamp_staunton.txt", and your findings in "docs/prompt10_mission_and_gap_analysis.md"
I want now slowly reshape our current plugin code.

Note: this is still discussions only, no code!

To re-iterate our overall mission
- make standard / "simple" chess publishing tasks as convenient as possible
    - fully automated handling of comments, hightlighting, arrws
    - support for chess diagrams
    - support for matches / tournaments with creation of score tables
    - outlines
- provide programmatic access to
    - board embellishements (labels, hightlightin etc)
    - diagrams (captions etc)
    - PGN handling (position after move list from given position / variants)
    - table creation
    - outline creation
- make non-standard chess publishing possible. This includes
    - standard pieces, but unusual board geometry e.g. 10x8
    - support of non-western chess (Xiangqi, Janggi, Shogi, Shatar)
    - chess variants like 960 / Fischer Random
    - various Fantasy chess (e.g. Capablanca Chess) etc.
- provide capabilities for standard settings
    - meaningful, convenient factory settings
        - for board layout
        - diagram handling
    - settable options for
        - board labeling, highlights etc.
        - piece sets
        - diagram caption handling
- provide different piece sets or defininng your own sets.

Even we we don't implement all this, we want atleast to
be _prepared_ for this. This has repercussions, how our structures
and functions must look like.


In general we have this structure in chess publishing from fundamental
(and visual) to structural:

- board (pieces on squares)
- embellished / amended board
    - labels, highlights (filled square or otherwise marked with circles or crosses) and arrows
- chess diagram: boards with additional (game) info
    - is locateable via Typst "labels"
    - has a #figure kind
- move text / notation, which is a textual representation of a game
    or parts of a game
- chess tables, originating from complete matches or tournaments
    - cross tables (in round-robin tournaments)
    - progress tables (for Swiss tournaments / open tournaments)
- condensed structure in form of various Typst outlines
    - for diagrams
    - for games
    - for chess tables

---

This first part is about "boards", the visual representation of a "chess position". A board in its basic form is just a rectangle of individual fields with chess pieces on them. The information on which squares which piece is located we call a "position".

Standard chess positions involve a 8x8 arrangement of fields (with
coordonates in file / rank form like "e1"). The squares are internally enumerated in such a way, that "e1" means "5th square from the left on first rank counted from the bottom. In a standard representation (white at bottom, black at top() this would also be its visual representation. In a flipped representation (black at bottom, white at top) "e1" would mean "4th square from the left on 8th rank). We have to have some form
of coordinate translation from named square "e1" to an internal square counting mechanism.

The basic (but insufficient!) structure for a position therefore
must be
```
#let position = (
    pieces: (
        (piece-kind1, color1, square),
        (piece-kind2, color2, square),
        ...
    )
)
```
What exactly "piece-kind" is, depends on the chess variant. Since we
have several different possible variants / we should denote this with
a property "variant: <VARIANT>". For starter let's define <VARIANT> as
an enum "standard" (standard western chess) and "xiangqi" for Chineses chess.
Other enum values may follow.

The piece kinds valid for a chess variant must be defined somewhere. For
standard western chess, this would be

"king"; "queen", "rook", "bishop", "knight"; "pawn"

In chess notation for example in FEN (Forsyth-Edwards-Notation), we abbreviate them as "k", "q", "r", "b", "n", "p". In FEN, we make a difference between white and black pieces by capitalizing the piece kind abbreviations.

For Chinese chess, the allowed chess pieces would be (romanized version)

"General"; "Advisor", "Chariot", "Elephant", "Horse"; "Cannon", "Soldier"

In ramonized systems we would abbreviate this to "G", "A", "R", "E", "H", "C" and "S".


In the following, let's focus for now on western standard chess. The position function
is still incomplete. We need to know, who'se turn it is (white / black), what the en passant square is (if we had a double pawn moove before), how many moves since capture or pawn move (not strictly necessary for board visualization, but for move
generation) and how many moves are played so far. We also need to know, which castles
rights still are available (if any).

For convenience (and also to support non-standard positions) We want to provide numerous ways how to construct a position:
- via PGN (done)
- vis FEN (done)
- as a hand-crafted position object (tedious, but sometimes only option)
- as a string.

The last option is new and not realized yet. The idea is, that we provide a position
via analyzing lines of strings where piece abbreviations represent pieces and the
relative position of that piece are the coordinates. A dot (".") represents an empty
square. I'm thinkking either of

#board(position(
  "....r...",
  "........",
  "..p..PPk",
  ".p.r....",
  "pP..p.R.",
  "P.B.....",
  "..P..K..",
  "........",
))

or 

#board(position(
```
  ....r...
  ........
  ..p..PPk
  .p.r....",
  pP..p.R.",
  P.B.....",
  ..P..K..",
  ........
```
))

Notice the use of "raw strings" with backticks in the latter case. 
In any case, we would need to provide the the chess variant (default: standard western) and our parsing code would need to analyze the validity of the piece kind
abbreviations (lower case: black, upper case: white) and construct the necessary positions.

The position functions also needs the number of columns (files) and rows (ranks).
This will be 8x8 for standard western chess and 9x9 for Chinese chess, but other colxrow layouts are possible, especially with the "position-from-string" option. We would need to count the rows and columns here. Caveat: we would support non-rectangular layouts for now, so column count must be the same for every row!.


I want your honest opinion about the "position" object. We also need to adapt test cases, but we will do so when implementing new solutions.

I also have some additional questions:
- in engine.typ / function "apply()", we have a position object that has board
    ("position.board"). Me thinks, that is the wrong layout ??!
- 

Next major step would be revamping the visualisation via boards.