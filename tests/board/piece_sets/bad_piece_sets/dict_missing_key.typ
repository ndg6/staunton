// EXPECT: has no entry for
// A bytes-dictionary piece set must carry every "<color>-<kind>" the position
// needs. Here the dict has the black king but the position also needs the white
// king, so "white-king" is missing -- reported clearly (with the keys present)
// instead of a bare dictionary-lookup panic.
#import "/lib.typ": board
#let partial = ("black-king": read("/src/assets/piece_sets/cburnett/bK.svg", encoding: none))
#board("4k3/8/8/8/8/8/8/4K3 w - - 0 1", piece-set: partial, labels: false)
