# Conformance suite

A specification that nobody tests is an opinion. This directory is the part of the repository
that can disagree with the compiler.

Twenty-two programs, each paired with a recorded expectation, each run on both execution
planes. A case passes only when the interpreter **and** the compiler produce what the
expectation says — a plane that silently diverges fails the suite, not the user.

```console
$ python3 conformance/run.py --tallow /path/to/tallow
0 failure(s), 20 case(s) run, 2 skipped
```

## The pair

```text
cases/06-loops.tl        the program
cases/06-loops.json      the expectation — recorded, not written by hand
```

The expectation is one of three shapes:

| `kind` | Means | Checked |
|---|---|---|
| `accept` | the program is valid | stdout matches exactly, exit status `0` |
| `reject` | the checker must refuse it | non-zero exit, and the recorded `E…` code appears in the diagnostic |
| `runtime` | valid program, defined runtime failure | non-zero exit, and the recorded message appears in stderr |

Optional keys narrow what a case needs from the binary:

- `planes` — restrict to `["interpret"]` or `["native"]` when only one plane can express the
  behaviour.
- `requires` — the engine feature this case needs (`zk`, `fhe`). Without the feature the case
  is **skipped**, and the refusal of the surface is covered by its own `runtime` case.
- `requires_absent` — the inverse: assert the refusal when a build *does* have the feature.

`19 run · 2 skipped` on a default binary is those two feature cases. `--features zk,fhe` runs
all twenty-one.

## Refresh, and why it is the only honest way to record

```console
$ python3 conformance/run.py --tallow /path/to/tallow --refresh
```

`--refresh` runs each program on both planes first and **refuses** to record a case whose
planes disagree:

```text
REFUSED 14-runtime-nonexhaustive.tl: planes disagree (interp exit 1, native exit 0)
```

That single rule is what keeps the suite honest. A hand-written expectation encodes what
somebody believed; a refreshed one can only encode behaviour the interpreter and the compiler
both produce, so a case can never quietly become a test of "what the compiler happens to do".

Refresh is therefore always a **reviewable diff**: the program is the argument, the JSON is the
receipt. Refresh against the engine commit you intend to pin, in the same change that moves
`spec/generated.json`.

## Adding a case

1. Write the smallest `.tl` program that shows the behaviour, named `NN-topic.tl`.
2. Run it on both planes by hand and confirm they agree. If they do not, it belongs in
   [`findings/`](findings/) instead — see below.
3. `python3 conformance/run.py --tallow <binary> --only NN-topic --refresh` to record it.
4. Read the JSON. If it says `reject`, check the code is the one the spec documents for that
   mistake; a new code is a spec change.
5. Run the whole suite. It must still be green, and the case count must go up by one.

## Findings — where disagreements live

[`findings/`](findings/) holds programs that exposed a real disagreement between the spec and
the engine. They are kept as programs, not prose, so a fixed bug becomes a case and a reopened
one becomes a failure again. [`FINDINGS.md`](FINDINGS.md) records what each established and
whether it is open or fixed.

A finding is promoted to `cases/` only after both planes agree. Until then it is documentation
of a known gap, and the suite's count deliberately does not include it.
