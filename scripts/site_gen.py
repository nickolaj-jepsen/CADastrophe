#!/usr/bin/env python3
"""Static gallery site generator for CADastrophe.

Pure transform — no rendering happens here. `scad site` first builds, for each
project, the STL/3MF artifacts and the four view PNGs into
projects/<name>/output/; this script then assembles a self-contained static
site (HTML + copied images + STL copies for the in-browser viewer) in --out.

RULE: every URL in the generated HTML must be RELATIVE (./, ../). GitHub Pages
serves the site from a sub-path (/CADastrophe/), and absolute paths break both
there and under local `python3 -m http.server` preview.

Usage:
    site_gen.py --root REPO_ROOT --out OUT_DIR [--repo owner/name]

With --repo, download buttons point at the rolling GitHub release
(releases/download/latest/<file>) and README links to sibling .md files are
rewritten to GitHub blob URLs. Without it (e.g. offline), downloads fall back
to the STL/3MF copies bundled into the site.
"""
import argparse
import os
import re
import shutil
import sys
from pathlib import Path

import markdown
from jinja2 import Environment, FileSystemLoader, select_autoescape

import geometry_report
import project_meta

def make_writable(path):
    """Restore write bits across a tree (static/ is copied from the read-only Nix store)."""
    for parent, dirs, files in os.walk(path):
        os.chmod(parent, 0o755)
        for f in files:
            os.chmod(os.path.join(parent, f), 0o644)


def force_rmtree(path):
    """rmtree that survives read-only trees left by an earlier copy from the Nix store."""
    make_writable(path)
    shutil.rmtree(path)


SITE_TITLE = "CADastrophe"
VIEWS = ("iso", "front", "top", "right")
NAME_RE = re.compile(r"^[a-z0-9-]+$")

# `name = value;  // comment` at top level (OpenSCAD customizer style).
PARAM_RE = re.compile(r"^([A-Za-z_]\w*)\s*=\s*([^;]+);\s*(?://\s*(.*))?$")
# Group headers: customizer `/* [Group] */` or this repo's `// --- group ---`.
GROUP_RE = re.compile(r"^/\*\s*\[(.+?)\]\s*\*/$|^//\s*-+\s*(.+?)\s*-+$")
STOP_RE = re.compile(r"^(module|function)\s")


def extract_params(scad_path):
    """Best-effort parameter table from the .scad header. Stops at the first
    module/function (everything after is derived geometry, not a user knob)."""
    params, group = [], None
    for line in scad_path.read_text(encoding="utf-8", errors="replace").splitlines():
        s = line.strip()
        if STOP_RE.match(s):
            break
        m = GROUP_RE.match(s)
        if m:
            group = (m.group(1) or m.group(2)).strip()
            continue
        m = PARAM_RE.match(s)
        if m and not m.group(1).startswith("$"):
            params.append({
                "group": group,
                "name": m.group(1),
                "value": m.group(2).strip(),
                "comment": (m.group(3) or "").strip(),
            })
    return params


def readme_html(projdir, name, repo):
    readme = projdir / "README.md"
    if not readme.is_file():
        return ""
    text = readme.read_text(encoding="utf-8", errors="replace")
    lines = text.splitlines()
    if lines and lines[0].startswith("# "):  # page already has a title
        lines = lines[1:]
    text = "\n".join(lines)
    html = markdown.markdown(text, extensions=["tables", "fenced_code"])
    if repo:
        # Relative links to sibling docs (SPEC.md, ...) only resolve on GitHub.
        html = re.sub(
            r'href="([A-Za-z0-9._-]+\.md)"',
            rf'href="https://github.com/{repo}/blob/main/projects/{name}/\1"',
            html,
        )
    return html


def mesh_stats(stl_path):
    try:
        mesh = geometry_report.load_single_mesh(str(stl_path))
    except Exception as e:
        print(f"warning: no stats for {stl_path}: {e}", file=sys.stderr)
        return None
    r = geometry_report.build_report(mesh)
    b = r["bbox_mm"]
    return {
        "bbox": f"{b['x']:.1f} × {b['y']:.1f} × {b['z']:.1f} mm",
        "volume": f"{r['volume_mm3'] / 1000.0:.1f} cm³",
        "triangles": f"{r['triangle_count']:,}",
        "watertight": r["is_watertight"] and r["is_winding_consistent"],
    }


def collect_artifact(name, base, label, outdir, sitedir, repo):
    """One downloadable body (the default plate or a [[parts]] entry): copy its
    viewer STL + gallery PNGs into the site, return the template context."""
    stl = outdir / f"{base}.stl"
    if not stl.is_file():
        print(f"warning: {stl} missing — run `scad site` without --skip-render",
              file=sys.stderr)
        return None
    (sitedir / "models").mkdir(parents=True, exist_ok=True)
    (sitedir / "img").mkdir(parents=True, exist_ok=True)
    shutil.copy2(stl, sitedir / "models" / stl.name)

    downloads = []
    for ext in ("stl", "3mf"):
        f = outdir / f"{base}.{ext}"
        if not f.is_file():
            continue
        if repo:
            url = f"https://github.com/{repo}/releases/download/latest/{f.name}"
        else:
            shutil.copy2(f, sitedir / "models" / f.name)
            url = f"models/{f.name}"
        downloads.append({"label": ext.upper(), "url": url, "file": f.name})

    images = []
    for view in VIEWS:
        png = outdir / f"{base}_{view}.png"
        if png.is_file():
            shutil.copy2(png, sitedir / "img" / png.name)
            images.append({"view": view, "src": f"img/{png.name}"})

    return {
        "label": label,
        "stl": f"models/{stl.name}",
        "downloads": downloads,
        "images": images,
        "stats": mesh_stats(stl),
    }


def collect_view(name, base, label, outdir, sitedir):
    """A render-only body (an assembled/exploded view): copy its gallery PNGs
    into the site. No STL, no downloads, no geometry stats — imagery only."""
    images = []
    for view in VIEWS:
        png = outdir / f"{base}_{view}.png"
        if png.is_file():
            (sitedir / "img").mkdir(parents=True, exist_ok=True)
            shutil.copy2(png, sitedir / "img" / png.name)
            images.append({"view": view, "src": f"img/{png.name}"})
    if not images:
        print(f"warning: no render for {base} — run `scad site` without --skip-render",
              file=sys.stderr)
        return None
    return {"label": label, "images": images}


def _split_downloads(downloads):
    """Pivot collect_artifact's flat download list into a 3MF-primary / rest-
    secondary split for the one-CTA layout. Keyed on the label collect_artifact
    builds via ext.upper() — change both together if that ext loop grows."""
    primary = next((d for d in downloads if d["label"] == "3MF"), None)
    secondary = [d for d in downloads if d["label"] != "3MF"]
    return {"primary": primary, "secondary": secondary}


def _iso_or_first(images):
    """Hero source: the iso view if present, else the first available view (a
    missing iso must not drop a project that has front/top/right)."""
    if not images:
        return None
    for img in images:
        if img["view"] == "iso":
            return img["src"]
    return images[0]["src"]


def build_project(projdir, out, repo):
    """Assemble one project's template context, or None if it can't be shown
    (no printable STL, or no image to lead with)."""
    name = projdir.name
    outdir = projdir / "output"
    sitedir = out / name
    meta = project_meta.load(projdir)

    secondary_parts, assembly_views = [], []
    for part in meta["parts"]:
        base = f"{name}-{part['name']}"
        if part["render_only"]:
            v = collect_view(name, base, part["name"], outdir, sitedir)
            if v:
                assembly_views.append(v)
        else:
            art = collect_artifact(name, base, part["name"], outdir, sitedir, repo)
            if art:
                art["downloads"] = _split_downloads(art["downloads"])
                secondary_parts.append(art)

    multipart = bool(secondary_parts)
    label = "Complete plate (all parts, one print)" if multipart else "Printable part"
    primary = collect_artifact(name, name, label, outdir, sitedir, repo)
    if primary is None:
        print(f"warning: {name} dropped — no printable STL", file=sys.stderr)
        return None
    primary["downloads"] = _split_downloads(primary["downloads"])

    # Lead with the assembled view (most legible); fall back to the plate's iso.
    hero_src = _iso_or_first(assembly_views[0]["images"]) if assembly_views else None
    if hero_src is None:
        hero_src = _iso_or_first(primary["images"])
    if hero_src is None:
        print(f"warning: {name} dropped — no hero image", file=sys.stderr)
        return None

    pr = meta.get("print", {})
    pstats = primary["stats"]
    facts = {
        "dimensions": pstats["bbox"] if pstats else None,
        "material": pr.get("material"),
        "supports": pr.get("supports"),
        "watertight": "unknown" if pstats is None else ("yes" if pstats["watertight"] else "no"),
        "printed": meta["printed"],
    }

    return {
        **{k: meta[k] for k in
           ("name", "title", "description", "status", "tags", "print", "bom", "links")},
        "printed": meta["printed"],
        "hero": {"src": hero_src, "alt": f"{meta['title']} — isometric view"},
        "facts": facts,
        "primary": primary,
        "secondary_parts": secondary_parts,
        "assembly_views": assembly_views,
        "params": extract_params(projdir / f"{name}.scad"),
        "readme_html": readme_html(projdir, name, repo),
    }


def main(argv=None):
    p = argparse.ArgumentParser(description="Generate the CADastrophe gallery site.")
    p.add_argument("--root", required=True, help="repo root (contains projects/)")
    p.add_argument("--out", required=True, help="output directory (wiped per project)")
    p.add_argument("--repo", help="GitHub owner/name for download + source links")
    args = p.parse_args(argv)

    root, out = Path(args.root), Path(args.out)
    here = Path(__file__).resolve().parent
    env = Environment(
        loader=FileSystemLoader(here / "site" / "templates"),
        autoescape=select_autoescape(["html"]),
        trim_blocks=True,
        lstrip_blocks=True,
    )
    common = {"site_title": SITE_TITLE, "repo": args.repo}

    projects, dropped = [], []
    for projdir in sorted(root.glob("projects/*/")):
        name = projdir.name
        if not NAME_RE.match(name) or not (projdir / f"{name}.scad").is_file():
            continue
        sitedir = out / name
        if sitedir.exists():
            force_rmtree(sitedir)
        ctx = build_project(projdir, out, args.repo)
        if ctx is None:
            dropped.append(name)
            if sitedir.exists():
                force_rmtree(sitedir)  # drop the half-copied assets too
            continue
        sitedir.mkdir(parents=True, exist_ok=True)
        page = env.get_template("project.html.j2").render(rel="../", project=ctx, **common)
        (sitedir / "index.html").write_text(page, encoding="utf-8")
        projects.append(ctx)
        bodies = [ctx["primary"], *ctx["secondary_parts"]]
        nimg = (sum(len(b["images"]) for b in bodies)
                + sum(len(v["images"]) for v in ctx["assembly_views"]))
        print(f"  {name}: {len(bodies)} body(ies), "
              f"{len(ctx['assembly_views'])} assembly view(s), {nimg} image(s)")

    if dropped:
        print(f"warning: {len(dropped)} project(s) dropped (no STL or no render): "
              f"{', '.join(dropped)} — run `scad site` without --skip-render",
              file=sys.stderr)

    # Released projects first, then alphabetical.
    projects.sort(key=lambda pr: (pr["status"] != "released", pr["name"]))

    static_dst = out / "static"
    if static_dst.exists():
        force_rmtree(static_dst)
    shutil.copytree(here / "site" / "static", static_dst)
    make_writable(static_dst)
    index = env.get_template("index.html.j2").render(rel="./", projects=projects, **common)
    out.joinpath("index.html").write_text(index, encoding="utf-8")
    print(f"site: {len(projects)} project(s) -> {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
