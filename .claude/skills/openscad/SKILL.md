---
name: openscad
description: Author parametric, 3D-printable OpenSCAD parts with BOSL2 in this repo using the scad render/verify feedback loop. Use when creating, editing, or debugging models under projects/.
---

# OpenSCAD + BOSL2 Parametric Modeling

You author 3D-printable parts as code and converge on correct geometry **without a GUI**.
Your only feedback channels are rendered PNG views and a numeric geometry report. Trust
those, not your mental model.

All tooling is in the dev shell (`nix develop`, or direnv). `include <BOSL2/std.scad>`
resolves automatically (BOSL2 is on `OPENSCADPATH`). Run `scad help` for the full CLI.

## The iterate loop (do this every single change)

```
edit .scad  →  scad render <project>  →  scad verify <project>  →  fix  →  repeat
```

1. **`scad render <project>`** — writes an auto-framed isometric PNG (with native axis +
   scale rulers and a bbox overlay) to `output/`. *Read the image.* Is the shape right? Are
   features present, holes through, walls solid? Need more angles or to see inside?
   - `scad render <p> --all` → a 2×2 montage (iso / front / top / right).
   - `scad render <p> --view front|top|right|left|back|bottom` → one named view.
   - `scad render <p> --section x|y|z` → a flat cross-section through the centre (read internal
     wall thickness). `scad render <p> --cutaway` → a corner removed to expose the interior.
   - **Multi-part projects** (one .scad emitting several print bodies behind a `part`
     customizer variable): render/verify each body in isolation with
     `scad render <p> --tag bracket -D 'part="bracket"'` — `-D` (repeatable) passes
     variable overrides to OpenSCAD, `--tag` suffixes the output files so per-part
     artifacts don't overwrite the canonical ones. Same flags work on `scad verify`
     (per-part watertight/bbox checks; the untagged default should be the full plate).
2. **`scad verify <project>`** — prints a geometry report. **Read every number.** A part is
   not done until:
   - **Watertight/manifold = yes.** `NO` is a build failure — **fix it before anything else.**
     Non-watertight geometry will not slice.
   - **Bounding box matches your intended real-world size in mm.** If you meant 40×30×20 mm and
     it says `40.00 x 30.00 x 20.00`, good. If it says `4 x 3 x 2`, you have a units/scale bug.
     This is the cheapest, highest-value sanity check you have.
   - **Bodies/shells = the number of separate solids you intended** (usually **1**). Extra shells
     = a floating sliver or accidental split.
   - **Euler number** sanity-checks topology: χ = 2 − 2·(number of through-holes/handles). A plain
     solid is 2; each through-hole subtracts 2 (the demo-tray's 4 floor holes give −6). A negative
     value is *normal* for any part with bores or vents — only worth a look if it doesn't match the
     hole count you intended. Watertight + correct shell count are the real gate, not χ = 2.
   - **Volume (mm³)** is a sanity check against gross modeling errors.

Never declare success off a render alone — a part can *look* fine and still be non-manifold.
Never declare success off verify alone — numbers can be right while the shape is wrong.
**You need both.**

Reference report for a clean hollow box:

```
Bounding box (mm)  : 40.00 x 30.00 x 20.00
Watertight/manifold: yes
Euler number       : 2
Volume (mm^3)      : 7004.52
Bodies/shells      : 1
```

## Parametric style

- **Units are millimetres.** Always. A printer thinks in mm; so do you.
- **Named parameters at the top**, derived values via **functions**, reusable geometry via
  **modules**.
- Set resolution once at the top: **`$fa=2; $fs=0.5;`**. The Manifold backend makes fine curves
  cheap, so **prefer `$fs` (segment length, mm) and `$fa` (angle) over a giant `$fn`.** Use a
  local `$fn` only for small threaded/faceted features.
- **Model in print orientation**: largest flat face on the bed (Z up), minimize overhangs, avoid
  features that *need* support.

```openscad
include <BOSL2/std.scad>
$fa = 2; $fs = 0.5;

// --- parameters (mm) ---
width = 40; depth = 30; height = 20; wall = 2; fillet = 3;

// --- derived ---
function inner(d) = d - 2 * wall;   // keep math in named functions

// --- reusable geometry ---
module shell() {
    diff()
        cuboid([width, depth, height], rounding = fillet, edges = "Z")
            position(TOP) up(0.01) tag("remove")
                cuboid([inner(width), inner(depth), height - wall], anchor = TOP);
}
shell();
```

## Manifold safety (the #1 source of bad geometry)

A model that *looks* fine but reports `Watertight = NO` almost always has one of these.
Internalize the rules:

- **Overlap solids you union** by a small epsilon (0.01–0.02 mm). Two cubes sharing a *flush*
  face create coincident faces — fragile and a source of degenerate triangles.
- **Over-cut solids you subtract.** When boring a hole or pocket, make the cutter poke *out past*
  the surface by ~0.01–0.02 mm on the open end. A cut face *exactly coincident* with the part
  surface leaves a zero-thickness skin.
- **Touching only at an edge or a point is non-manifold.** Two cubes sharing only one edge export
  to non-watertight geometry. Always give shared regions real volumetric overlap.
- **No zero-thickness walls, no zero-area faces.** If a wall computes to 0 mm (e.g. `inner()` went
  negative), you get garbage. `assert` your wall thicknesses.
- **Prefer clean 2D → `linear_extrude` / `rotate_extrude`** over stacking many 3D booleans. A
  correct 2D profile extruded is manifold by construction.

```openscad
// SUBTRACT: over-cut so the cut face is never coincident with the surface
diff()
    cuboid([40, 30, 20])
        attach(TOP) tag("remove")
            cyl(h = 20 + 0.02, d = 8);   // +0.02 pokes through top & bottom

// UNION: overlap, don't kiss
union() {
    cuboid([20, 20, 10]);
    up(10 - 0.01) cuboid([20, 20, 10]);  // 0.01 overlap, not flush
}
```

> The Manifold engine sometimes *welds* a flush union so it slips past verify — don't rely on it.
> Coincident faces still wreck section views and downstream booleans. Always use the epsilon.

## BOSL2 cheatsheet

Always start with `include <BOSL2/std.scad>`. **Threads/screws are NOT in `std.scad`** — add
`include <BOSL2/screws.scad>` and/or `include <BOSL2/threading.scad>`.

**Primitives with built-in rounding/chamfer** — use these instead of hand-rolled fillets:
```openscad
cuboid([40, 30, 20], rounding = 3, edges = "Z");        // round the 4 vertical edges only
cuboid([30, 30, 30], rounding = 4, edges = [TOP+FRONT, TOP+BACK]);
cyl(h = 20, d = 15, rounding = 2);                       // rounded rim
cyl(h = 20, d = 15, chamfer = 2);                        // chamfered rim
```

**Attachment system — place parts *relative* to each other, not by absolute coordinates.**
Named anchors: `TOP BOTTOM LEFT RIGHT FRONT BACK CENTER` (combinable, e.g. `TOP+RIGHT`).
```openscad
// attach(parent_anchor, child_anchor): child's anchor mates to the parent's anchor
cuboid([30, 30, 10]) attach(TOP, BOTTOM) cyl(h = 12, d = 8);

// position() places the child's origin at an anchor; orient() aims it
cuboid([40, 40, 10]) position(RIGHT) orient(RIGHT) cyl(h = 6, d = 20, anchor = BOTTOM);
```

**Clean boolean removal / cutaways — `diff()` + `tag("remove")`:**
```openscad
diff()
    cuboid([40, 30, 20])
        attach(TOP) tag("remove") cyl(h = 10 + 0.02, d = 8);   // bore from the top
```

**Threads / fasteners** (need the extra includes; a small local `$fn` is fine):
```openscad
include <BOSL2/screws.scad>
screw("M4x0.7", length = 12, head = "socket", anchor = BOTTOM);
nut("M4", thickness = 4, anchor = BOTTOM);

include <BOSL2/threading.scad>
threaded_rod(d = 8, l = 30, pitch = 1.25);
```

**Sweeps & movement helpers:**
```openscad
linear_sweep(circle(d = 20), height = 10, scale = 0.5);          // taper a 2D profile upward
path_sweep(circle(d = 4), arc(r = 20, angle = 120, n = 24));     // tube along a path
up(10) fwd(5) zrot(30) cube([5, 5, 5], center = true);           // up/down fwd/back left/right xrot/yrot/zrot
```

> If unsure of an exact BOSL2 signature, confirm against the BelfrySCAD/BOSL2 wiki
> (WebSearch/WebFetch) — **do not invent argument names.** Arg order and named params vary.

## Debugging without a GUI

You can't press F5/F6 or interact with the `% # ! *` modifiers. Lean on:

- **`echo()` to print computed values.** Output appears as `ECHO: ...` on **stderr** during
  render — visible in `scad render`/`verify` output. Confirm derived dimensions before trusting
  the model:
  ```openscad
  wall = 2; inner_w = 40 - 2 * wall;
  echo("inner_w =", inner_w);   // -> ECHO: "inner_w =", 36   (stderr)
  ```
- **`assert(condition, "msg")` for invariants.** A failed assert prints `ERROR: Assertion ...`
  and aborts — turning a silent geometry bug into a loud, located failure:
  ```openscad
  assert(wall >= 1, "wall too thin for FDM");
  assert(inner_w > 0, "negative inner width — check dims");
  ```
- **When a feature is internal** (pocket, boss, rib), you can't see it on the isometric. Request
  `scad render <p> --section x|y|z` or `--cutaway` to slice the part open and confirm internal
  geometry and wall thickness.

## Common gotchas

- **Every render is a full Manifold render** (never a throwaway preview) — don't reason about
  preview-only artifacts.
- **BOSL2 primitives default to centered** (`anchor=CENTER`), so the bbox straddles the origin;
  plain OpenSCAD `cube()` is first-octant unless `center=true`. The bbox *size* is what matters
  for correctness.
- **Read the report numbers as assertions.** `Watertight = NO` → fix before iterating on shape.
  `Bodies/shells > 1` unexpectedly → a sliver split off (often too small an overlap). bbox off by
  10× → units bug. `Euler number ≠ 2` is **expected** for any part with holes (χ = 2 − 2·holes;
  demo-tray = −6 for its 4 holes) — only a flag if it disagrees with your intended hole count.
- **Reach for a section view** the moment a feature is hidden inside the part — don't guess from
  the silhouette.

## Each project's README

Keep it short:
- **One-line description** of the part and its purpose.
- **Key parameters** (the named top-of-file vars: dimensions, wall, clearances, fastener sizes).
- **Print notes**: recommended orientation (which face on the bed), layer height, and whether
  supports are needed (and where).

When the part is final, refresh the gallery image with `scad preview <project>` (writes the
committed `projects/<project>/preview.png`).
