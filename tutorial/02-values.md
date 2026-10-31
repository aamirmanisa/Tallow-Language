# 2. Values and printing

`let` binds a name once; `var` binds one you intend to change. Types are
inferred from the initialiser: `String`, `i64`, `f64`, `bool`.

```tallow
fn main() {
    let name = "Tallow"
    let year = 2026
    let ratio = 0.5
    let ready = true

    print("hello, {name}")
    print(year + 1)
    print(ratio * 4.0)
    print(ready)
    print(year / 2)
}
```

```
hello, Tallow
2027
2
true
1013
```

Three things worth noticing:

- `{name}` interpolates inside a string literal, and that is the idiomatic way to
  build one. `+` on two strings concatenates (`"a" + "b"` is `ab`, both planes);
  it is not the recommended style, and mixing a string with a non-string operand
  is `E0110` (`"a" + 1`).
- `2026 / 2` is integer division: `1013`. Use `f64` when you want a fraction.
- `print` renders each type the way the type is written: `true`, not `1`.

Next: [3. Control flow](03-control.md)
