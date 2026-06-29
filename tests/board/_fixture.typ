// Shared fixture for the board tests. All low-level drawing tests use ONE
// arbitrary position so they are directly comparable; edit it here once to
// re-point every board test.
//
// Chosen position: an Italian Game a few moves in. It has all six piece kinds,
// both colours, and is asymmetric (so flips and labels are visually
// unambiguous). The "_" prefix makes the runner skip this file.
#let test-fen = "r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQK2R w KQkq - 0 5"
