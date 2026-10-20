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

## F-03 — non-exhaustive `match` (findings → now `cases/14`, `cases/15`) — **FIXED**

```
before:  interpreter  runtime error: non-exhaustive match   exit 1
         native       (null)                                 exit 0

         string subject, single arm:
         native       "x" match { "a" -> "A" }  printed "A"  exit 0
```

The native plane invented a value. Both emitters now call a `noreturn` helper that
reports `runtime error: non-exhaustive match` and exits 1, matching the interpreter
(`tallowsphere` e79c4da, register #123). The two programs are now conformance cases and
run on both planes.

The string variant was the more dangerous of the two: the failing `strcmp` branched into
the merge block while the PHI listed only the body block, so LLVM folded the guard away
and the arm body ran unconditionally — a guard that silently stops guarding.

## F-04 — printing a data-carrying enum (findings/04-print-data-enum.tl) — **OPEN**

```
interpreter: Pending("awaiting review")     exit 0
native:      <0x01>                         exit 0
```

Unit variants agree on both planes — they print their discriminant (`0`, `1`, …).
A variant with a payload does not: the native path prints a raw byte of the payload,
so the output is a control character. The interpreter keeps the constructor form, which
is the only shape that carries the payload.

Status: open (engine register #125). Options: lower enum printing to a name table plus a
payload formatter, or refuse to compile `print` of a data variant — a loud refusal is
cheap, a correct rendering is feature work.
