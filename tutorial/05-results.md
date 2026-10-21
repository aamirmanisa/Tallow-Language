# 5. Results

A function that can fail says so in its type: `Result<T>`. `Ok(value)` succeeds,
`bail "reason"` fails with a message, and `match` is how a caller decides what to
do.

```tallow
fn parse_positive(n: i64) -> Result<i64> {
    if n <= 0 {
        bail "not positive"
    }
    Ok(n)
}

fn main() {
    print(parse_positive(5))
    print(parse_positive(0))

    let doubled = parse_positive(21) match {
        Ok(x) -> x * 2
        Err(e) -> 0
    }
    print(doubled)
}
```

```
Ok(5)
Err("not positive")
42
```

Printing a `Result` shows which arm it is — it never prints a bare `5` that could
be mistaken for success.

One honest caveat, measured on both planes: a `Result` that is evaluated and not
matched is **discarded silently today** — `bad()` on its own line neither prints
nor changes the exit status, and `tallow check` emits no warning. Until that is
closed (it is tracked as a defect, not a feature), always `match` a `Result` or
bind it.

Next: read the [specification](../spec/00-preface.md) for the rules behind these
programs, or the [conformance suite](../conformance/) for the cases that pin them
down on both planes.
