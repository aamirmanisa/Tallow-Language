# Contributing

This repository holds a normative document, a tutorial and an arbiter. The useful contributions
are the ones that make one of those three more true — not more features.

## What is worth sending

- **A case that fails.** A `.tl` program whose output differs from the spec is the most valuable
  artifact here. Add it under `conformance/findings/` with the disagreement stated in
  `FINDINGS.md`.
- **A chapter that confuses.** Tutorial prose is code. If a step does not run, or runs but does
  not explain, that is a bug in this repository.
- **A spec sentence that can be read two ways.** Ambiguity in a normative document is a defect
  even when both readings are currently satisfied.
- **A dead link, a stale count, a claim with no label.** These are cheap to fix and they are the
  ones that make a reader stop trusting the rest.

Proposed features for the language belong in the engine repository,
[tallowsphere](https://github.com/aamirmanisa/tallowsphere). A feature request here will be
answered with "write the case first".

## Before you open a pull request

```console
$ python3 conformance/run.py --tallow /path/to/tallow     # corpus, both planes
$ ./tutorial/run-all.sh /path/to/tallow                   # chapters and examples
$ python3 tools/check_drift.py --engine /path/to/tallowsphere   # spec vs engine
```

All three must pass, and the output you paste into the description must be the output you got —
not a retyped approximation. If a command could not be run (no aarch64 host, no engine
checkout), say which one and why.

## Commit messages

Scope prefix, then the change, then the evidence. The scope is the part of the repository you
touched: `spec`, `tutorial`, `conformance`, `tools`, `install`, `assets`.

```text
conformance: the truthiness case now covers "" and [] on both planes
spec: repin at engine 8edc189
tools: a pin-only move is not content drift
```

A change that moves a count states the old and the new number. A change that fixes a claim says
which claim was wrong — the correction is the reviewable part.

## Editing rules

- **Do not hand-edit generated chapters.** `spec/01`, `05` and `06` are produced by
  `tools/generate.py`; fix the generator or the engine instead. See [`spec/README.md`](spec/README.md).
- **Do not record an expectation by hand.** Use `--refresh`; it refuses a case whose planes
  disagree.
- **Do not carry an unlabelled number.** Quantitative claims in prose carry `[measured YYYY-MM-DD]`
  with the command that produced them.
- **Do not delete a finding because it is inconvenient.** Fix it, or leave it in `findings/`
  where the suite's own count cannot hide it.

## Licence

Contributions to the specification prose are accepted under CC BY 4.0; contributions to examples,
conformance cases, tooling and assets under MIT. See [`LICENSE-SPEC`](LICENSE-SPEC) and
[`LICENSE`](LICENSE).
