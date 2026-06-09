# CADastrophe

Various 3d models and experiments in OpenSCAD.

## Quick start

```sh
nix develop          # or: direnv allow   (auto-loads the shell)
scad list            # see projects
scad new my-part     # scaffold projects/my-part/
scad render my-part  # headless PNG with axis rulers + bbox overlay -> output/
scad verify my-part  # geometry report: watertight, bbox, volume, shells
```

Reproducible exports straight from source:

```sh
nix build .#demo-tray   # -> result/demo-tray.stl
nix build               # the whole gallery
```

## Projects

- **[demo-tray](projects/demo-tray/)** — a parametric rounded tray with mounting holes
  (the starter example).

## Agentic development

This repo ships a Claude skill at [`.claude/skills/openscad/`](.claude/skills/openscad/SKILL.md)
and the `scad` tool, which together give an agent a full feedback loop for authoring
correct parametric geometry without a GUI. See [CLAUDE.md](CLAUDE.md).
