// EXPECT: unknown table grid: "bogus" (expected "complete", "no-outer", or "header-rule")
// set-table-defaults rejects an unknown `grid` preset.
#import "/lib.typ": set-table-defaults
#set-table-defaults(grid: "bogus")
