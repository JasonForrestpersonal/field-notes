# Field Notes

Rendering and animation experiments from Jason Forrest Agency.

Five self-contained pages. **No build step, no dependencies, no package.json.**
Every tool is a single HTML file — open the source and the whole technique is
there. That is deliberate: it keeps them readable, forkable, and alive for years
without a toolchain rotting underneath them.

| | | |
|---|---|---|
| [`wake/`](wake/) | **Wake** | A particle field driven by the pointer — move to push, click for a shockwave, shift-click to pin an attractor. Halftone, RGB and freeze screens. |
| [`stipple/`](stipple/) | **Stipple** | Re-renders your own geometry — a typed word, an uploaded SVG, or a pasted CSV — as a field of marks. Vector export grouped one layer per ink. |
| [`field-lab/`](field-lab/) | **Field Lab** | Playground for the Cav Empt circle-field technique. Six primitives, eight materials, four oscillators, nineteen presets. |
| [`circle-field/`](circle-field/) | **Circle Field** | Teardown of what that background actually is, with the four render passes shown side by side. |
| [`terminator/`](terminator/) | **Terminator Ellipse** | Beeswarm dots shaded as spheres by one adjustable sun. Exact per-pixel canvas against a four-gradient SVG approximation. |
| [`scroll-animation/`](scroll-animation/) | **Animating SVG on Scroll** | Review of fourteen animation frameworks for scroll-driven SVG, with live demos. |

## Running it

Nothing to install. Either:

```bash
python3 -m http.server 8000     # then open http://localhost:8000
```

…or just open `index.html` in a browser. A local server is only needed because
one tool reads an uploaded SVG back off a canvas, which some browsers restrict
on `file://`.

## Deploying

GitHub Pages serves this repo as-is from the root of `main`. `.nojekyll` is
present so Pages skips Jekyll processing and copies the files straight through.

All internal links are **relative**, so the site works at a repo subpath
(`user.github.io/field-notes/`), at a domain root, and from the local
filesystem, without changes.

## Adding a tool

1. Make a folder with an `index.html`.
2. Add a card to the table in `index.html` (copy an existing `<a class="card">`).
3. Paste the shared home-link block from any existing tool at the end of the
   `<body>`, and add your folder name to the regex inside it. The link hides
   itself anywhere that regex does not match, which is how these pages stay
   usable as standalone files.

## A note on the Cav Empt work

Two of these pages analyse the background of [cavempt.com](https://www.cavempt.com).
That site belongs to Sk8thing and Toby Feltwell. The teardown is a technical
read of a public page; the implementations here were written from scratch
against that description, and no code was copied from it. The two ISF materials
inside Stipple are re-implementations credited in the interface to their
authors — David Lublin (after Staffan Widegarn Åhlvik) and VIDVOX (after Andrew
Benson and v002).

Keep that attribution attached if any of this moves into client work.
