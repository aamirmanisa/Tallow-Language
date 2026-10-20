# Divergences found by writing the suite

Each program below runs on the current engine and produces **different answers on the two
planes**. They are not in `cases/` because the suite's rule is that a case must pass on
both planes; a program that only passes on one belongs here until the planes agree.

Reproduce any of them with:

```sh
tallow run --interpret        findings/<file>.tl
tallow run --require-native   findings/<file>.tl
```

## F-01 — truthiness of `""` and `[]` (findings/03-truthiness.tl)

| program | interpreter | native |
|---|---|---|
| `if 0` | F | F |
| `if ""` | **F** | **T** |
| `if nil` | F | F |
| `if []` | **F** | **T** |
| `if 1` | T | T |
| `if "x"` | T | T |

The interpreter tests emptiness; the native plane tests only non-nullness. §4.2 of the
specification says empty string and empty slice are falsy — so the **native plane is the
defect**. Status: open (engine register #122).

## F-02 — closures are interpreter-only (findings/08-closures.tl)

```
native: error[E…] native build unavailable (call to unknown function …)
```

Function values and closures do not lower in the native backend; the build fails loudly
rather than silently calling 0, which is the right failure mode, but it means a language
feature has no native implementation. Status: open (engine register #124).

## F-03 — a non-exhaustive `match` yields `null` natively (findings/14-runtime-nonexhaustive.tl)

```
interpreter: runtime error: non-exhaustive match (at 3:5)   exit 1
native:      (null)                                         exit 0
```

The interpreter rejects the program at runtime; the native plane silently produces a null
value, which then prints as `(null)`. Silent-wrong-answer on a shipped binary is the worst
class of divergence in this project's own rules. Status: open (engine register #123).
