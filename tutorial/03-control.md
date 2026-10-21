# 3. Control flow

`if` is a statement. `for` walks a list; `while` takes a condition. `break` and
`continue` work in both.

```tallow
fn main() {
    var total = 0
    for n in [1, 2, 3, 4, 5] {
        if n == 3 { continue }
        total += n
    }
    print(total)

    var countdown = 3
    while countdown > 0 {
        print(countdown)
        countdown -= 1
    }
}
```

```
12
3
2
1
```

`total` skips the `3` because `continue` runs before the addition. `var` is
required for both counters: `let total = 0` followed by `total += n` is a
compile error, not a silent no-op.

Next: [4. Functions](04-functions.md)
