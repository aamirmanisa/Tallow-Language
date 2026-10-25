#!/usr/bin/env python3
"""Detect spec drift against an engine tree.

Two kinds of drift matter, and they need different verdicts:

* **Content drift** — the engine's keywords, tokens, error codes, modules or
  declarations changed and the spec was not regenerated. That is a failure:
  the published language surface disagrees with the published engine.
* **Pin drift** — only `engine_sha` / `generated` differ. The content is
  identical, so the spec is merely behind. That is a warning, not a failure,
  because demanding a spec commit per engine commit produces noise that
  trains people to ignore the job.

Usage:
    tools/check_drift.py --engine /path/to/engine [--repo .]
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path


def run_generate(engine: Path, repo: Path, date: str) -> None:
    subprocess.run(
        [sys.executable, str(Path(__file__).resolve().parent / "generate.py"),
         "--engine", str(engine), "--repo", str(repo), "--date", date],
        check=True, capture_output=True, text=True,
    )


def normalize(text: str, shas: set[str]) -> str:
    for sha in shas:
        if sha:
            text = text.replace(sha, "<engine-sha>")
    text = re.sub(r"\b20\d\d-\d\d-\d\d\b", "<date>", text)
    return text


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--engine", required=True)
    ap.add_argument("--repo", default=str(Path(__file__).resolve().parent.parent))
    a = ap.parse_args()

    engine, repo = Path(a.engine), Path(a.repo)
    current = json.loads((repo / "spec" / "generated.json").read_text())
    current_sha = current.get("engine_sha", "")
    engine_sha = subprocess.run(
        ["git", "-C", str(engine), "rev-parse", "HEAD"],
        capture_output=True, text=True, check=True).stdout.strip()

    with tempfile.TemporaryDirectory() as tmp:
        tmp_repo = Path(tmp)
        (tmp_repo / "spec").mkdir(parents=True)
        run_generate(engine, tmp_repo, current.get("generated", "2026-01-01"))
        fresh = json.loads((tmp_repo / "spec" / "generated.json").read_text())

        counts = ("keywords", "tokens", "error_codes", "stdlib_modules", "stdlib_fns")
        differing = [k for k in counts if current.get(k) != fresh.get(k)]
        if differing:
            print("DRIFT: the engine surface changed and the spec was not regenerated")
            for k in differing:
                print(f"  {k}: spec {current.get(k)} -> engine {fresh.get(k)}")
            return 1

        # Generated docs name the engine with a SHORT sha; normalize every
        # abbreviation of both pins, or a pin-only move reads as content drift.
        shas = {current_sha, engine_sha}
        for sha in list(shas):
            if sha:
                shas.update({sha[:7], sha[:8], sha[:12]})
        doc_diffs = []
        for f in sorted((tmp_repo / "spec").glob("*.md")):
            target = repo / "spec" / f.name
            if not target.exists():
                doc_diffs.append(f"{f.name}: missing from the spec tree")
                continue
            if normalize(target.read_text(), shas) != normalize(f.read_text(), shas):
                doc_diffs.append(f"{f.name}: prose or tables differ")
        if doc_diffs:
            print("DRIFT: generated spec documents differ from a fresh generation")
            for d in doc_diffs:
                print(f"  {d}")
            return 1

    if current_sha != engine_sha:
        print(f"PIN: spec pinned at {current_sha or 'unknown'}, engine at {engine_sha[:7]} — "
              f"content identical, regenerate to refresh the pin")
        return 0
    print(f"OK: spec matches engine {engine_sha[:7]} ({current.get('stdlib_modules')} modules, "
          f"{current.get('stdlib_fns')} functions)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
