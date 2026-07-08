// EXPECT: file not found
// A loader that points at a NON-EXISTENT set/folder (or a wrongly named file):
// the failure surfaces as Typst's own "file not found" error, naming the exact
// path it searched -- the same clear diagnostic a missing bundled-set file gives.
#import "/lib.typ": board
#let broken = (color, kind) => read("/src/assets/piece_sets/does_not_exist/wK.svg", encoding: none)
#board("8/8/8/8/8/8/8/4K3 w - - 0 1", piece-set: broken, labels: false)
