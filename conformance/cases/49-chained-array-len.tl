// 1.7.0: `.len` on a chained call that returns a string array must read the
// array's count slot. Before the fix the compiled plane ran strlen over
// `[count: i64][slot: i64]…`, which reads the count's low byte and stops at the
// NUL of its second byte — so a three-element result answered 1 on the compiled
// plane and 3 in the interpreter. This case pins the agreement.
//
// The shape needs a chained call: a bound value was already tracked, which is
// why the browser cookie arrays and `Transfer.chunk(...)` could disagree for two
// releases without any case noticing.
fn main() {
    print("a,b,c".split(",").len)
}
