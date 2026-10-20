# 3. Types

Tallow is statically typed: every binding, field, parameter and return value has a type
fixed at compile time. There is no implicit `nil` for non-optional types and no implicit
conversion between numeric widths.

## 3.1 Built-in types

| Type | Meaning |
|---|---|
| `bool` | `true` / `false` |
| `i8` `i16` `i32` `i64` `i128` `isize` | signed integers |
| `u8` `u16` `u32` `u64` `u128` `usize` | unsigned integers |
| `f32` `f64` | IEEE-754 floats |
| `String` | UTF-8 text |
| `Bytes` | byte buffer |
| `char` | one character |
| `nil` | the absent value; the only inhabitant of `T?` when no value is present |

An integer literal has type `i64` unless the context demands otherwise; a float literal has
type `f64`. A name that is not a built-in and not declared in scope produces **W0100**
(`type … is not defined in this scope`) and is treated as the default integer — a warning,
not an error, so a typo in a type position does not silently change behaviour without a
diagnostic.

The names `Int` and `Float` used in the standard library's declaration files are **not**
language types: user code that writes `fn f(x: Int)` gets W0100. Use `i64` / `f64`.

## 3.2 Composite types

```
[]T        slice of T                    []String, [[Float]]
T?         optional T                    i64?, WaitResult?
(A, B)     tuple                        (String, i64)
fn(T) -> R function value               fn(i64) -> i64
Result<T>  success or error              Result<i64>
Box<T>     heap indirection              Box<Node>
impl T     opaque trait implementor      impl Iterator
dyn T      dynamic trait object          dyn Iterator
Name<T>    user generic                  Map<String, i64>
```

Slices are the only sequence type; there is no fixed-size array type. `[]T` may be nested
(`[[Float]]`), and a slice of structs (`[]Item`) is the normal way to return extracted rows.

## 3.3 Optionals

`T?` is a value that is either a `T` or `nil`.

- `nil` is assignable only to an optional.
- `x == nil` and `x != nil` are always legal on an optional and are the only comparisons
  that do not require unwrapping.
- Printing an optional prints the payload (`5`) or `nil`.
- Using an optional where a `T` is required is a type error. In particular **arithmetic on
  an optional is rejected**: `r.elapsed_ms + 1` with `elapsed_ms: i64?` is
  `E0110 left operand of + must be numeric, got i64?`. Unwrap first (`match`, `if let`, or
  the `?` operator inside a function that returns an optional).

## 3.4 Results

`Result<T>` is `Ok(value)` or `Err(message)`. It is an ordinary generic type from the
standard library, with three language-level affordances:

- `bail expr` constructs an `Err` and returns it from the enclosing function, whose return
  type MUST be a `Result`.
- The `?` postfix operator propagates: on `Err` it returns from the enclosing function with
  that error; on `Ok` it yields the payload.
- `match` on a `Result` uses variant patterns `Ok(x)` / `Err(e)`.

A function returning `Result<T>` MUST return a value of that type on every path; the
type checker does not insert an implicit `Ok`.

## 3.5 Functions and closures

A function value has type `fn(T, U) -> R`. Closures are function values with captured
environment; their type is the same `fn(...) -> R`.

Portability note: the reference native backend represents a function value as one pointer
called through the closure ABI `i64 (ptr env, args…)`, so a `fn(..)` binding is callable
on both planes (F-05, fixed). What does not cross a call boundary is a *capturing*
closure: its environment lives in the caller's frame and there is no slot for it in the
value (F-07). Direct calls of a capturing closure do compile natively (F-06).

A method declared in an `impl` block receives `self` as its first parameter and is called
with dot syntax (`page.title`, `page.goto(url)`). A trait declares method signatures;
`impl Trait for Type` must provide every non-default method or the program is rejected
(**E0401**), and naming a trait that does not exist is **E0400**.

## 3.6 Mutability and visibility

- `let` binds immutably; assigning to a `let` binding is an error.
- `var` binds mutably.
- `const` is an item-level immutable binding and MUST have a type and an initialiser.
- Struct fields may carry the qualifiers `private` and `secret` (`private: SecretBytes`).
  A `secret` field is a type qualifier with policy consequences: passes such as the
  constant-time and secret-handling checks treat it as sensitive material, and the
  diagnostics for misusing it are in §5 (W12xx).

## 3.7 Diagnostics that are warnings

Not every type irregularity is fatal. Conditions that are not `bool` produce **W0103** and
are evaluated by the truthiness rules of §4.2; undefined type names produce **W0100** and
fall back to the default integer. Both are warnings because the program still has a
defined meaning; a conforming implementation MUST emit the diagnostic and MUST apply the
same fallback, or reject the program outright — silently doing something else is not
conforming.
