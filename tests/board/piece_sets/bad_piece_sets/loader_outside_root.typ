// EXPECT: would escape the project root
// A loader that reaches for a folder OUTSIDE the compilation root fails hard:
// Typst forbids `..` from climbing above --root (and likewise rejects absolute OS
// paths like "C:/..." with "invalid component"). This documents the hard limit
// discussed in prompt 25: a package cannot read genuinely-external piece-set
// folders. The user's only options are to compile with --root set to a common
// ancestor, or to symlink the folder into the project tree.
#import "/lib.typ": board
#let outside = (color, kind) => read("../../../../../wK.svg", encoding: none)
#board("8/8/8/8/8/8/8/4K3 w - - 0 1", piece-set: outside, labels: false)
