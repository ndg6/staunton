// §2.4 (positive side of decision 3) - a user can add their OWN piece set by
// just dropping a folder under src/assets/piece_sets/, with no plugin code change.
// The "_incomplete" fixture set ships only bK.svg; a position that needs only
// the black king therefore renders fine through that custom set name. This is
// the behaviour the removed guard used to block.
#import "/lib.typ": board

#set page(width: auto, height: auto, margin: 1cm)

A position drawn with a user-supplied set named `_incomplete`:

#board("4k3/8/8/8/8/8/8/8 w - - 0 1", piece-set: "_incomplete", size: 4cm, labels: false)
