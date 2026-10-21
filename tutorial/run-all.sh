#!/usr/bin/env bash
# Prove the claim "each chapter is runnable": every program under tutorial/
# programs/ and examples/ must produce identical output on both planes.
#
#   ./tutorial/run-all.sh /path/to/tallow
#
# The binary must be a build of the engine that ships this repository's spec.
# A program that fails to compile natively is a FAILURE here, not a skip: the
# interpreter is the reference, the compiler is what ships.
set -uo pipefail

TALLOW="${1:-tallow}"
root="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
ran=0

run_one() {
    local file="$1"
    local native interp nerr ierr
    nerr="$(mktemp)"; ierr="$(mktemp)"
    native="$("$TALLOW" run --require-native "$file" 2>"$nerr")"
    local nrc=$?
    interp="$("$TALLOW" run --interpret "$file" 2>"$ierr" | sed '/^\* /d')"
    local irc=${PIPESTATUS[0]}
    ran=$((ran + 1))

    if [ $nrc -ne 0 ]; then
        printf 'FAIL %s\n  native plane refused:\n%s\n' "${file#$root/}" "$(sed 's/^/    /' "$nerr")"
        fail=$((fail + 1))
        return
    fi
    if [ $irc -ne 0 ]; then
        printf 'FAIL %s\n  interpreter refused:\n%s\n' "${file#$root/}" "$(sed 's/^/    /' "$ierr")"
        fail=$((fail + 1))
        return
    fi
    if [ "$native" != "$interp" ]; then
        printf 'FAIL %s\n  the two planes disagree:\n' "${file#$root/}"
        diff <(printf '%s\n' "$native") <(printf '%s\n' "$interp") | sed 's/^/    /'
        fail=$((fail + 1))
        return
    fi
    rm -f "$nerr" "$ierr"
    printf 'ok   %s\n' "${file#$root/}"
}

shopt -s nullglob
for f in "$root"/tutorial/programs/*.tl "$root"/examples/*.tl; do
    run_one "$f"
done

printf '\n%d program(s), %d failure(s)\n' "$ran" "$fail"
[ "$fail" -eq 0 ]
