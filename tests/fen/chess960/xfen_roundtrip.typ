// X-FEN (Chess960) castling in the rook-file model: each castling right stores
// the rook's file index. Parsing resolves K/Q/k/q to the OUTERMOST rook on that
// side of the king; serialising emits KQkq when unambiguous and a rook file
// letter otherwise (the promotion-rook case). Standard positions are unaffected.
#import "/lib.typ": position, to-fen

#set page(width: auto, height: auto, margin: 1cm)

// --- standard positions still round-trip byte-for-byte as KQkq ---
#let std = (
  "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1",
  "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1",
)
#for f in std { assert(to-fen(position(f)) == f, message: "std round-trip: " + to-fen(position(f))) }

// a standard start parses to the a/h-file rook indices
#assert(
  position(std.first()).castling == (white-king: 7, white-queen: 0, black-king: 7, black-queen: 0),
  message: repr(position(std.first()).castling),
)

// --- a Chess960 start (king on f, rooks on b/h) still serialises as KQkq,
//     because each castling rook is the outermost rook on its side ---
#let frc = "nrbbqknr/pppppppp/8/8/8/8/PPPPPPPP/NRBBQKNR w KQkq - 0 1"
#assert(to-fen(position(frc)) == frc, message: "FRC KQkq round-trip: " + to-fen(position(frc)))
#assert(
  position(frc).castling == (white-king: 7, white-queen: 1, black-king: 7, black-queen: 1),
  message: repr(position(frc).castling),
)

// --- promotion-rook ambiguity: an EXTRA rook outside the castling rook forces
//     the rook FILE letter (X-FEN "G.."/"g..") instead of K/k ---
#let xf = "r3k1rr/8/8/8/8/8/8/R3K1RR w GQgq - 0 1"
#assert(to-fen(position(xf)) == xf, message: "X-FEN file-letter round-trip: " + to-fen(position(xf)))
#assert(
  position(xf).castling == (white-king: 6, white-queen: 0, black-king: 6, black-queen: 0),
  message: repr(position(xf).castling),
)

= X-FEN castling round-trips

Standard `KQkq`, a Chess960 start, and the promotion-rook file-letter form all
round-trip through `position` / `to-fen`.
