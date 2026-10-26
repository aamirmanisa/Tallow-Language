# Visual identity — Tallow language repository

The README is the front page of a normative document, so the design job is hierarchy and
restraint, not decoration: one claim at the top, one accent, generous margins, and diagrams
that carry information the prose would otherwise have to repeat.

## Tokens

| Token | Dark | Light | Used for |
|---|---|---|---|
| `bg` | `#0D0C0B` | `#FBF8F2` | page/asset background |
| `panel` | `#171513` | `#FFFFFF` | diagram nodes |
| `panel2` | `#1D1A17` | `#F7F2E8` | the node that carries the answer |
| `rule` | `#2E2924` | `#E0D6C4` | hairlines, arrows, grid |
| `text` | `#F4EFE6` | `#17150F` | wordmark, node titles |
| `muted` | `#A79E8F` | `#6B6459` | tagline, secondary labels |
| `faint` | `#6E675D` | `#9A9184` | footnotes, captions |
| `accent` | `#E39B3E` | `#A35C05` | the one emphasis: tallow rendered amber |
| `ok` / `warn` | `#6FAF8A` / `#D2705C` | `#2F7A53` / `#A8402C` | accepted rows / quarantine |

Amber is the only saturated colour in the layout. If a second element needs emphasis, it gets
weight or space — not another hue.

## Type

- **Wordmark and headlines** — Lato Black, converted to outlines.
- **Labels and code in diagrams** — DejaVu Sans Mono, also converted to outlines.
- **Prose** — GitHub's own stack. The README sets no fonts: a documentation page that fights the
  reader's theme is worse than a plain one.

Outlines are the point: a viewer without Lato installed still sees the exact composition. Do not
replace an outlined label with a `<text>` element to make editing easier.

## Composition

- Hero: 1600 × 420, wordmark at ~2× the width of the tagline, footer rule carrying the three
  navigation words. Rendered at 2× the display width so it stays crisp on retina.
- Diagrams: 1500 wide, left-to-right flow, 30–40 px gutters, arrows only where direction is
  ambiguous.
- Every asset ships dark **and** light; the README selects with
  `<picture>` + `prefers-color-scheme`. Never ship a single-theme asset with a coloured
  background — it will be unreadable in the other theme.

## Inventory

| File | What it is |
|---|---|
| `lang-hero-{dark,light}.png` | README hero |
| `lang-planes-{dark,light}.png` | "One program, two planes" diagram |
| `src/*.svg` | the editable sources the PNGs are rendered from |
| `src/brand.py` | tokens, text-to-outline conversion, SVG primitives |
| `src/make_assets.py` | regenerates the SVGs and renders the PNGs |

## Regenerating

```console
$ python3 assets/src/make_assets.py lang
```

`brand.py` reads Lato Black and DejaVu Sans Mono from `/usr/share/fonts`. Rasterising uses
headless Chromium; if it runs under a sandbox that cannot read the checkout (snap Chromium on
this host cannot read `/root`), copy `assets/src/` somewhere it can open and run it there.
