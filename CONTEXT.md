# Context

A handoff brief for future sessions — human or Claude. `README.md` says what
this repo *is*; this file says how it got here, why it is built the way it is,
and which mistakes have already been paid for.

---

## 1. What this is for

Field Notes is JFA's playground for rendering and animation technique. It is a
place to learn a technique in public, keep it runnable, and pull it into client
work later — not a portfolio site and not a product.

Three working rules follow from that:

- **Every tool is one self-contained HTML file.** No build, no `package.json`,
  no dependencies. View-source is the documentation. A toolchain would rot; a
  single file will still open in five years.
- **Every tool is an instrument, not a demo.** If it does one thing on a loop,
  it is not finished. Controls, presets, and an export path are the bar.
- **It has to survive contact with real data.** The point is dataviz, not
  screensavers. Anything that only makes pretty noise is a step on the way to
  something, not the thing.

That third rule came from the sharpest piece of feedback in the project's
history — an early build was called "basically a rave visualz generator … I
can't imagine how I can use this for visualizing data." Stipple exists as the
direct answer: it takes a typed word, an uploaded SVG, or a pasted CSV and
re-renders *your* geometry.

---

## 2. Where everything lives

| | |
|---|---|
| Local working copy | `~/Desktop/JF AGENCY/111 Projects/JFA website/field-notes` |
| Repo | `github.com/JasonForrestpersonal/field-notes` |
| Live site | `jasonforrestpersonal.github.io/field-notes/` |
| Hosting | GitHub Pages, served from the root of `main` |

The local copy sits beside `JFA-repo` inside the JFA website folder. It is a
real clone with full history, not a copy of the files.

Hosting moved here from Netlify deliberately. The drag-a-zip-into-Netlify loop
had no history, no diffing, and no way for anyone else on the team to pick the
work up.

---

## 3. The working loop with Claude

Claude reaches the folder directly through the desktop bridge. **There is no
zip step, and there should never be one again.** The loop is:

1. Say what you want built or changed.
2. Claude edits the folder in place and commits.
3. You run one command:

```bash
cd ~/Desktop/"JF AGENCY"/"111 Projects"/"JFA website"/field-notes && git push
```

### Constraints of that bridge — worth knowing before you fight them

- **Claude cannot delete files on the machine.** Not a permissions bug, a hard
  rule. Anything that needs removing gets moved into a `_to_delete/` folder for
  you to trash. `_to_delete/` is gitignored.
- **Therefore `unzip -o` fails**, because it deletes before it writes. Files get
  overwritten by truncate-and-write instead (Python `open(p,'wb')`), which is
  permitted.
- **Therefore git leaves stale `.git/index.lock` and `.git/objects/*.lock`
  files** after Claude runs `git add`/`commit`. They get moved aside in the same
  pass. If a future session sees "unable to unlink … Operation not permitted",
  that is this, and it is expected — the commit still lands.
- **Claude cannot push.** GitHub credentials live in the macOS keychain, which
  the sandbox cannot reach. `git push` fails with `could not read Username for
  'https://github.com'`. That is why the push is yours.
- Claude's own cloud container and the machine are **separate filesystems**. A
  file written in one is invisible to the other.

---

## 4. The tools

Ordered as on the index — newest first.

### Scroll Shader Lab — scroll position as the timeline
A sticky full-viewport WebGL stage under a tall scroll track (`tracklen` ×
100vh). Scroll progress 0→1 is the only clock; each effect owns a **ramp**
(start, end, curve) on that track and an **amount** derived from it. Source is
an image, a video, the webcam, or a procedural sample, cover-fit into the
working buffer; the chain ping-pongs between two FBOs, one pass per effect.

Six effects: Planes (shatter into offset slabs), Radial mirror, Halftone,
Broken LCD, VHS glitch, Flow distort. The last four are re-implementations of
VIDVOX ISF shaders (flow after Andrew Benson / v002) — same attribution rule as
Stipple. Flow keeps a persistent mask + delay buffer; on stills it is fed by
scroll velocity (`uVel`), on video by real frame differences.

The relationships Jason asked for live in three places:

- **Drive** — every effect's amount is scaled per pixel by a feature of the
  input (light, dark, saturation, distance to a chosen colour, edges); negative
  strength inverts it. `localAmt()` in the shared GLSL preamble.
- **Follow** — an effect can multiply its amount by the previous effect's
  (or by `1 − previous`), which chains dependencies through the stack.
- **Scroll motion** — each parameter has a small `mods[k]` in −1..1 that adds
  `mod × t × (max − min)` as the ramp progresses.

Ramp curve `in` **holds at 1 after its end** rather than dropping to 0 — that
is what lets a chain accumulate down the page.

Presets are absolute: `apply()` rebuilds the chain from `defaultEffect()` and
merges the preset over it. Exports: PNG frame, clipboard frame, JSON preset.
Debug handle: `window.__SCROLLSHADER = {state, apply, serialize, randomize, render, setSource, sample, prog}`.

### Wake — pointer-driven particle field
Synthesised from seven references (two ykob sketch-threejs sketches, a CodePen
by Lea Rosema, four ISF shaders). WebGL2 instanced rendering.

Particle state is a single `Float32Array`, stride 6: `hx, hy, x, y, vx, vy`
(home position, position, velocity). Each step applies, in order: spring toward
home, pointer force (repel / attract / swirl / freeze), pinned attractors, click
shockwaves, noise flow, polar rings.

The detail that makes it read as motion rather than jitter: marks both **orient
and stretch** along velocity.

```js
var len = P.shape===0
  ? clamp(P.size*sc + sp*P.stretch*sc*6, P.size*sc, P.maxLen*sc)
  : P.size*sc;
idata[oo+3] = Math.atan2(vy, vx);
```

Shockwaves are a Gaussian ring travelling outward with exponential decay:

```js
Math.exp(-Math.pow((bd-front)/(P.burstWidth*sc),2)) * Math.exp(-bursts[c].t*P.burstDecay)
```

Interactions: move to push, click for a shockwave, shift-click to pin an
attractor, alt-click to unpin.
Debug handle: `window.__WAKE = {P, pins, bursts, seed, step, render, ptr, burst, count}`

### Stipple — source → sample → marks → material
The instrument that answers "can I use this on real work". Input is a typed
word, an uploaded SVG, or a pasted CSV. Output is marks, and a **vector export
grouped one `<g>` per ink** so it lands in Illustrator ready to separate.

```js
window.__STIPPLE = {P, LFO, buildConfig, loadConfig, buildSVG, marks, src};
```

`buildConfig(true)` embeds the SVG and CSV alongside the parameters, so a saved
config restores the whole state, not just the sliders.

### Field Lab — the Cav Empt technique as a playground
Six primitives, eight materials, four LFOs, nineteen presets. The LFO system
keeps `M` as a modulated copy of the base parameter set `P`, with depth
normalised to each target's slider range — so a modulation depth means the same
thing regardless of the parameter's units.

### Circle Field — the teardown
What the cavempt.com background actually is, with the four render passes shown
side by side. See §6 for the technique itself.

### Terminator Ellipse — sphere-shaded beeswarm
Beeswarm dots lit by one adjustable sun. Exact per-pixel canvas rendering shown
against a four-gradient SVG approximation, so you can see what the cheap version
costs you. Lambert diffuse plus Blinn-Phong specular; the terminator of a lit
sphere is an ellipse with semi-minor axis `sin(elevation)`.

### Animating SVG on Scroll — the review
Fourteen frameworks assessed for scroll-driven SVG, with four live demos, a
node-count stress test, a comparison matrix, and a risk register.

---

## 5. Things that are true about the code

- **Relative links everywhere.** The site has to work at a repo subpath, at a
  domain root, and from `file://`. An absolute `/stipple/` 404s on Pages — this
  has already broken the live site once.
- **`.nojekyll` is required** so Pages copies files through untouched.
- **The home chip is a shared block** pasted at the end of each tool's `<body>`.
  It removes itself when the path does not match, which is what lets each page
  stay usable as a standalone file:

```js
if(!/\/(stipple|field-lab|circle-field|terminator|scroll-animation|wake|scroll-shader)\/?(index\.html)?$/
   .test(location.pathname)) a.remove();
```

  **Add your folder name to that regex when you add a tool.**
- **Presets must be absolute, never differential.** Snapshot `BASE =
  Object.assign({}, P)` at load and apply it before every preset. This bug
  shipped twice — in Field Lab and again in Stipple — and it is invisible until
  someone clicks two presets in a row and gets a state that belongs to neither.
- **Colour is a dataviz decision, not a mood.** The palettes are validated:
  `SEQ_BLUE`, `SEQ_ORANGE`, `DIV_BR` (blue↔red with a grey midpoint), and
  `CAT3` — where only the first three slots survive an all-pairs colour-vision
  check. Do not extend `CAT3` without re-running that check.

---

## 6. The technique notes worth keeping

Each of these cost real debugging time. They are the actual content of the repo.

**The gooey filter needs a gain term.** Blur → alpha gain → hard threshold. Skip
the gain and everything renders black, because blurring a 9px stroke divides its
peak alpha by roughly four and it never reaches the threshold. SVG's
`feColorMatrix` version multiplies alpha by about 18×; in the shader:

```glsl
min(c.a * uGain, 1.0)   // before the smoothstep, not after
```

**Lighting is a sum, not a lerp.** Compositing a lit layer over an ambient layer
with alpha is a linear interpolation, and it renders black. Bake `ambient +
diffuse * lambert` into the stop colours of a single opaque gradient:

```js
var lam = Math.max(0, ce*up + se*z);
dif.appendChild(el("stop", {
  offset: t.toFixed(3),
  "stop-color": shade(hexBase, S.ambient + S.diffuse*lam)
}));
```

**Halftone dots must be capped at ~0.54× the cell pitch**, or the tone collapses
to solid black. This also shipped twice. And sample the field with a **box
average** over the cell, not a point sample at its centre.

**Do not screen a field that is already dotty at the screen pitch.** Wake's
halftones aliased until the marks were made to overlap first (spacing 5.5, size
4.6). Screening needs continuous tone underneath it.

**Beeswarm packing uses merged forbidden y-intervals**, not quantised candidate
offsets. Quantising produces a visible crystalline lattice.

**Emission must be wall-clock driven, not frame driven.** One ring per frame ties
the animation's speed to the refresh rate. Use a catch-up loop, capped (8 per
frame) so a backgrounded tab does not explode on return.

**A continuous colour ramp gives every mark a unique hex**, which produced a
157-group SVG export. Snap to *n* separations before writing the file.

---

## 7. The Cav Empt stack, as observed

From reading the live page: Nuxt on Vercel (iad1), headless Shopify
(`1de53a-4.myshopify.com`), three.js, Sentry nuxt 10.63.0, GA4 plus proxied
analytics, CloudFront.

---

## 8. Attribution — keep this attached

Two pages analyse the background of [cavempt.com](https://www.cavempt.com),
which belongs to Sk8thing and Toby Feltwell. The teardown is a technical read of
a public page; every implementation here was written from scratch against that
description. No code was copied.

The two ISF materials in Stipple are re-implementations, credited in the
interface to David Lublin (after Staffan Widegarn Åhlvik) and VIDVOX (after
Andrew Benson and v002).

Carry this attribution into any client work that borrows from these pages.

---

## 9. Verification

Tools are checked in headless Chromium with software WebGL:

```bash
/opt/pw-browsers/chromium-*/chrome-linux/chrome \
  --use-gl=angle --use-angle=swiftshader --enable-unsafe-swiftshader
```

Effects are proven with **pixel-diff measurement**, not by eye — a control that
changes nothing is the most common failure mode in a tool like this, and it
looks fine in a screenshot. Recorded baselines: VHS 54% frame-to-frame change,
flow 4.5%, pointer push 25%, burst propagation 43%.

Two bugs found this way that would otherwise have shipped: the chroma finish did
nothing (offset defaulted to 0, fixed with a floor of `max(uChroma, 0.12)`), and
`turns` produced radial spokes instead of spirals (the angle was advancing per
segment; it should be `ring.phase + f*TAU*ring.turns`).

---

## 10. Open threads

- The tools export stills and SVG. Nothing exports **motion** yet — no video, no
  Lottie, no frame sequence. That is the obvious gap for client work.
- Stipple reads CSV, but the other tools have no data input at all. Wake's
  particle homes are the natural place to bind a dataset.
- No shared module between the tools. That is intentional today (single-file
  rule), but the gooey filter, the palettes, and the LFO matrix are now written
  three times each. If a fourth tool needs them, reconsider.
- Nothing here has been used in a client deliverable yet. Until it is, treat the
  dataviz claim as unproven.
