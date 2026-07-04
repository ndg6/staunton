// PGN (good) - a board for a position at an arbitrary MAINLINE move, from a
// real game. diagram-after pulls the roster (White/Black/Date) into the labels and
// the last move into the caption automatically.
#import "/lib.typ": parse-pgn, diagram-after, mainline

#set page(width: 13cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)

#let game = parse-pgn(read("/tests/pgn/realworld/opera.pgn")).first()

= Mainline position

The mainline has #mainline(game).len() plies.

After Black's 11th move (11...Nbd7):
#diagram-after(game, "11b", size: 5cm)
