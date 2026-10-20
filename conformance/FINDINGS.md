# Divergences found by writing the suite

Each program below runs on the current engine and produces **different answers on the two
planes**. They are not in `cases/` because the suite's rule is that a case must pass on
both planes; a program that only passes on one belongs here until the planes agree.

Reproduce any of them with:

```sh
tallow run --interpret        findings/<file>.tl
tallow run --require-native   findings/<file>.tl
```

## F-01 — truthiness of `""` and `[]` — **FIXED** (now `cases/17-truthiness.tl`)

```
before:  interpreter  F F F F T T
         native       F T F T T T      ("" and [] were truthy)
after:   both planes  F F F F T T
```

Native tested pointer non-nullness. Conditions now dispatch on the expression
(`truthy_of`): arrays by count, strings by first byte, other pointers by non-nullness
(`tallowsphere` c1c1e1c-class change, register #122).

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

## F-04 — printing a data-carrying enum (findings/04-print-data-enum.tl) — **REFUSED LOUDLY**

```
before:  interpreter  Pending("awaiting review")
         native       <0x01>                              (a control byte)
now:     tallow run               Pending("awaiting review")   (interpreter fallback)
         --require-native        exit 1, "cannot print a data-carrying enum natively:
                                 it is a tagged struct, not a string …"
```

Unit variants agree on both planes — they print their discriminant. A variant with a
payload is a tagged struct natively, and the string printer used to walk its tag. The
native backend now refuses that print, so no garbage reaches stdout; rendering the
variant and its payload natively (a name table plus a formatter) is future work.

Status: refused (engine register #125, `tallowsphere` 35307b3).
