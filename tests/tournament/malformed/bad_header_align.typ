// EXPECT: unknown table header-align: top (expected left, center, or right)
// set-table-defaults rejects an alignment value outside left/center/right (here
// the vertical alignment `top`, which is a valid Typst alignment but not one of
// the three this field accepts).
#import "/lib.typ": set-table-defaults
#set-table-defaults(header-align: top)
