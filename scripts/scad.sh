# shellcheck shell=bash
# scad — OpenSCAD project tool for the CADastrophe repo.
#
# This file is the body of a flake `writeShellApplication`. The wrapper provides
# `set -euo pipefail`, a PATH containing openscad/python3/magick/montage/coreutils,
# and exports OPENSCADPATH (BOSL2 lib) and SCAD_LIB (this scripts directory).
# Run `scad help` for usage.

SCAD_LIB="${SCAD_LIB:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
REPORT_PY="$SCAD_LIB/geometry_report.py"
FONT="DejaVu-Sans"
IMGSIZE="${SCAD_IMGSIZE:-900,900}"
COLORSCHEME="${SCAD_COLORSCHEME:-Tomorrow}"

die() { echo "scad: $*" >&2; exit 1; }

# Reject anything outside [a-z0-9-] (also forbids '/' and '.', so a name can
# never traverse out of projects/ or inject into a generated .scad).
validate_name() {
  case "$1" in
    "" | -* | *[!a-z0-9-]*) die "invalid project name '$1' (lowercase letters, digits, hyphens only)" ;;
  esac
}

# One temp dir per invocation, removed on ANY exit (normal, die, or set -e abort).
SCAD_TMP=""
cleanup_tmp() { [ -n "${SCAD_TMP:-}" ] && rm -rf "$SCAD_TMP"; return 0; }
trap cleanup_tmp EXIT
mktmp() { SCAD_TMP="$(mktemp -d)"; printf '%s\n' "$SCAD_TMP"; }

# Camera rotation triple (rx,ry,rz) for a named view; --viewall sets distance.
view_rot() {
  case "$1" in
    iso)    echo "55,0,25" ;;
    front)  echo "90,0,0" ;;
    back)   echo "90,0,180" ;;
    right)  echo "90,0,90" ;;
    left)   echo "90,0,270" ;;
    top)    echo "0,0,0" ;;
    bottom) echo "180,0,0" ;;
    *)      return 1 ;;
  esac
}

# Repo root: nearest ancestor holding both flake.nix and projects/ (else $PWD).
find_root() {
  local d="$PWD"
  while [ "$d" != "/" ]; do
    if [ -e "$d/flake.nix" ] && [ -d "$d/projects" ]; then
      printf '%s\n' "$d"; return 0
    fi
    d="$(dirname "$d")"
  done
  printf '%s\n' "$PWD"
}

ROOT="$(find_root)"

project_scad() {  # name -> path to main .scad (or die)
  validate_name "$1"
  local f="$ROOT/projects/$1/$1.scad"
  [ -f "$f" ] || die "no such project '$1' (expected $f)"
  printf '%s\n' "$f"
}

project_outdir() {  # name -> output dir (created)
  validate_name "$1"
  local d="$ROOT/projects/$1/output"
  mkdir -p "$d"
  printf '%s\n' "$d"
}

# -D name=value overrides collected from the command line (render/verify),
# passed to every openscad invocation as repeated `-D` flags. Lets a
# multi-part project select one body, e.g.:
#   scad render uniflag --tag bracket -D 'part="bracket"'
SCAD_DEFINES=()

# Output-filename tag (validated like project names) so per-variant artifacts
# don't overwrite the canonical ones: output/<name>_<tag>_<view>.png etc.
SCAD_TAG=""

validate_tag() {
  case "$1" in
    "" | -* | *[!a-z0-9-]*) die "invalid --tag '$1' (lowercase letters, digits, hyphens only)" ;;
  esac
}

# Headless binary-STL export (Manifold). Needs no GL/display.
build_stl() {  # scad out
  local defs=() d
  for d in "${SCAD_DEFINES[@]}"; do defs+=(-D "$d"); done
  env -u DISPLAY -u WAYLAND_DISPLAY QT_QPA_PLATFORM=offscreen \
    openscad --backend=Manifold --export-format=binstl "${defs[@]}" -o "$2" "$1"
}

# Headless PNG render of one view. rot = "rx,ry,rz".
render_png() {  # scad out rot [extra openscad args...]
  local scad="$1" out="$2" rot="$3"; shift 3
  local defs=() d
  for d in "${SCAD_DEFINES[@]}"; do defs+=(-D "$d"); done
  env -u DISPLAY -u WAYLAND_DISPLAY QT_QPA_PLATFORM=offscreen \
    openscad --backend=Manifold --render \
      --camera="0,0,0,$rot,0" --viewall --autocenter \
      --projection=ortho --view=axes,scales \
      --colorscheme="$COLORSCHEME" --imgsize="$IMGSIZE" \
      "${defs[@]}" "$@" -o "$out" "$scad"
}

bbox_line() { python3 "$REPORT_PY" "$1" --bbox; }

# Burn the bbox extents into the bottom-left corner (DejaVu-Sans is the only font).
overlay_bbox() {  # png bboxtext
  magick "$1" -font "$FONT" -pointsize 20 -fill white \
    -undercolor '#000000aa' -gravity SouthWest \
    -annotate +10+10 "bbox  $2 mm" "$1"
}

cmd_new() {
  local name="${1:-}"
  [ -n "$name" ] || die "usage: scad new <name>"
  validate_name "$name"
  local dir="$ROOT/projects/$name"
  [ -e "$dir" ] && die "project '$name' already exists at $dir"
  local modname="${name//-/_}"
  mkdir -p "$dir/output"
  {
    cat <<'SCAD_HEAD'
include <BOSL2/std.scad>
$fa = 2; $fs = 0.5;   // curve resolution: Manifold makes fine curves cheap

// --- parameters (mm) ---
size   = 30;
wall   = 2;
fillet = 3;

SCAD_HEAD
    printf 'module %s() {\n' "$modname"
    cat <<'SCAD_BODY'
    // A hollow rounded box — replace with your part.
    // edges="Z" rounds only the vertical edges so the bbox stays at the nominal size.
    diff()
        cuboid([size, size, size], rounding=fillet, edges="Z")
            position(TOP) up(0.01) tag("remove")   // +0.01 avoids a coincident face
                cuboid([size - 2 * wall, size - 2 * wall, size - wall], anchor=TOP);
}

SCAD_BODY
    printf '%s();\n' "$modname"
  } > "$dir/$name.scad"
  {
    printf '# %s\n\n' "$name"
    printf 'One-line description of the part and what it is for.\n\n'
    printf '**Key params:** size=30, wall=2, fillet=3 (mm)\n\n'
    printf '**Print:** orientation / 0.2 mm layers / supports? \n\n'
    printf '![preview](preview.png)\n'
  } > "$dir/README.md"
  echo "Created projects/$name/"
  echo "Next: edit projects/$name/$name.scad, then run: scad render $name && scad verify $name"
}

# Build a temp section/cutaway .scad (OpenSCAD does the float math) and render it.
render_cut() {  # name scad outdir stl bbox section cutaway
  local name="$1" outdir="$3" stl="$4" bbox="$5" section="$6" cutaway="$7"
  local centre; centre="$(python3 "$REPORT_PY" "$stl" --center)"
  local cx cy cz; read -r cx cy cz <<<"$centre"
  local tmp; tmp="$(mktmp)"
  local cutscad="$tmp/cut.scad" out
  if [ "$cutaway" = 1 ]; then
    out="$outdir/${name}_cutaway.png"
    {
      printf 'big = 1000; cx = %s; cy = %s; cz = %s;\n' "$cx" "$cy" "$cz"
      printf 'difference() {\n  import("%s");\n' "$stl"
      printf '  translate([cx, cy, cz]) cube(big);   // remove the +x+y+z corner\n}\n'
    } > "$cutscad"
  else
    out="$outdir/${name}_section_${section}.png"
    local off
    case "$section" in
      x) off="[cx - big, cy - big/2, cz - big/2]" ;;
      y) off="[cx - big/2, cy - big, cz - big/2]" ;;
      z) off="[cx - big/2, cy - big/2, cz - big]" ;;
      *) die "section axis must be x, y, or z" ;;
    esac
    {
      printf 'big = 1000; cx = %s; cy = %s; cz = %s;\n' "$cx" "$cy" "$cz"
      printf 'intersection() {\n  import("%s");\n' "$stl"
      printf '  translate(%s) cube(big);\n}\n' "$off"
    } > "$cutscad"
  fi
  render_png "$cutscad" "$out" "$(view_rot iso)"
  overlay_bbox "$out" "$bbox"
  echo "$out"
}

cmd_render() {
  local name="" view="iso" do_all=0 section="" cutaway=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --all)       do_all=1; shift ;;
      --cutaway)   cutaway=1; shift ;;
      --view)      [ $# -ge 2 ] || die "render: --view needs a value"; view="$2"; shift 2 ;;
      --view=*)    view="${1#*=}"; shift ;;
      --section)   [ $# -ge 2 ] || die "render: --section needs a value"; section="$2"; shift 2 ;;
      --section=*) section="${1#*=}"; shift ;;
      --size)      [ $# -ge 2 ] || die "render: --size needs a value"; IMGSIZE="$2"; shift 2 ;;
      --size=*)    IMGSIZE="${1#*=}"; shift ;;
      -D)          [ $# -ge 2 ] || die "render: -D needs name=value"; SCAD_DEFINES+=("$2"); shift 2 ;;
      -D*)         SCAD_DEFINES+=("${1#-D}"); shift ;;
      --tag)       [ $# -ge 2 ] || die "render: --tag needs a value"; SCAD_TAG="$2"; shift 2 ;;
      --tag=*)     SCAD_TAG="${1#*=}"; shift ;;
      -*)          die "render: unknown option '$1'" ;;
      *)           [ -z "$name" ] || die "render: unexpected extra argument '$1'"; name="$1"; shift ;;
    esac
  done
  [ -n "$name" ] || die "usage: scad render <name> [--view V] [--all] [--section x|y|z] [--cutaway] [--size WxH] [-D name=value]... [--tag t]"
  [ -z "$SCAD_TAG" ] || validate_tag "$SCAD_TAG"

  # Validate everything cheap BEFORE the expensive build.
  IMGSIZE="${IMGSIZE//[xX]/,}"
  [[ "$IMGSIZE" =~ ^[0-9]+,[0-9]+$ ]] || die "render: --size must be WxH, e.g. 900x900"
  local rot=""
  if [ "$cutaway" = 1 ] || [ -n "$section" ]; then
    [ -z "$section" ] || case "$section" in x|y|z) ;; *) die "render: --section axis must be x, y, or z" ;; esac
  else
    rot="$(view_rot "$view")" || die "render: unknown view '$view' (iso|front|top|right|left|back|bottom)"
  fi

  local scad outdir stl bbox base
  scad="$(project_scad "$name")"
  outdir="$(project_outdir "$name")"
  base="${name}${SCAD_TAG:+_$SCAD_TAG}"
  stl="$outdir/$base.stl"
  build_stl "$scad" "$stl"
  bbox="$(bbox_line "$stl")"

  if [ "$cutaway" = 1 ] || [ -n "$section" ]; then
    render_cut "$base" "$scad" "$outdir" "$stl" "$bbox" "$section" "$cutaway"
    return
  fi

  if [ "$do_all" = 1 ]; then
    local tmp; tmp="$(mktmp)"
    local v
    for v in iso front top right; do
      render_png "$scad" "$tmp/$v.png" "$(view_rot "$v")"
    done
    local grid="$outdir/${base}_views.png"
    montage -font "$FONT" -pointsize 16 -background white \
      -tile 2x2 -geometry +6+6 -border 1 -bordercolor '#888888' \
      -label 'ISO' "$tmp/iso.png" -label 'FRONT' "$tmp/front.png" \
      -label 'TOP' "$tmp/top.png" -label 'RIGHT' "$tmp/right.png" \
      "$grid"
    overlay_bbox "$grid" "$bbox"
    echo "$grid"
    return
  fi

  local out="$outdir/${base}_${view}.png"
  render_png "$scad" "$out" "$rot"
  overlay_bbox "$out" "$bbox"
  echo "$out"
}

cmd_verify() {
  local name=""
  while [ $# -gt 0 ]; do
    case "$1" in
      -D)      [ $# -ge 2 ] || die "verify: -D needs name=value"; SCAD_DEFINES+=("$2"); shift 2 ;;
      -D*)     SCAD_DEFINES+=("${1#-D}"); shift ;;
      --tag)   [ $# -ge 2 ] || die "verify: --tag needs a value"; SCAD_TAG="$2"; shift 2 ;;
      --tag=*) SCAD_TAG="${1#*=}"; shift ;;
      -*)      die "verify: unknown option '$1'" ;;
      *)       [ -z "$name" ] || die "verify: unexpected extra argument '$1'"; name="$1"; shift ;;
    esac
  done
  [ -n "$name" ] || die "usage: scad verify <name> [-D name=value]... [--tag t]"
  [ -z "$SCAD_TAG" ] || validate_tag "$SCAD_TAG"
  local scad outdir stl
  scad="$(project_scad "$name")"
  outdir="$(project_outdir "$name")"
  stl="$outdir/${name}${SCAD_TAG:+_$SCAD_TAG}.stl"
  build_stl "$scad" "$stl"
  python3 "$REPORT_PY" "$stl"
}

build_one() {
  local name="$1" scad outdir
  scad="$(project_scad "$name")" || return 1
  outdir="$(project_outdir "$name")" || return 1
  build_stl "$scad" "$outdir/$name.stl" || return 1
  env -u DISPLAY -u WAYLAND_DISPLAY QT_QPA_PLATFORM=offscreen \
    openscad --backend=Manifold -o "$outdir/$name.3mf" "$scad" || return 1
  echo "built $outdir/$name.stl and $outdir/$name.3mf"
}

cmd_build() {
  local target="${1:-}"
  [ -n "$target" ] || die "usage: scad build <name|--all>"
  if [ "$target" = "--all" ]; then
    local d name rc=0
    for d in "$ROOT"/projects/*/; do
      name="$(basename "$d")"
      [ -f "$d$name.scad" ] || continue
      if ! build_one "$name"; then echo "scad: FAILED to build '$name'" >&2; rc=1; fi
    done
    return "$rc"
  fi
  build_one "$target"
}

cmd_preview() {
  local name="${1:-}"
  [ -n "$name" ] || die "usage: scad preview <name>"
  local scad out tmp stl bbox
  scad="$(project_scad "$name")"
  out="$ROOT/projects/$name/preview.png"
  tmp="$(mktmp)"
  stl="$tmp/$name.stl"
  build_stl "$scad" "$stl"
  bbox="$(bbox_line "$stl")"
  render_png "$scad" "$out" "$(view_rot iso)"
  overlay_bbox "$out" "$bbox"
  echo "$out"
}

cmd_list() {
  local d name found=0
  for d in "$ROOT"/projects/*/; do
    [ -d "$d" ] || continue
    name="$(basename "$d")"
    [ -f "$d$name.scad" ] || continue
    printf '%s\n' "$name"
    found=1
  done
  [ "$found" = 1 ] || echo "(no projects yet — create one with: scad new <name>)"
}

cmd_help() {
  cat <<'EOF'
scad — OpenSCAD project tool for CADastrophe

Usage:
  scad new <name>            scaffold projects/<name>/ from a BOSL2 starter
  scad render <name> [opts]  render PNG view(s) with bbox overlay -> output/
      --view iso|front|top|right|left|back|bottom   (default: iso)
      --all                  2x2 montage of iso/front/top/right
      --section x|y|z        flat cross-section through the centre
      --cutaway              remove a corner octant to expose the interior
      --size WxH             image size (default 900x900)
      -D name=value          OpenSCAD variable override (repeatable); strings
                             need quoted quotes: -D 'part="bracket"'
      --tag <t>              suffix output files: <name>_<t>_<view>.png
  scad verify <name> [-D ...] [--tag t]
                             build STL and print the geometry report
  scad build <name|--all>    export STL + 3MF to output/
  scad preview <name>        (re)generate committed projects/<name>/preview.png
  scad list                  list projects
  scad help                  this help

Iterate loop:  edit -> scad render <name> -> scad verify <name> -> fix -> repeat.
Note: `nix build .#<name>` only sees git-tracked projects; commit before building with Nix.
EOF
}

main() {
  local cmd="${1:-help}"
  shift || true
  case "$cmd" in
    new)            cmd_new "$@" ;;
    render)         cmd_render "$@" ;;
    verify)         cmd_verify "$@" ;;
    build)          cmd_build "$@" ;;
    preview)        cmd_preview "$@" ;;
    list|ls)        cmd_list "$@" ;;
    help|-h|--help) cmd_help ;;
    *)              die "unknown command '$cmd' (try: scad help)" ;;
  esac
}

main "$@"
