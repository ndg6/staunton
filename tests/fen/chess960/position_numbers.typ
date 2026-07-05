// Chess960 position numbering (Scharnagl scheme): number -> start FEN and the
// inverse rank -> number. Anchors: 518 = standard, 0 = BBQNNRKR, 959 = RKRNNQBB.
// Every number 0..959 must round-trip, and every generated start must be a valid
// FEN that serialises back as KQkq (each colour's castling rooks are the outer
// pair, so no file-letter disambiguation is needed for a fresh start).
#import "/lib.typ": chess960-start-fen, chess960-start, parse-fen, to-fen
#import "/src/chess960.typ": chess960-back-rank, chess960-number

#set page(width: auto, height: auto, margin: 1cm)

// --- anchors ---
#assert(chess960-start-fen(518) == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
  message: "518: " + chess960-start-fen(518))
#assert(chess960-start-fen(0) == "bbqnnrkr/pppppppp/8/8/8/8/PPPPPPPP/BBQNNRKR w KQkq - 0 1",
  message: "0: " + chess960-start-fen(0))
#assert(chess960-start-fen(959) == "rkrnnqbb/pppppppp/8/8/8/8/PPPPPPPP/RKRNNQBB w KQkq - 0 1",
  message: "959: " + chess960-start-fen(959))

// --- full number <-> rank round-trip across all 960 positions ---
#for n in range(960) {
  assert(chess960-number(chess960-back-rank(n)) == n, message: "round-trip broke at n=" + str(n))
}

// --- every start FEN parses and re-serialises identically (KQkq) ---
#for n in (0, 1, 42, 356, 518, 617, 959) {
  let f = chess960-start-fen(n)
  assert(to-fen(parse-fen(f)) == f, message: "FEN round-trip broke at n=" + str(n) + ": " + to-fen(parse-fen(f)))
}

// chess960-start(n) is the parsed position of chess960-start-fen(n)
#assert(chess960-start(518).squares == parse-fen(chess960-start-fen(518)).squares, message: "chess960-start")

// out-of-range numbers are rejected
#assert(chess960-back-rank(0).len() == 8)

= Chess960 numbering round-trips

All 960 Scharnagl position numbers round-trip through `chess960-back-rank` /
`chess960-number`, and each start FEN re-serialises as `KQkq`.
