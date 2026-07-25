// EXPECT: unknown table body-fill: "bogus" (expected none, "zebra", or a color)
// set-table-defaults rejects an unknown `body-fill` value.
#import "/lib.typ": set-table-defaults
#set-table-defaults(body-fill: "bogus")
