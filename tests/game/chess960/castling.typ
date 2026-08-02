// Chess960 castling, generalised: the king and its rook swing to the fixed
// destination files — king -> g / rook -> f for O-O, king -> c / rook -> d for
// O-O-O — from ARBITRARY starting files. Standard castling is the special case.
// These positions use non-standard king/rook files to exercise the general path.
#import "/lib.typ": play, position, to-fen, legal-moves

#set page(width: auto, height: auto, margin: 1cm)

// O-O with the king on f1 and its rook on g1: king f1->g1, rook g1->f1.
#let a = play("4k3/8/8/8/8/8/8/5KR1 w K - 0 1", "O-O")
#assert(to-fen(a) == "4k3/8/8/8/8/8/8/5RK1 b - - 1 1", message: "O-O king f1: " + to-fen(a))

// O-O-O with the king on b1 and its rook on a1: king b1->c1, rook a1->d1.
#let b = play("4k3/8/8/8/8/8/8/RK6 w Q - 0 1", "O-O-O")
#assert(to-fen(b) == "4k3/8/8/8/8/8/8/2KR4 b - - 1 1", message: "O-O-O king b1: " + to-fen(b))

// King ALREADY on the castled file (g1), rook on h1: O-O leaves the king put and
// only swings the rook h1->f1 (the Chess960 stationary-king case).
#let c = play("4k3/8/8/8/8/8/8/6KR w K - 0 1", "O-O")
#assert(to-fen(c) == "4k3/8/8/8/8/8/8/5RK1 b - - 1 1", message: "O-O king stationary: " + to-fen(c))

// legal-moves offers exactly one castling move here, and it is a king-side castle.
#let castles = legal-moves(position("4k3/8/8/8/8/8/8/5KR1 w K - 0 1")).filter(m => m.kind == "castle-k" or m.kind == "castle-q")
#assert(castles.len() == 1 and castles.first().kind == "castle-k", message: "one king-side castle: " + repr(castles))

= Chess960 castling from non-standard king/rook files

`O-O` / `O-O-O` land the king and rook on the standard g/f (c/d) files even when
they start elsewhere, including the case where the king does not move.
