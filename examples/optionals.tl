// Optionals: a function that can fail to produce a value says so — `i64?`.
//
// What works on both planes today: producing the optional (`return nil` or a
// value), printing it, and testing it with `== nil`. What does NOT compile
// natively yet is unwrapping it: `match` on an optional and `??` are refused
// (register #134), so this example tests presence instead of pretending to
// unwrap. `--require-native` refuses rather than silently running the
// interpreter, which is why the gap is visible here instead of hidden.
fn divide(a: i64, b: i64) -> i64? {
    if b == 0 { return nil }
    return a / b
}

fn main() {
    print(divide(10, 2))
    print(divide(1, 0))
    print(divide(1, 0) == nil)
    print(divide(10, 2) == nil)
}
