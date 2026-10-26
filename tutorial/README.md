# Tutorial

Six chapters. Each one introduces the smallest thing that makes the next chapter readable, and
each one ends with a program you can run.

| Chapter | Settles | Program |
|---|---|---|
| [01 · Hello](01-hello.md) | A program, a build, an exit code | [`programs/01-hello.tl`](programs/01-hello.tl) |
| [02 · Values](02-values.md) | Types, literals, operators, strings | [`programs/02-values.tl`](programs/02-values.tl) |
| [03 · Control](03-control.md) | `if`, `while`, `for`, `match` | [`programs/03-control.tl`](programs/03-control.tl) |
| [04 · Functions](04-functions.md) | Signatures, returns, recursion, closures | [`programs/04-functions.tl`](programs/04-functions.tl) |
| [05 · Results](05-results.md) | `Result`, `Option`, exhaustive matching | [`programs/05-results.tl`](programs/05-results.tl) |
| [06 · Scripts](06-scripts.md) | Shebangs, arguments, exit codes | [`../examples/scripts/`](../examples/scripts/) |

## Running a chapter

You need a Tallow binary. Install one, or build the engine from
[tallowsphere](https://github.com/aamirmanisa/tallowsphere):

```console
$ curl -fsSL https://raw.githubusercontent.com/aamirmanisa/Tallow-Language/main/install/install.sh | sh
$ tallow --version
```

Then run any program on either plane:

```console
$ tallow run --interpret      tutorial/programs/01-hello.tl
$ tallow run --require-native tutorial/programs/01-hello.tl
```

`--require-native` is the honest switch. If the compiler cannot lower something in the program,
it says so and exits instead of quietly falling back to the interpreter and reporting a pass —
which is why the chapters use it.

## Prove the whole set

```console
$ ./tutorial/run-all.sh /path/to/tallow
```

The script runs every program under `tutorial/programs/` and `examples/` on **both** planes and
fails when the outputs differ, when either plane refuses, or when a script exit code is wrong.
A program that only passes on one plane is a failure here, not a skip.

## Writing a chapter

- One idea per chapter, introduced by a program that runs.
- Show the output you actually got, including the exit code when it matters.
- Use `--require-native` whenever the program is expected to compile; a chapter that quietly
  depends on the interpreter teaches a language the binary does not implement.
- Add the program to `tutorial/programs/` and check that `run-all.sh` prints `ok` for it.
