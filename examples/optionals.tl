// Optionals: a function that can fail to produce a value says so — `i64?`.
//
// `match` is the only unwrap the language has: `Some(x)` binds the value,
// `None` takes the absent branch. Both arms must produce the same type.
fn divide(a: i64, b: i64) -> i64? {
    if b == 0 { return nil }
    return a / b
}

fn main() {
    print(divide(10, 2))
    print(divide(1, 0) == nil)

    let half = divide(10, 2) match {
        Some(x) -> x
        None -> 0 - 1
    }
    print(half)

    let missing = divide(1, 0) match {
        Some(x) -> x
        None -> 0 - 1
    }
    print(missing)
}
