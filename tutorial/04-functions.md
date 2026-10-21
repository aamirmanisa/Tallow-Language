# 4. Functions

A function declares its parameter and return types. The last expression is the
return value; `return` exits early.

```tallow
fn factorial(n: i64) -> i64 {
    if n <= 1 {
        return 1
    }
    return n * factorial(n - 1)
}

fn sign_word(n: i64) -> String {
    if n < 0 { return "negative" }
    if n == 0 { return "zero" }
    return "positive"
}

fn main() {
    print(factorial(6))
    print(sign_word(-4))
    print(sign_word(0))
}
```

```
720
negative
zero
```

`return` leaves the function immediately, so the three `if`s in `sign_word` are
exhaustive by construction and the type checker accepts the last `return` as the
fallback. Recursion needs no annotation: the return type `i64` is enough.

Next: [5. Results](05-results.md)
