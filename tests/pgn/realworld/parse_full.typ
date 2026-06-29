// the full real-world tournament PGN (848 KB, with complete
// movetext incl. long {[%evp ...]} eval profiles).
//
// parse-pgn is now LAZY in the movetext: it eagerly extracts the roster + each
// game's verbatim movetext substring, but builds the move TREE only on demand
// via `movetext(game)`. So this whole-file parse is fast (roster scan only); the
// per-game tree is exercised by touching ONE game below.
#import "/lib.typ": parse-pgn, games-by-event, mainline, movetext

#set page(width: auto, height: auto, margin: 1cm)

#let all = parse-pgn(read("/tests/pgn/realworld/real_tournament.pgn"))
#assert(all.len() == 375, message: "expected 375 games, got " + str(all.len()))
#assert(games-by-event(all).keys().len() == 4, message: "four divisions")

// Roster + result + raw movetext are eager (no tree built yet).
#assert(all.first().result == "1-0", message: "result extracted eagerly")
#assert(all.first().movetext-raw.len() > 0, message: "verbatim movetext retained")

// Force ONE game's tree to confirm lazy movetext parsing works end to end.
#let g0 = all.first()
#assert(mainline(g0).len() == 105, message: "first game mainline plies")
// game 1 opens with a long {[%evp ...]} eval profile BEFORE 1.e4, so it attaches
// to the first move's comment-before (there is no comment between e4 and e5).
#let first-move = movetext(g0).first()
#assert(first-move.comment-before != none, message: "leading comment retained")
#assert(first-move.comment-before.starts-with("[%evp"), message: "eval profile retained verbatim")

= Full tournament PGN parses (#all.len() games, #games-by-event(all).keys().len() divisions)
