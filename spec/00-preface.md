# 0. Preface

## 0.1 What this document is

This is the specification of the Tallow language: the rules a program must satisfy to be
valid, and the behaviour a valid program has. It is normative for the language. It is not
a manual for the standard library's I/O surfaces, and it is not a description of the
reference implementation's internals.

Where this document and the reference implementation (`tallowsphere`) disagree, **the
disagreement is a bug**, and it is recorded as such: the conformance suite in
`conformance/` is the arbiter, and its expectations are regenerated from the engine rather
than hand-written. A change in behaviour that the suite does not cover is not part of the
language yet.

## 0.2 Normative language

- **MUST / MUST NOT** — a requirement. A program or implementation that violates it is
  non-conforming.
- **SHOULD** — a strong recommendation; deviation is allowed only with a stated reason.
- **MAY** — genuinely optional.

## 0.3 Conformance

An implementation conforms to this specification at version *v* if it:

1. accepts every program in `conformance/cases/` that the suite marks as accepted, and
   produces the recorded stdout and exit status;
2. rejects every program the suite marks as rejected, with a diagnostic carrying the
   recorded error code;
3. implements the type rules of §3 and the evaluation rules of §4.

The suite is versioned with the engine release it was generated from; a conformance claim
is always relative to a pinned `(spec version, engine commit)` pair.

## 0.4 Specification and implementation

Tallow has exactly one implementation. This document does not describe a second one, and it
does not attempt to make independent implementations bit-compatible in areas where the
language delegates to the runtime: the browser, the network, the extraction pipeline and
the process FFI are *host surfaces*, documented by signature and contract in §6, whose
observable behaviour beyond the contract is the host's business.

What an independent implementation must match is the part that compiles: lexing, parsing,
name resolution, typing, and the evaluation semantics of the language's own constructs.

## 0.5 Reading order

| Chapter | Answers |
|---|---|
| 1. Lexical structure | What is a token? What are the reserved words? |
| 2. Grammar | What is a syntactically valid program? |
| 3. Types | What programs type-check? |
| 4. Semantics | What does a valid program do? |
| 5. Error catalogue | Which diagnostic codes exist, and where are they raised? |
| 6. Standard library index | What is callable, with what signature? |

## 0.6 Versioning

The specification version tracks the engine's crate version (`Cargo.toml` in
`tallowsphere`). A change that alters which programs are accepted, or what an accepted
program prints, MUST be accompanied by a spec change and a regenerated conformance suite
in the same release. Editorial changes are made freely and do not move the version.
