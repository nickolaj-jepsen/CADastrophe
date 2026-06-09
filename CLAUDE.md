# CADastrophe

A monorepo of parametric OpenSCAD projects. Each part lives at
`projects/<name>/<name>.scad` (this exact path is load-bearing — the flake
auto-discovers it and `nix build .#<name>` renders its STL).

## Working here
- **Enter the dev shell first:** `nix develop` (or let direnv load it). It puts the
  `scad` tool, `openscad`, Python+trimesh, ImageMagick, and BOSL2 (on `OPENSCADPATH`)
  on PATH. Don't invoke `openscad` outside the shell — BOSL2 won't resolve.
- **Read the playbook before modelling:** `.claude/skills/openscad/SKILL.md` covers the
  iterate→render→verify loop, the manifold-safety rules, and a BOSL2 cheatsheet.
- **The loop, every change:** `scad render <name>` (look at the PNG) →
  `scad verify <name>` (read the geometry report) → fix → repeat. A part is not done
  until `Watertight/manifold = yes` and the bounding box matches the intended size in mm.

## Tools (provided by the flake; run `scad help`)
- `scad new <name>` — scaffold a project from a BOSL2 starter.
- `scad render <name> [--view V | --all | --section x|y|z | --cutaway]` — headless PNG(s)
  with native axis/scale rulers and a bbox overlay, written to `output/`.
- `scad verify <name>` — build STL and print the geometry report (watertight, bbox, volume, shells).
- `scad build <name|--all>` — export STL + 3MF. `scad preview <name>` — refresh the committed preview.png.

## Conventions
- **Millimetres**, always. Resolution via `$fa=2; $fs=0.5;` (prefer over a large `$fn`).
- `output/` is gitignored and regenerated. Commit only source and `projects/<name>/preview.png`.
- Reproducible builds: `nix build .#<name>` (one STL) · `nix build` (whole gallery). Nix only
  discovers **git-tracked** projects — `git add` a new project before `nix build` will see it
  (the `scad` CLI sees the working tree, so the two can disagree until you commit).
