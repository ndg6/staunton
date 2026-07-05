// EXPECT: 0..959
// Chess960 position numbers are 0..959; anything outside is a hard error.
#import "/lib.typ": chess960-start-fen

#let _ = chess960-start-fen(960)
