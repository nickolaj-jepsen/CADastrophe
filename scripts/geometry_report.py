#!/usr/bin/env python3
"""Geometry report for an STL (or any trimesh-loadable mesh) file.

Reports bounding-box extents (mm), watertight/manifold status, volume (mm^3),
surface area (mm^2), triangle count, and number of disconnected bodies/shells.

Usage:
    geometry_report.py MESH.stl            # human-readable report
    geometry_report.py MESH.stl --json     # machine-readable JSON
    geometry_report.py MESH.stl --bbox      # one line: "X:40.0  Y:30.0  Z:20.0"
    geometry_report.py MESH.stl --center    # one line: "cx cy cz" (bbox centre)
    geometry_report.py MESH.stl --check     # human report; exit 1 unless
                                            # watertight AND winding-consistent

Exit codes:
    0  success
    1  file could not be loaded / no usable geometry / --check failed
    2  bad CLI usage
"""
import argparse
import json
import sys

import trimesh


def load_single_mesh(path):
    """Load `path` and always return a single Trimesh.

    STL normally loads as a Trimesh, but trimesh may return a Scene (multiple
    geometries). force="mesh" concatenates a Scene into one Trimesh; we keep an
    explicit fallback for safety. Raises ValueError if nothing usable loads.
    """
    obj = trimesh.load(path, force="mesh")
    if isinstance(obj, trimesh.Scene):
        geoms = [g for g in obj.geometry.values() if isinstance(g, trimesh.Trimesh)]
        if not geoms:
            raise ValueError("scene contained no triangle meshes")
        obj = trimesh.util.concatenate(geoms)
    if not isinstance(obj, trimesh.Trimesh):
        raise ValueError(f"loaded object is not a mesh: {type(obj).__name__}")
    if len(obj.faces) == 0:
        raise ValueError("mesh has no faces")
    return obj


def body_count(mesh):
    """Number of disconnected bodies/shells.

    mesh.split() / mesh.body_count need a graph engine (scipy or networkx). If
    neither is installed, return None rather than crashing.
    """
    try:
        return len(mesh.split(only_watertight=False))
    except Exception:
        try:
            return int(mesh.body_count)
        except Exception:
            return None


def build_report(mesh):
    ext = mesh.extents            # axis-aligned bbox edge lengths [X, Y, Z]
    lo, hi = mesh.bounds          # [[minx,miny,minz], [maxx,maxy,maxz]]
    centre = (lo + hi) / 2.0
    return {
        "bbox_mm": {"x": float(ext[0]), "y": float(ext[1]), "z": float(ext[2])},
        "bbox_min": {"x": float(lo[0]), "y": float(lo[1]), "z": float(lo[2])},
        "bbox_max": {"x": float(hi[0]), "y": float(hi[1]), "z": float(hi[2])},
        "bbox_center": {"x": float(centre[0]), "y": float(centre[1]), "z": float(centre[2])},
        "is_watertight": bool(mesh.is_watertight),
        "is_winding_consistent": bool(mesh.is_winding_consistent),
        "euler_number": int(mesh.euler_number),
        "volume_mm3": float(mesh.volume),
        "area_mm2": float(mesh.area),
        "triangle_count": int(len(mesh.faces)),
        "body_count": body_count(mesh),
    }


def human(path, r):
    b = r["bbox_mm"]
    bc = r["body_count"]
    bc_str = "unavailable (install scipy or networkx)" if bc is None else str(bc)
    watert = "yes" if r["is_watertight"] else "NO  <-- not manifold, fix this"
    lines = [
        f"Geometry report: {path}",
        "-" * 52,
        f"  Bounding box (mm)  : {b['x']:.2f} x {b['y']:.2f} x {b['z']:.2f}",
        f"  Watertight/manifold: {watert}",
        f"  Winding consistent : {r['is_winding_consistent']}",
        f"  Euler number       : {r['euler_number']}",
        f"  Volume (mm^3)      : {r['volume_mm3']:.2f}",
        f"  Surface area (mm^2): {r['area_mm2']:.2f}",
        f"  Triangles          : {r['triangle_count']}",
        f"  Bodies/shells      : {bc_str}",
    ]
    return "\n".join(lines)


def main(argv=None):
    p = argparse.ArgumentParser(description="Report geometry metrics for a mesh file.")
    p.add_argument("path", help="path to STL (or other mesh) file")
    g = p.add_mutually_exclusive_group()
    g.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    g.add_argument("--bbox", action="store_true", help="emit one bbox line for overlays")
    g.add_argument("--center", action="store_true", help="emit bbox centre 'cx cy cz'")
    g.add_argument("--check", action="store_true",
                   help="print the report; exit 1 unless watertight and winding-consistent")
    args = p.parse_args(argv)

    try:
        mesh = load_single_mesh(args.path)
    except Exception as e:
        if args.json:
            json.dump({"ok": False, "error": str(e), "path": args.path}, sys.stdout)
            sys.stdout.write("\n")
        else:
            print(f"error: could not load {args.path!r}: {e}", file=sys.stderr)
        return 1

    report = build_report(mesh)
    if args.json:
        json.dump({"ok": True, "path": args.path, **report}, sys.stdout, indent=2)
        sys.stdout.write("\n")
    elif args.bbox:
        b = report["bbox_mm"]
        print(f"X:{b['x']:.1f}  Y:{b['y']:.1f}  Z:{b['z']:.1f}")
    elif args.center:
        c = report["bbox_center"]
        print(f"{c['x']:.4f} {c['y']:.4f} {c['z']:.4f}")
    else:
        print(human(args.path, report))
        if args.check and not (report["is_watertight"] and report["is_winding_consistent"]):
            print(f"check FAILED: {args.path} is not a printable manifold", file=sys.stderr)
            return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
