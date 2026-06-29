// EXPECT: unknown board style option
//  the explicit setters validate their keys against the bucket. An
// unknown board option is a hard error (catches typos), distinct from a diagram
// option going to the wrong setter.
#import "/lib.typ": set-board-defaults
#set-board-defaults(nonsuch: 5)
