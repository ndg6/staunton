// §prompt 15 - the PGN-handling bucket: settable defaults for how embedded
// extras are processed. All OFF by default; set-pgn-defaults / set-chess-defaults
// update the document state.
#import "/lib.typ": default-pgn-style, pgn-style-keys, pgn-style-state, set-pgn-defaults, set-chess-defaults

#assert(
  default-pgn-style.annotations == false and default-pgn-style.nags == false
    and default-pgn-style.comments == false and default-pgn-style.diagrams == false,
  message: "all pgn switches OFF by default",
)
#assert(pgn-style-keys.contains("annotations") and pgn-style-keys.contains("nags"), message: "bucket keys")

// set-pgn-defaults updates the document state
#set-pgn-defaults(nags: true)
#context [#assert((default-pgn-style + pgn-style-state.get()).nags == true, message: "set-pgn-defaults applied")]

// the umbrella setter routes pgn keys too
#set-chess-defaults(comments: true)
#context [#assert((default-pgn-style + pgn-style-state.get()).comments == true, message: "set-chess-defaults routes pgn keys")]

#set page(width: auto, height: auto, margin: 1cm)
= PGN handling bucket
Settable keys: #repr(pgn-style-keys)
