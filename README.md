# CADastrophe

Various 3d models and experiments in OpenSCAD.

**Browse the gallery:** <https://nickolaj-jepsen.github.io/CADastrophe/> — every
project with interactive 3D preview, multi-view renders, print settings, BOM,
and download links.

**Download printables:** STL + 3MF for every project are attached to the
[`latest` release](https://github.com/nickolaj-jepsen/CADastrophe/releases/tag/latest),
rebuilt automatically on every push to `main`. Stable URLs:
`https://github.com/nickolaj-jepsen/CADastrophe/releases/download/latest/<file>`.

## Quick start

```sh
nix develop          # or: direnv allow   (auto-loads the shell)
scad list            # see projects
scad new my-part     # scaffold projects/my-part/ (.scad + README + project.toml)
scad render my-part  # headless PNG with axis rulers + bbox overlay -> output/
scad verify my-part  # geometry report: watertight, bbox, volume, shells
scad site --serve    # build the gallery site locally and preview on :8000
```

Reproducible exports straight from source:

```sh
nix build .#ebrake-bracket   # -> result/ebrake-bracket.stl + .3mf
nix build               # the whole gallery (all STL + 3MF)
nix flake check         # geometry gate: every part must be watertight
```

## Project metadata

Each project may carry a `projects/<name>/project.toml` (all keys optional):
title, description, status (`wip`/`released`), tags, print settings, a bill of
materials, related links, and — for multi-part projects — `[[parts]]` entries
that add per-part `<name>-<part>.stl/.3mf` artifacts. The gallery site, the
release pipeline, and the Nix derivations all consume it. `scad validate
<name|--all>` checks it against the schema.

## Automation

- **CI** (`.github/workflows/ci.yml`): PRs run `nix flake check` (every STL
  must build and be watertight) and `scad validate --all`.
- **Publish** (`.github/workflows/publish.yml`): pushes to `main` rebuild all
  artifacts, replace the rolling `latest` release, and deploy the gallery site
  to GitHub Pages.

## Projects

- **[ebrake-bracket](projects/ebrake-bracket/)** — handbrake mount for a GT Omega
  PRIME Lite 8040 side rail.

The [gallery site](https://nickolaj-jepsen.github.io/CADastrophe/) is the
canonical, always-current list.

## Agentic development

This repo ships a Claude skill at [`.claude/skills/openscad/`](.claude/skills/openscad/SKILL.md)
and the `scad` tool, which together give an agent a full feedback loop for authoring
correct parametric geometry without a GUI. See [CLAUDE.md](CLAUDE.md).
