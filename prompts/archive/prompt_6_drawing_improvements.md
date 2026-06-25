The font size used in labeling boards (option 1, directly on board square is too big, it must be proportional smaller and also a bit closer to corners (bottom/left and top/right, respectively)).

It may be that if the font gets too small (let's say <= 4pt>), we have to switch to option 3 (drawing border around actually board and putting labels there) as the default in that case.

Introduce an extra #board(..) function for just drawing boards. Rules for labeling the board, colors and flipping etc. still apply.

Fully fledged chess diagrams with figures with captions etc. should stay with #chess-diagram(...) (and #fen-diagram(...)), respectively. Those functions would just use the new #board() function.

Introduce new tests that test boards in different sizes with the same (arbitrary) position to test different labeling options in order to test, how well scaling board sizes work.