// EXPECT: Two games appear to have run together
// Same restart guard as movetext_restart_no_separator.typ, but with the move
// number GLUED to the move ("1.e4"). A naive check that only looks for a bare
// "1." token would miss this -- the restart check must still catch it. The
// check lives in the lazy movetext-tree builder, so parsing (mainline(..))
// must actually be forced for the error to fire.
#import "/lib.typ": games, mainline
#let _ = mainline(games("1.e4 e5 2.Nf3 1.d4").first())
