// FINDING (1.7.0, measured 2026-11-02): the two planes disagree on an index into
// a literal array-of-arrays.
//
//   tallow run --interpret      nested-array-index.tl  -> 30
//   tallow run --require-native nested-array-index.tl  -> 0     (exit 0, both)
//
// The compiled plane does not fail here — it silently prints the wrong element,
// which is worse than a refusal. `[[10,20],[30,40]].zip(...)`-shaped arrays were
// fixed for 1.7.0 (the element of a NonScalar array is an untagged inner array,
// not a string); a literal nested array is a different producer and still takes
// the string path.
//
// This file lives in conformance/findings/ rather than conformance/cases/
// because a case asserts that the planes agree, and here they do not.
fn main() {
    let m = [[10, 20], [30, 40]]
    print(m[1][0])
}
