// EXPECT: Two games appear to have run together
// The restart check generalised from "restarts at move 1" to "the top-level
// white move number must strictly increase" -- so 40. Kf1 followed by 2. d4
// (an earlier number regressing, not just a restart at 1) must also be
// rejected. The check lives in the lazy movetext-tree builder, so parsing
// (mainline(..)) must be forced for the error to fire.
#import "/lib.typ": games, mainline
#let _ = mainline(games("1. e4 e5 2. Nf3 Nc6 40. Kf1 2. d4 d5").first())
