# 1. Hello

A Tallow program is a set of `fn` declarations. Execution starts at `main`.

```tallow
fn main() {
    print("hello, world")
}
```

Save it as `01-hello.tl` and run it on either plane — both must print the same
thing:

```sh
tallow run --require-native 01-hello.tl   # compile to a binary and run it
tallow run --interpret      01-hello.tl   # run it in the interpreter
```

```
hello, world
```

`--require-native` is the honest switch: if the compiler cannot lower something
in this program, it says so and exits instead of quietly running the interpreter
and reporting a pass.

Next: [2. Values](02-values.md)
