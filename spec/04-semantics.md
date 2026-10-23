# 4. Semantics

This chapter defines what a well-typed program does. Statements about the reference
implementation are marked *(reference)*; everything else follows from the language rules
and is enforced by the conformance suite.

## 4.1 Evaluation order

Expressions evaluate left to right: operands of a binary operator, arguments of a call, and
elements of a slice literal. An assignment evaluates its right-hand side before storing.
This matters only for expressions with effects (calls, `await`, `spawn`), but it is fixed
so that two implementations cannot differ on output ordering.

## 4.2 Truthiness

`if`, `while` and `&&`/`||` accept any value, and coerce it to a boolean:

| Value | Truthy |
|---|---|
| `false`, `nil` | no |
| `0`, `0.0` | no |
| `""` | no |
| empty slice `[]` | no |
| `Err(…)` | no |
| everything else | yes |

A condition whose static type is not `bool` produces **W0103** and is still evaluated by the
table above. *(reference: verified — `if 0`, `if ""`, `if nil`, `if []` all take the false
branch; `if 1` takes the true branch.)*

## 4.3 Arithmetic

- Integer division truncates toward zero: `7 / 2` is `3`, `-7 / 2` is `-3`.
- Remainder takes the sign of the dividend: `-7 % 3` is `-1`.
- `**` is right-associative: `2 ** 3 ** 2` is `512`.
- `*`, `/`, `%` bind tighter than `+`, `-`; `1 + 2 * 3` is `7`.
- `+` is numeric only. `"a" + 1` is **E0110**; string assembly is interpolation
  (`"value {x}"`) or the standard library's helpers.
- Overflow behaviour at the integer widths is the reference implementation's: it does not
  trap in release builds. Programs that depend on wrapping are not portable and SHOULD use
  explicit conversions.

## 4.4 Strings and interpolation

`"text {expr} more"` evaluates each interpolation, converts it with the same rules as
`print`, and concatenates. Conversion renders a `Result` as `Ok(value)` / `Err(message)` and
an absent optional as `nil` — the constructor is visible, not stripped.
*(reference: verified — `print("v={r}")` with `r = Ok(7)` prints `v=Ok(7)`; `print("o={o}")`
with `o: i64? = nil` prints `o=nil`.)*

`+` never concatenates strings: both operands must be numeric (E0110). String assembly is
interpolation, or the standard library's helpers.

## 4.5 Optionals and Result propagation

- `expr?` — if `expr` evaluates to `nil` (for `T?`) or `Err(e)` (for `Result<T>`), the
  enclosing function returns immediately with that absence/error; otherwise the operator
  yields the payload. The enclosing function's return type MUST be compatible.
- `bail expr` — evaluates `expr`, wraps it in `Err`, and returns from the enclosing
  function. The function MUST return a `Result`.
- Comparison with `nil` is by presence, not by value: `f() == nil` is `false` for a present
  optional even when the payload is `0` or `""`.

## 4.6 Blocks, scoping and `defer`

A block `{ … }` is an expression: its value is the trailing expression if present, otherwise
`nil`. Bindings introduced in a block are not visible outside it. `var` bindings are mutable
throughout their scope, and mutation is visible to closures that captured them *(reference)*.

`defer { … }` schedules the block to run when the enclosing scope exits, in last-in,
first-out order, including on `return`, `bail` and error propagation. A `defer` inside a loop
runs at the end of each iteration's scope.

## 4.7 Control flow

- `if` / `else` are expressions.
- `if let Pattern = expr { … }` matches and binds; the binding is visible only in the
  consequent block.
- `while let Pattern = expr { … }` re-evaluates `expr` before each iteration and stops when
  the pattern fails.
- `loop { … }` is an unconditional loop; `break` exits the innermost loop, `continue` starts
  the next iteration. A `break` with a value makes the loop an expression of that type.
- `for x in slice { … }` iterates elements in order.
- `return expr` returns from the enclosing function; a bare `return` returns `nil`.

## 4.8 Match

`scrutinee match { Pattern -> Expr … }` evaluates the scrutinee once and tests arms in
source order. A pattern may be:

- a literal — including a bare integer, which matches an enum variant's discriminant
  (enums are integer-backed: `Color.Red match { 0 -> … }` is the supported form);
- an identifier — binds the value;
- `_` — matches anything, binds nothing;
- a variant pattern `Ok(x)` / `Err(e)`;
- a tuple pattern.

A variant that carries a payload is the exception: it displays as `Variant(payload)` on the
interpreter, and the reference native backend does not yet render it (see
`conformance/FINDINGS.md`, F-04). Programs that print payload variants are therefore not
portable to the native plane today.

An enum value **is** its discriminant, everywhere: it prints as the integer, compares
`==`/`!=` against integers, and matches integer literal patterns. The variant name is
available only through variant patterns (`Color.Red`, or `Red` capitalised as a pattern),
never through arithmetic or display. *(reference: measured on both planes — print → `0`,
`Color.Green == 1` → `true`, `match { 1 -> … }` → the second arm.)*

The first matching arm's expression is the value of the `match`. There is no fall-through
and no implicit `_` arm: a scrutinee that matches nothing is a **runtime error**
(`non-exhaustive match`, located at the `match`), not a compile-time rejection
*(reference: verified)*. A `match` over an open set therefore MUST end with `_` if it is
reachable with an unmatched value.

## 4.9 Decorators and policy passes

Decorators are compile-time contracts, checked by dedicated passes before code generation:

- `@legal(basis: .research, purpose: "…")` — declares the legal basis for processing.
  Required on functions that touch personal data or run as agents.
- `@agent_task(id: …, timeout: …, max_requests: …, can_write: …, can_spawn: …)` — declares
  an agent's autonomy level and resource budget. `can_spawn: true` at level L3 is a compile
  error, and `@legal` is required on every agent function (E0805).

Violations are diagnostics, not runtime checks: a program that fails these passes does not
compile, which is the point — the policy is enforced before the code can run.

## 4.10 Concurrency

- `spawn expr` starts `expr` concurrently and yields a handle.
- `expr.await` waits for the handle and yields its result.
- `select { … }` waits for the first of several operations to become ready.

Concurrency is cooperative inside the runtime; the language does not promise parallelism.
Ordering between spawned tasks is unspecified except where `await`/`select` imposes it, so
programs MUST NOT depend on interleaving.

## 4.11 Process, browser and network surfaces

`process`, `browser`, `net` and the extraction modules are host surfaces (§6). Their
signatures and their failure contract are specified — a call that cannot start a process
returns an `Output` with `exit_code = -1` and the reason on stderr rather than aborting —
but their internal behaviour is the host's, and a conforming implementation MAY provide a
different backend for them.

## 4.12 Mesh execution contract

`Mesh.plan` and `Mesh.replay` (§6) are the published part of the execution plane.
Their results are **deterministic functions of their arguments**, and that is a
requirement, not an implementation detail:

- Seeds derive from `BLAKE3(mesh_seed ‖ wave ‖ task_id ‖ attempt)`. An
  implementation MUST NOT use a clock, an address, or a thread identity to derive
  a seed, so the same plan produces the same values on any worker.
- A wave checkpoint is a hash over the wave's committed results **sorted by task
  id**. Two runs that finish in a different order MUST produce the same
  checkpoint, otherwise `Mesh.replay` could not verify either of them.
- `Mesh.replay` MUST fail on the first wave whose recorded checkpoint does not
  recompute, and MUST refuse a journal that ends inside a wave. A replay that
  matches most waves is a failed replay.

Task classes carry requirements the planner enforces:

- `pure` — re-executing MUST produce an identical result. At most 3 attempts.
- `io` — MUST carry `idempotency_key`; a plan containing an `io` task without one
  is refused. At most 2 attempts.
- `llm` — never retried automatically and never re-executed during replay; the
  recorded response is substituted. 1 attempt.

Ordering inside a wave is the plan's input order, and `Mesh.plan` refuses a
dependency cycle by naming its path (`a -> b -> a`), because "cycle" alone does
not tell a reader which edge to cut.

`Mesh.run` is NOT part of this revision. Executing a plan requires a worker pool
that runs Tallow functions, and no such executor is specified here yet; an
implementation MUST NOT accept a program that calls it.

## 4.13 Name resolution: variables shadow modules

Standard-library modules are reachable by name (`math`, `http`, `llm`, `Mesh`), but
a module name is **not** a reserved word. If a variable is in scope with that name,
the variable wins:

```
let llm = h.llm_calls     // the field, not the module
```

An implementation MUST resolve a bound variable before resolving a module name.
The reverse order silently rewrites ordinary programs — a local named `llm` reads
back as the module sentinel rather than the value it was bound to — and no
diagnostic is produced, because the identifier does resolve.
