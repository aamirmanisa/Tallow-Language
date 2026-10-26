#!/usr/bin/env python3
"""Render this repository's README assets.

    python3 make_assets.py lang

Writes the SVG into this directory — the editable source of truth — and a PNG next
to it at the SVG's own size. Every label is converted to outlines, so no viewer
font can shift a layout.

Rasterising needs Chromium, and Chromium (snap on this host) cannot read /root:
run it from a directory it can open, or point --screenshot at one.

    chromium --headless --no-sandbox --disable-gpu --hide-scrollbars \
             --window-size=W,H --screenshot=out.png in.svg
"""
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from brand import *  # noqa: F401,F403

HERE = os.path.dirname(os.path.abspath(__file__))
PARENT = os.path.dirname(HERE)


def lang_motif(c):
    """A page of the spec, reduced to its rules."""
    b = []
    x, y = 1080, 120
    widths = [330, 300, 345, 250, 320, 190]
    for i, wd in enumerate(widths):
        col = c["accent"] if i == 1 else c["rule"]
        b.append(f'<line x1="{x}" y1="{y + i*36}" x2="{x + wd}" y2="{y + i*36}" '
                 f'stroke="{col}" stroke-width="{3 if i == 1 else 4}"/>')
    b.append(mono(x, y + 6 * 36 + 34, "§ 00—06", 14, c["faint"], spacing="2"))
    return "".join(b)


def node(b, c, x, y, w, h, title, sub=""):
    b.append(box(x, y, w, h, c, fill=c["panel"]))
    b.append(mono(x + 18, y + 30, title, 18, c["text"], spacing="0.4"))
    if sub:
        b.append(mono(x + 18, y + 56, sub, 14, c["muted"]))


def planes(c):
    W, H = 1500, 420
    b = [grain(W, H, c, 50)]
    b.append(mono(64, 60, "ONE PROGRAM, TWO PLANES", 16, c["faint"], spacing="3"))
    node(b, c, 64, 150, 230, 96, "program.tl", "source text")
    b.append(arrow(294, 198, 372, 108, c["rule"]))
    b.append(arrow(294, 198, 372, 288, c["rule"]))
    node(b, c, 380, 68, 330, 84, "interpreter", "reference semantics, directly on the AST")
    node(b, c, 380, 248, 330, 84, "compiler", "LLVM IR  →  clang  →  ELF binary")
    b.append(arrow(710, 110, 800, 168, c["rule"]))
    b.append(arrow(710, 290, 800, 232, c["rule"]))
    b.append(f'<rect x="810" y="150" width="250" height="100" rx="6" fill="{c["panel2"]}" '
             f'stroke="{c["accent"]}" stroke-width="1.5"/>')
    b.append(mono(835, 192, "identical", 24, c["accent"]))
    b.append(mono(835, 222, "stdout · stderr · exit", 14, c["muted"]))
    b.append(arrow(1060, 200, 1120, 200, c["rule"]))
    b.append(box(1128, 150, 306, 100, c, fill=c["panel"]))
    b.append(mono(1148, 186, "recorded expectation", 17, c["text"]))
    b.append(mono(1148, 214, "cases/06-loops.json", 14, c["muted"]))
    b.append(mono(1148, 236, "regenerate: --refresh", 13, c["faint"]))
    b.append(mono(64, H - 44,
                  "the suite refuses to record a case whose two planes disagree", 15, c["faint"]))
    return svg(W, H, "".join(b), c["bg"])


RECIPES = {
    "lang": [
        ("lang-hero", lambda c: hero(1600, 420, "TALLOW / LANGUAGE", "Tallow",
                                     "The language, written down.",
                                     "SPECIFICATION   ·   TUTORIAL   ·   CONFORMANCE",
                                     c, lang_motif(c))),
        ("lang-planes", planes),
    ],
}


def main():
    which = sys.argv[1] if len(sys.argv) > 1 else "lang"
    if which not in RECIPES:
        sys.exit(f"usage: {sys.argv[0]} [{'|'.join(RECIPES)}]")
    for name, render in RECIPES[which]:
        for theme, c in THEMES.items():
            svg_text = render(c)
            src = os.path.join(HERE, f"{name}-{theme}.svg")
            with open(src, "w") as fh:
                fh.write(svg_text)
            head = svg_text.split(">", 1)[0]
            w = int(head.split('width="')[1].split('"')[0])
            h = int(head.split('height="')[1].split('"')[0])
            png = os.path.join(PARENT, f"{name}-{theme}.png")
            subprocess.run(["chromium", "--headless", "--no-sandbox", "--disable-gpu",
                            "--hide-scrollbars", f"--window-size={w},{h}",
                            f"--screenshot={png}", src],
                           check=False, capture_output=True)
            print(f"{name}-{theme}.svg  {w}x{h}  -> {os.path.basename(png)}")


if __name__ == "__main__":
    main()
