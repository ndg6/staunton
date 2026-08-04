// Tournament tables export to real, semantic HTML <table> elements (not SVG).
// HTML-HAS: <table
// HTML-HAS: <thead
// HTML-HAS: </table>
#import "/lib.typ": games, standings-table
#let rr = games(```
[White "A"][Black "B"][Result "1-0"] 1-0
[White "A"][Black "C"][Result "1-0"] 1-0
[White "B"][Black "C"][Result "1-0"] 1-0
```)
#standings-table(rr)
