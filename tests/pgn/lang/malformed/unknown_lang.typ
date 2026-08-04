// EXPECT: games: unknown language code "xx"; supported: en, de, es, fr, it, pt, ru
// Expected-fail test: 2.0.0 Phase B' -- an unsupported `lang:` code is a hard
// error naming the supported list, rather than silently falling back to
// English (which would reopen exactly the hazard `hazard_lang.typ` pins).
#import "/lib.typ": game

#game("1. e4 e5", lang: "xx")
