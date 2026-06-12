#!/usr/bin/env python3
"""Load, validate, and merge a project's project.toml metadata.

The file is OPTIONAL: every key has a default, so tooling never breaks on a
project without one. This module is the single source of truth for the schema —
the `scad` CLI shells out to it and site_gen.py imports it.

Usage:
    project_meta.py PROJECT_DIR --json    # merged metadata, defaults applied
    project_meta.py PROJECT_DIR --parts   # one line per part: name<TAB>mode<TAB>define...
    project_meta.py PROJECT_DIR --check   # validate; warnings to stderr

Exit codes:
    0  success (including: file absent, or warnings only)
    1  validation error / unreadable file
    2  bad CLI usage
"""
import argparse
import json
import re
import sys
import tomllib
from pathlib import Path

NAME_RE = re.compile(r"^[a-z0-9-]+$")

# Schema: dict -> table of typed keys, list -> array of tables. A tuple of
# types means "any of". Keys absent from the schema produce warnings (typo
# catcher), wrong types produce errors.
SCHEMA = {
    "project": {
        "title": str,
        "description": str,
        "status": str,
        "printed": bool,
        "tags": (list, str),
    },
    "parts": {
        "name": str,
        "defines": (list, str),
        "render_only": bool,
    },
    "print": {
        "material": str,
        "layer_height_mm": (int, float),
        "infill": (str, int, float),
        "walls": int,
        "supports": bool,
        "orientation": str,
        "notes": str,
    },
    "bom": {
        "name": str,
        "qty": int,
        "spec": str,
        "link": str,
    },
    "links": {
        "label": str,
        "url": str,
    },
}
ARRAY_TABLES = {"parts", "bom", "links"}
STATUSES = ("wip", "released")


def _check_table(table, spec, where, errors, warnings):
    for key, val in table.items():
        if key not in spec:
            warnings.append(f"{where}: unknown key '{key}' (typo?)")
            continue
        want = spec[key]
        if isinstance(want, tuple) and want[0] is list:
            if not isinstance(val, list) or not all(isinstance(v, want[1]) for v in val):
                errors.append(f"{where}.{key}: expected a list of {want[1].__name__}")
        elif not isinstance(val, want if isinstance(want, tuple) else (want,)):
            errors.append(f"{where}.{key}: wrong type {type(val).__name__}")
        elif isinstance(val, bool) and want is int:  # bool is an int subclass
            errors.append(f"{where}.{key}: wrong type bool")


def validate(raw):
    """Return (errors, warnings) lists for a parsed project.toml dict."""
    errors, warnings = [], []
    for key, val in raw.items():
        if key not in SCHEMA:
            warnings.append(f"unknown table '{key}' (typo?)")
        elif key in ARRAY_TABLES:
            if not isinstance(val, list):
                errors.append(f"'{key}' must be an array of tables ([[{key}]])")
                continue
            for i, entry in enumerate(val):
                _check_table(entry, SCHEMA[key], f"{key}[{i}]", errors, warnings)
        else:
            if not isinstance(val, dict):
                errors.append(f"'{key}' must be a table ([{key}])")
                continue
            _check_table(val, SCHEMA[key], key, errors, warnings)

    status = raw.get("project", {}).get("status")
    if status is not None and status not in STATUSES:
        errors.append(f"project.status must be one of {STATUSES}, got '{status}'")
    for i, part in enumerate(raw.get("parts", []) if isinstance(raw.get("parts"), list) else []):
        pname = part.get("name")
        if not isinstance(pname, str) or not NAME_RE.match(pname):
            errors.append(f"parts[{i}].name: required, lowercase letters/digits/hyphens only")
    for i, item in enumerate(raw.get("bom", []) if isinstance(raw.get("bom"), list) else []):
        if not isinstance(item.get("name"), str):
            errors.append(f"bom[{i}]: 'name' is required")
    for i, lnk in enumerate(raw.get("links", []) if isinstance(raw.get("links"), list) else []):
        if not isinstance(lnk.get("label"), str) or not isinstance(lnk.get("url"), str):
            errors.append(f"links[{i}]: both 'label' and 'url' are required")
    return errors, warnings


def readme_first_paragraph(projdir):
    """Best-effort one-liner from README.md: first non-heading paragraph,
    markdown links flattened to their text."""
    readme = projdir / "README.md"
    if not readme.is_file():
        return ""
    lines, started = [], False
    for line in readme.read_text(encoding="utf-8", errors="replace").splitlines():
        s = line.strip()
        if not started:
            if not s or s.startswith("#") or s.startswith("!["):
                continue
            started = True
        elif not s:
            break
        lines.append(s)
    text = " ".join(lines)
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", text)  # [text](url) -> text
    return re.sub(r"[*_`]", "", text).strip()


def load(projdir):
    """Parsed + merged metadata for one project dir, defaults applied.
    Raises on unparseable TOML; call validate() separately for schema issues."""
    projdir = Path(projdir)
    name = projdir.name
    toml_path = projdir / "project.toml"
    raw = tomllib.loads(toml_path.read_text(encoding="utf-8")) if toml_path.is_file() else {}
    proj = raw.get("project", {}) if isinstance(raw.get("project", {}), dict) else {}
    parts = raw.get("parts", []) if isinstance(raw.get("parts", []), list) else []
    return {
        "name": name,
        "has_toml": toml_path.is_file(),
        "title": proj.get("title") or name,
        "description": proj.get("description") or readme_first_paragraph(projdir),
        "status": proj.get("status", "wip"),
        "printed": bool(proj.get("printed", False)),
        "tags": proj.get("tags", []),
        "parts": [
            {"name": p["name"], "defines": p.get("defines", ['part="%s"' % p["name"]]),
             "render_only": bool(p.get("render_only", False))}
            for p in parts
            if isinstance(p, dict) and isinstance(p.get("name"), str)
        ],
        "print": raw.get("print", {}),
        "bom": raw.get("bom", []),
        "links": raw.get("links", []),
        "_raw": raw,
    }


def main(argv=None):
    p = argparse.ArgumentParser(description="Load/validate projects/<name>/project.toml.")
    p.add_argument("projdir", help="path to the project directory")
    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument("--json", action="store_true", help="emit merged metadata as JSON")
    g.add_argument("--parts", action="store_true", help="emit 'name<TAB>mode<TAB>define...' per part")
    g.add_argument("--check", action="store_true", help="validate the file")
    args = p.parse_args(argv)

    projdir = Path(args.projdir)
    if not projdir.is_dir():
        print(f"error: not a directory: {projdir}", file=sys.stderr)
        return 1
    try:
        meta = load(projdir)
    except (tomllib.TOMLDecodeError, OSError) as e:
        print(f"error: {projdir / 'project.toml'}: {e}", file=sys.stderr)
        return 1

    if args.check:
        if not meta["has_toml"]:
            print(f"{meta['name']}: no project.toml (fine — defaults apply)")
            return 0
        errors, warnings = validate(meta["_raw"])
        for w in warnings:
            print(f"warning: {w}", file=sys.stderr)
        for e in errors:
            print(f"error: {e}", file=sys.stderr)
        if errors:
            return 1
        print(f"{meta['name']}: project.toml ok"
              + (f" ({len(warnings)} warning(s))" if warnings else ""))
        return 0

    if args.parts:
        for part in meta["parts"]:
            mode = "render" if part["render_only"] else "build"
            print("\t".join([part["name"], mode, *part["defines"]]))
        return 0

    meta.pop("_raw")
    json.dump(meta, sys.stdout, indent=2)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
