# Tallow

Tallow is a statically typed language for writing web scrapers, extraction pipelines and
browser automation — with the network, browser and extraction primitives in the standard
library instead of in a framework.

```tallow
fn main() {
    let page = browser.open("https://example.com")
    print(page.title)
}
```

This repository is the **language** half of Tallow: the specification, the tutorial, the
conformance suite, and the packaged compiler. The **engine and scraper system** live in
[tallowsphere](https://github.com/aamirmanisa/tallowsphere).

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/aamirmanisa/Tallow-Language/main/install/install.sh | sh
tallow --version
```

No release has been published yet; `install.sh` explains what it looked for and exits
non-zero rather than installing something unverified.

## The two repositories

| | Tallow-Language (this repo) | tallowsphere |
|---|---|---|
| Role | language surface: spec, tutorial, conformance, distribution | the reference implementation and the scraper system |
| Contains | prose that defines the language, runnable examples, test cases, prebuilt binaries | compiler, runtime, stdlib, browser engine, services |
| Licence | spec text CC BY 4.0; examples and tooling MIT | MIT (root workspace) |

The split is deliberate: there is exactly **one** implementation of the compiler, and it
lives in tallowsphere. This repository never carries a second copy of it, so the two can
never disagree about what the language *is* — only about whether the engine matches the
spec, which is what the conformance suite measures.

## What is specified, and what is not

The specification covers the language: lexical form, grammar, type system, evaluation
semantics, the error model, and the error-code catalogue.

It does **not** specify the behaviour of the standard library's I/O modules beyond their
signatures and documented contracts. `browser.*`, `net.*` and the extraction modules are
runtime surfaces with an ABI; they are documented here so programs are writable, but an
independent implementation is expected to provide its own I/O, not to match byte-for-byte.

## Conformance

```sh
python3 conformance/run.py --tallow /path/to/tallow
```

Every case is a `.tl` program plus the exact stdout and exit status the reference engine
produced. Expectations are recorded, never hand-edited:

```sh
python3 conformance/run.py --tallow /path/to/tallow --refresh
```

`--refresh` refuses to record a case whose two planes disagree, so a case can only encode
behaviour the interpreter and the compiler share. CI runs the suite against the packaged
binary.

## Tutorial

`tutorial/01-hello.md` … `05-results.md` build the language up in five steps. Every
chapter's program is also a standalone file, and the claim "each chapter runs" is checked
rather than asserted:

```sh
./tutorial/run-all.sh /path/to/tallow
```

The script runs each program on both planes and fails if either refuses or if their output
differs. `examples/` is under the same gate.

## Repository layout

```
spec/           the language specification, in reading order
tutorial/       a guided introduction, each chapter runnable
examples/       complete programs
conformance/    cases/ (programs + expectations) and run.py
tools/          generate.py — regenerates the generated sections from the engine
install/        install.sh and packaging notes
```

## Licence

Specification prose: CC BY 4.0 (`LICENSE-SPEC`). Examples, conformance cases and tooling:
MIT (`LICENSE`). The engine is MIT in its own repository.
