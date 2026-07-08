// Custom piece set via a LOADER FUNCTION -- the mechanism that lets an installed
// package reach the user's OWN files. The loader body is authored HERE (in the
// user's document), so its `read()` resolves against the user's project root;
// package code could not build such a path (its paths resolve to the package
// sandbox -- see the sandbox probe in prompts/prompt_25...). We read the bundled
// cburnett SVGs as raw bytes to stand in for a user-downloaded set of the same
// {w,b}{K,Q,..}.svg layout (e.g. a lichess set).
//
// Asserting test: the two-king position must produce exactly two rendered images,
// proving the bytes were decoded and placed (not silently dropped).
#import "/lib.typ": board

#set page(width: auto, height: auto, margin: 1cm)

// kind -> file letter; the loader is kind-agnostic (kind is passed straight in).
#let letters = (king: "K", queen: "Q", rook: "R", bishop: "B", knight: "N", pawn: "P")
#let lichess-loader(root) = (color, kind) => {
  let c = if color == "white" { "w" } else { "b" }
  read(root + "/" + c + letters.at(kind) + ".svg", encoding: none)
}

A position drawn through a user-authored loader closure:

#board(
  "4k3/8/8/8/8/8/8/4K3 w - - 0 1",
  piece-set: lichess-loader("/src/assets/piece_sets/cburnett"),
  size: 4cm, labels: false,
)

#context assert(
  query(image).len() == 2,
  message: "loader should render 2 piece images, got " + str(query(image).len()),
)
