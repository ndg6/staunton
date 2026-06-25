// EXPECT: wK.svg
// §2.4 - a piece set that is MISSING (or has badly named) a piece file.
// After the unknown-set guard was removed (decision 3), an unrecognised set name
// is no longer a hard error -- instead the SVG is loaded on demand, so a missing
// or misnamed piece file surfaces as Typst's own "file not found" error naming
// the exact file. Here the "_incomplete" fixture set ships only bK.svg, so a
// position needing the white king fails to find wK.svg.
//
// (A "badly named" file, e.g. naming the white king "king-white.svg" instead of
// "wK.svg", manifests the same way: the canonical path is not found.)
#import "/lib.typ": board
#board("8/8/8/8/8/8/8/4K3 w - - 0 1", piece-set: "_incomplete")
