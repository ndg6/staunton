// EXPECT: ambiguous move
// Two white knights (b1 and f3) can both play to d2; "Nd2" without
// disambiguation must be rejected as ambiguous.
#import "/lib.typ": position
#import "/src/san.typ": san-to-move
#let _ = san-to-move(position("4k3/8/8/8/8/5N2/8/1N2K3 w - - 0 1"), "Nd2")
