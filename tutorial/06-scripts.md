# 06 — Scripts

A `.tl` file is a program you can execute, not an argument you must spell out.

```tallow
#!/usr/bin/env tallow
fn main() {
    print("hello from a script")
}
```

```console
$ chmod +x hello.tl
$ ./hello.tl
hello from a script
$ tallow run hello.tl          # same thing, spelled out
```

Three details make that work, and each of them was a defect until recently:

- **The `#!` line is not program text.** It is blanked, not deleted, so line
  numbers in errors still match the file you are looking at: an error on line 2
  is reported at line 2, not line 1.
- **Arguments after the path belong to the program.** `./wc.tl notes.txt` passes
  `notes.txt` to the program, not to the compiler.
- **`tallow app.tl` works too** — a path is accepted where a subcommand would go.

## Arguments

`env.args()` returns the program's own arguments. The script path is *not* in
it:

```console
$ ./wc.tl notes.txt
2 4 23 notes.txt
```

`args[0]` is `notes.txt`.

## Exit codes

`exit(n)` and `process.exit(n)` end the program with `n`. This is what makes a
script usable in a pipeline — and, until the fix, what made every program with
an `exit` inside an `if` lose its native plane:

```tallow
if found > 0 {
    exit(1)
}
```

## Two complete scripts

`examples/scripts/wc.tl` — lines, words and bytes, matching `wc -l -w -c`:

```console
$ ./wc.tl notes.txt
2 4 23 notes.txt
```

`examples/scripts/todo.tl` — every TODO / FIXME / XXX with its line number,
exit 1 when there is at least one:

```console
$ ./todo.tl src/main.rs
src/main.rs:118: // TODO: hoist the retry policy
$ echo $?
1
```

Both are run by `tutorial/run-all.sh` with a real file argument on both planes,
so a regression in either shows up as a failing tutorial rather than as a
surprise for a user.
