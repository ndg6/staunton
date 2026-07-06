// EXPECT: expected bytes
// A loader must return image `bytes` (e.g. read(path, encoding: none)) or ready
// `content` (e.g. image(path)). Returning anything else -- here a plain string,
// the classic slip of forgetting `encoding: none` on read() -- is caught with a
// message naming the offending piece, rather than a confusing downstream error.
#import "/lib.typ": board
#let wrong = (color, kind) => "not-an-image"
#board("8/8/8/8/8/8/8/4K3 w - - 0 1", piece-set: wrong, labels: false)
