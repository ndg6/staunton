// EXPECT: Two games appear to have run together
// Two games with NEITHER rosters NOR result tokens concatenate into one
// legal-looking line that no separator can catch -- the restart check exists
// specifically for this case. The check lives in the LAZY movetext-tree
// builder now, not the eager games() scan, so games() alone does not error --
// the error only fires when the movetext is actually parsed (mainline(..)).
#import "/lib.typ": games, mainline
#let _ = mainline(games("1. e4 e5\n\n1. d4 d5").first())
