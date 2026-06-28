// §faster tokenizer - the full real-world tournament PGN (848 KB, with complete
// movetext incl. long {[%evp ...]} eval profiles) now parses. This used to
// exceed Typst's loop limit with the old char-by-char tokenizer.
#import "/lib.typ": parse-pgn, games-by-event, mainline

#set page(width: auto, height: auto, margin: 1cm)

#let all = parse-pgn(read("/tests/pgn/realworld/real_tournament.pgn"))
#assert(all.len() == 375, message: "expected 375 games, got " + str(all.len()))
#assert(games-by-event(all).keys().len() == 4, message: "four divisions")
// movetext (and comments/variations) preserved, not just the roster
#assert(mainline(all.first()).len() == 105, message: "first game mainline plies")
// game 1 opens with a long {[%evp ...]} eval profile BEFORE 1.e4, so it attaches
// to the first move's comment-before (there is no comment between e4 and e5).
#let first-move = all.first().movetext.first()
#assert(first-move.comment-before != none, message: "leading comment retained")
#assert(first-move.comment-before.starts-with("[%evp"), message: "eval profile retained verbatim")

= Full tournament PGN parses (#all.len() games, #games-by-event(all).keys().len() divisions)
