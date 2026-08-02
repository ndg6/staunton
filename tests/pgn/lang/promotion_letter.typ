// Asserting test: 2.0.0 Phase B' -- the promotion letter after "=" is
// localized too. German "=D" (Dame) must normalize to canonical "=Q".
#import "/lib.typ": game, mainline

// A legal pawn-race line where both sides capture a rook on the back rank
// and promote to a queen (verified legal).
#let en-promo = "1. c4 h5 2. c5 h4 3. c6 h3 4. cxb7 hxg2 5. bxa8=Q gxh1=Q"
#let g-en = game(en-promo, lang: "en")
#assert(
  mainline(g-en) == ("c4", "h5", "c5", "h4", "c6", "h3", "cxb7", "hxg2", "bxa8=Q", "gxh1=Q"),
  message: "en promotion baseline: " + repr(mainline(g-en)),
)

// The same line, written with German piece letters and "=D" for the
// promotion.
#let de-promo = "1. c4 h5 2. c5 h4 3. c6 h3 4. cxb7 hxg2 5. bxa8=D gxh1=D"
#let g-de = game(de-promo, lang: "de")
#assert(
  mainline(g-de) == ("c4", "h5", "c5", "h4", "c6", "h3", "cxb7", "hxg2", "bxa8=Q", "gxh1=Q"),
  message: "de promotion normalisation: " + repr(mainline(g-de)),
)

= localized promotion letter OK

German "=D" normalizes to English "=Q" in both promoting moves of the line.
