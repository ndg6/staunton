// Real-world variation notation: an Italian / Two Knights analysis with two
// variations at one move (7. O-O), a deep NESTED line (12. O-O-O ... move 18), and
// a black-first variation (16... Rab8). Regression that parse-pgn + chess-notation
// (variations: true) render real RAVs with correct offset numbering.
#import "/lib.typ": parse-pgn, chess-notation, mainline

#set page(width: auto, height: auto, margin: 1cm)
#set text(font: "Libertinus Serif", size: 9pt)

#let g = parse-pgn(read("/tests/pgn/realworld/italian_two_knights.pgn")).first()
#assert(mainline(g).len() == 32, message: "mainline: 16 full moves (32 plies)")

// all switches explicit -> a plain string; check the structurally tricky spots.
#let s = chess-notation(g, variations: true, lang: "en", nags: false, comments: false, diagrams: false)
#assert(type(s) == str, message: "explicit switches -> plain string")
#assert(
  s.starts-with("1. e4 e5 2. Nf3 Nc6 3. Bc4 Nf6 4. Ng5 d5 5. exd5 b5 6. dxc6 bxc4 7. O-O "),
  message: "mainline opening",
)
#assert(s.contains("7. O-O (7. Qf3) (7. d4 cxd3 8. Qxd3"), message: "two variations at move 7, numbered")
#assert(s.contains("12. Bc1 (12. O-O-O Bf5 13. a3"), message: "nested variation numbered from move 12")
#assert(s.contains("18. Nh3 O-O)) 7... h6"), message: "deep nesting closes; resumed Black move re-numbered 7...")
#assert(s.ends-with("16. Nc3 Rad8 (16... Rab8 17. b3)"), message: "black-first variation at the end")

= Two Knights — full notation with variations
#chess-notation(g, variations: true)
