// EXPECT: unknown table header-fill: "bogus" (expected none, "gray", or a color)
// set-table-defaults rejects an unknown `header-fill` value.
#import "/lib.typ": set-table-defaults
#set-table-defaults(header-fill: "bogus")
