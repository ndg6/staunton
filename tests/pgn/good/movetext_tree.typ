// PGN (good) - the movetext TREE built by movetext(game). Pins down the
// attachment rules the lazy/`cur`-accumulator parser implements:
//  * a leading comment -> the FIRST move's comment-before (and only the first);
//  * multiple comments after a move -> comment-after, joined by a single space;
//  * NAGs attach to the move they follow;
//  * a variation attaches to its move, and a comment after the ')' attaches to
//  that same (pre-variation) move;
//  * the final move is flushed even with NO trailing result token.
#import "/lib.typ": game, movetext, mainline

#set page(width: auto, height: auto, margin: 1cm)

// Note: no trailing result token -> the last move (Nf3) must still appear.
#let g = game(```
[White "Tree"] [Black "Test"]
{opening note} 1. e4 {good} {center} e5 $1 2. Nf3 (2. Bc4 Bc5) {develop}
```)

#let nodes = movetext(g)

#assert(mainline(g) == ("e4", "e5", "Nf3"), message: "three moves incl. flushed last move")

// comment-before: only the first move carries the leading comment.
#assert(nodes.at(0).comment-before == "opening note", message: "leading comment -> first move comment-before")
#assert(nodes.at(1).comment-before == none, message: "non-first move has no comment-before")

// comment-after: the two comments after e4 are joined with one space.
#assert(nodes.at(0).comment-after == "good center", message: "multiple comments joined")

// NAG on e5.
#assert(nodes.at(1).nags == ("1",), message: "nag captured on the move it follows")

// variation + comment after ')' both belong to Nf3 (the pre-variation move).
#assert(nodes.at(2).variations.len() == 1, message: "one variation on move 3")
#assert(nodes.at(2).variations.at(0).map(n => n.san) == ("Bc4", "Bc5"), message: "variation line preserved")
#assert(nodes.at(2).comment-after == "develop", message: "comment after ')' -> pre-variation move")

= movetext tree structure OK
