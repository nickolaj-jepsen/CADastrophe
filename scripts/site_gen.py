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
import re
import shutil
import sys
from pathlib import Path

import markdown
from jinja2 import Environment, FileSystemLoader, select_autoescape

import geometry_report
import project_meta

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
    text = re.sub(r"!\[[^\]]*\]\(preview\.png\)", "", text)  # site has its own gallery
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


def build_project(projdir, out, repo):
    name = projdir.name
    outdir = projdir / "output"
    sitedir = out / name
    meta = project_meta.load(projdir)

    artifacts = []
    art = collect_artifact(name, name, meta["title"], outdir, sitedir, repo)
    if art:
        artifacts.append(art)
    for part in meta["parts"]:
        art = collect_artifact(name, f"{name}-{part['name']}", part["name"],
                               outdir, sitedir, repo)
        if art:
            artifacts.append(art)

    return {
        **{k: meta[k] for k in
           ("name", "title", "description", "status", "tags", "print", "bom", "links")},
        "artifacts": artifacts,
        "params": extract_params(projdir / f"{name}.scad"),
        "readme_html": readme_html(projdir, name, repo),
        "thumb": artifacts[0]["images"][0]["src"] if artifacts and artifacts[0]["images"] else None,
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

    projects = []
    for projdir in sorted(root.glob("projects/*/")):
        name = projdir.name
        if not NAME_RE.match(name) or not (projdir / f"{name}.scad").is_file():
            continue
        sitedir = out / name
        if sitedir.exists():
            shutil.rmtree(sitedir)
        ctx = build_project(projdir, out, args.repo)
        sitedir.mkdir(parents=True, exist_ok=True)
        page = env.get_template("project.html.j2").render(rel="../", project=ctx, **common)
        (sitedir / "index.html").write_text(page, encoding="utf-8")
        projects.append(ctx)
        print(f"  {name}: {len(ctx['artifacts'])} artifact(s), "
              f"{sum(len(a['images']) for a in ctx['artifacts'])} image(s)")

    # Released projects first, then alphabetical.
    projects.sort(key=lambda pr: (pr["status"] != "released", pr["name"]))

    static_dst = out / "static"
    if static_dst.exists():
        shutil.rmtree(static_dst)
    shutil.copytree(here / "site" / "static", static_dst)
    index = env.get_template("index.html.j2").render(rel="./", projects=projects, **common)
    out.joinpath("index.html").write_text(index, encoding="utf-8")
    print(f"site: {len(projects)} project(s) -> {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
