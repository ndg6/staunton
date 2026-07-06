// Custom piece set via a BYTES DICTIONARY -- the convenient form for a small,
// fixed set of pieces (e.g. a study that only uses a few kinds). Keys are
// "<color>-<kind>" (kind-agnostic: no fixed six-kind letter map), values are raw
// image bytes or ready-made content. Only the pieces the position needs must be
// present. Same user-side authoring as the loader-function form: the `read()`
// calls that build the dict resolve against the user's project root.
//
// Asserting test: the two-king position must produce exactly two rendered images.
#import "/lib.typ": board

#set page(width: auto, height: auto, margin: 1cm)

#let dir = "/src/assets/piece_sets/cburnett"
#let my-set = (
  "white-king": read(dir + "/wK.svg", encoding: none),
  "black-king": read(dir + "/bK.svg", encoding: none),
)

A position drawn through a bytes dictionary:

#board("4k3/8/8/8/8/8/8/4K3 w - - 0 1", piece-set: my-set, size: 4cm, labels: false)

#context assert(
  query(image).len() == 2,
  message: "dict set should render 2 piece images, got " + str(query(image).len()),
)
