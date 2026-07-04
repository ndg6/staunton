// PGN/SAN (good) - the counterpart to the ambiguous-SAN failure: when two
// pieces can reach the same square, a DISAMBIGUATED SAN resolves cleanly. Here
// both knights (b1, f3) can go to d2; "Nbd2" (file hint) picks the b1 knight.
#import "/lib.typ": parse-fen
// san-to-move / square-name are internal; test them against their own modules.
#import "/src/san.typ": san-to-move
#import "/src/coords.typ": square-name

#set page(width: auto, height: auto, margin: 1cm)

#let pos = parse-fen("4k3/8/8/8/8/5N2/8/1N2K3 w - - 0 1")
#let mv = san-to-move(pos, "Nbd2")
#let from-sq = square-name(..mv.from)
#let to-sq = square-name(..mv.to)
#assert(from-sq == "b1", message: "Nbd2 must move the b1 knight, got " + from-sq)
#assert(to-sq == "d2", message: "target must be d2, got " + to-sq)

Disambiguated SAN `Nbd2` resolves to #from-sq–#to-sq.
